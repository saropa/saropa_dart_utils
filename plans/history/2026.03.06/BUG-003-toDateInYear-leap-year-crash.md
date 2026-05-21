# BUG-003: `toDateInYear` Throws Unhandled Exception for Feb 29 in Non-Leap Years

**File:** `lib/datetime/date_time_extensions.dart`
**Severity:** 🔴 Critical
**Category:** Edge Case / Crash
**Status:** Open

---

## Summary

`toDateInYear(int setYear)` will throw an `ArgumentError` (or return an invalid date) when called on a February 29 date and the target year is not a leap year. The method has no guard for this case, making it crash in production for leap-year birthdays, anniversaries, or any recurring events set on Feb 29.

---

## Reproduction

```dart
// Feb 29 only exists in leap years
final leapDay = DateTime(2024, 2, 29); // 2024 is a leap year ✓

// ❌ CRASH: 2023 is not a leap year — DateTime(2023, 2, 29) throws
final result = leapDay.toDateInYear(2023);
// Unhandled Exception: Invalid date

// ✅ Fine for leap years
final result2 = leapDay.toDateInYear(2028); // 2028 is a leap year ✓
```

---

## Root Cause

```dart
// lib/datetime/date_time_extensions.dart ~line 212
DateTime? toDateInYear(int setYear) => DateTime(setYear, month, day);
//                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// No validation: DateTime(2023, 2, 29) throws ArgumentError in Dart
```

Dart's `DateTime` constructor throws if the day is invalid for the given month/year combination. There is no try-catch or pre-validation.

---

## Impact

- **Crash risk**: Any recurring yearly event on Feb 29 (leap year birthdays, anniversary calculations) will crash when `toDateInYear` is called for a non-leap year.
- The method return type is `DateTime?` (nullable), suggesting the implementer intended to handle failure cases — but the failure mode was not implemented.
- The method is used in `age`, `birthday`, and yearly schedule calculations throughout the codebase.

---

## How to Detect

```dart
// Check if 2024 leap day survives in 2023
bool isLeapYear(int year) =>
    (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);

// 2023 is not a leap year
print(isLeapYear(2023)); // false
// DateTime(2023, 2, 29) → THROWS
```

---

## Suggested Fix

Two valid approaches depending on intended semantics:

### Option A: Return null for invalid dates (matches nullable return type intent)
```dart
DateTime? toDateInYear(int setYear) {
  // Dart doesn't validate in constructor directly for all cases,
  // use DateTime.utc to detect overflow
  if (month == 2 && day == 29 && !_isLeapYear(setYear)) {
    return null; // Feb 29 doesn't exist in non-leap years
  }
  return DateTime(setYear, month, day, hour, minute, second,
                  millisecond, microsecond);
}

bool _isLeapYear(int year) =>
    year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
```

### Option B: Clamp to Feb 28 for non-leap years (more user-friendly for birthdays)
```dart
DateTime? toDateInYear(int setYear) {
  int targetDay = day;
  if (month == 2 && day == 29 && !_isLeapYear(setYear)) {
    targetDay = 28; // Clamp to Feb 28
  }
  return DateTime(setYear, month, targetDay, hour, minute, second,
                  millisecond, microsecond);
}
```

---

## Missing Tests

No test in the suite exercises `toDateInYear` with a Feb 29 source date:

```dart
group('toDateInYear - leap year edge cases', () {
  test('Feb 29 in leap year to another leap year succeeds', () {
    final leapDay = DateTime(2024, 2, 29);
    expect(leapDay.toDateInYear(2028), equals(DateTime(2028, 2, 29)));
  });

  test('Feb 29 to non-leap year returns null (or Feb 28)', () {
    final leapDay = DateTime(2024, 2, 29);
    // Depending on chosen fix:
    expect(leapDay.toDateInYear(2023), isNull);
    // OR: expect(leapDay.toDateInYear(2023), equals(DateTime(2023, 2, 28)));
  });

  test('Feb 28 to non-leap year works normally', () {
    final feb28 = DateTime(2024, 2, 28);
    expect(feb28.toDateInYear(2023), equals(DateTime(2023, 2, 28)));
  });

  test('Feb 28 to leap year works normally', () {
    final feb28 = DateTime(2023, 2, 28);
    expect(feb28.toDateInYear(2024), equals(DateTime(2024, 2, 28)));
  });
});
```
