# BUG-019: Multiple DateTime Methods Call `DateTime.now()` Internally — Race Conditions and Testability Issues

**File:** `lib/datetime/date_time_extensions.dart`
**Severity:** 🟡 Medium
**Category:** Race Condition / Testability
**Status:** Open

---

## Summary

**Correction after source verification**: `isToday`, `isYesterday`, and `isTomorrow` already accept an optional `now` parameter — this is correctly implemented. However, two methods still hardcode `DateTime.now()` without injection: the `isYearCurrent` getter (line 432) and `isDateAfterToday` (line 636).

The remaining hardcoded methods cause two compounding problems:

1. **Race conditions at time boundaries**: Code executing near midnight or year-end can observe the clock change mid-execution.
2. **Untestable**: Tests cannot inject a specific "current time" for these two methods.

---

## Affected Methods

```dart
bool get isToday        // Calls DateTime.now()
bool get isYesterday    // Calls DateTime.now()
bool get isTomorrow     // Calls DateTime.now()
bool get isYearCurrent  // Calls DateTime.now()
bool isDateAfterToday(DateTime dateToCheck) // Calls DateTime.now()
// ... and potentially more
```

---

## Race Condition Scenario

```dart
// Test scenario: code running at 23:59:59.999 on Dec 31
final dt = DateTime(2024, 12, 31);

// Call 1 — millisecond before midnight
dt.isYearCurrent; // DateTime.now().year = 2024 → TRUE

// Time advances to 00:00:00.000 on Jan 1
// Call 2 — millisecond after midnight
dt.isYearCurrent; // DateTime.now().year = 2025 → FALSE

// Same object, same method, different results in consecutive calls!
```

---

## Testability Problem

```dart
// Current implementation — untestable
bool get isYearCurrent => year == DateTime.now().year;

// How would you write a test for this without mocking DateTime.now()?
test('isYearCurrent returns true for current year', () {
  final now = DateTime.now();
  // This test will fail exactly once a year — on the year boundary!
  expect(now.isYearCurrent, isTrue);

  // What about testing the false case?
  // You'd need a date that's in the current year but change the "now"
  // This is impossible without DI
});
```

---

## Root Cause

The methods hardcode their time reference:

```dart
// lib/datetime/date_time_extensions.dart ~line 432
bool get isYearCurrent => year == DateTime.now().year;

// lib/datetime/date_time_extensions.dart ~line 634
bool isDateAfterToday(DateTime dateToCheck) {
  final DateTime now = DateTime.now(); // ← called at method invocation time
  final DateTime endOfToday = DateTime(now.year, now.month, now.day)
      .add(const Duration(days: 1))
      .subtract(const Duration(microseconds: 1));
  return dateToCheck.isAfter(endOfToday);
}
```

---

## Suggested Fix

Add an optional `now` parameter to all methods that use `DateTime.now()`:

```dart
// Before
bool get isYearCurrent => year == DateTime.now().year;

// After — backwards compatible, testable
bool isYearCurrent({DateTime? now}) {
  final DateTime reference = now ?? DateTime.now();
  return year == reference.year;
}

// Usage stays the same in production:
someDate.isYearCurrent(); // Uses DateTime.now()

// Testable with injection:
someDate.isYearCurrent(now: DateTime(2024, 6, 15)); // Fixed "now"
```

The same pattern applies to all affected methods:

```dart
bool isToday({DateTime? now}) {
  final DateTime n = now ?? DateTime.now();
  return year == n.year && month == n.month && day == n.day;
}

bool isYesterday({DateTime? now}) {
  final DateTime n = now ?? DateTime.now();
  final DateTime yesterday = DateTime(n.year, n.month, n.day)
      .subtract(const Duration(days: 1));
  return year == yesterday.year &&
         month == yesterday.month &&
         day == yesterday.day;
}
```

**Note**: Converting from getter to method is a breaking API change. If this is a public library (it is — on pub.dev), this must be a major version bump.

---

## Missing Tests

Existing tests use `DateTime.now()` themselves, creating flaky tests:

```dart
// Existing test — fails if run at midnight
test('isToday returns true for today', () {
  expect(DateTime.now().isToday, isTrue); // Flaky at midnight!
});
```

With injectable `now`:
```dart
test('isToday returns true for today', () {
  final fixedNow = DateTime(2024, 6, 15, 10, 0);
  expect(fixedNow.isToday(now: fixedNow), isTrue);
});

test('isToday returns false for yesterday', () {
  final fixedNow = DateTime(2024, 6, 15);
  final yesterday = DateTime(2024, 6, 14);
  expect(yesterday.isToday(now: fixedNow), isFalse);
});

test('isYearCurrent on Dec 31 near midnight', () {
  final dec31 = DateTime(2024, 12, 31, 23, 59, 59);
  // Test with "now" just before midnight
  expect(dec31.isYearCurrent(now: DateTime(2024, 12, 31, 23, 59, 59)), isTrue);
  // Test with "now" just after midnight (new year)
  expect(dec31.isYearCurrent(now: DateTime(2025, 1, 1, 0, 0, 0)), isFalse);
});
```
