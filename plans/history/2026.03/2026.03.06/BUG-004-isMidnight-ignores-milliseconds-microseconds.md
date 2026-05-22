# BUG-004: `isMidnight` Ignores Milliseconds and Microseconds

**File:** `lib/datetime/date_time_extensions.dart`
**Severity:** 🟡 Medium
**Category:** Edge Case / Logic Error
**Status:** Open

---

## Summary

The `isMidnight` getter checks only `hour`, `minute`, and `second` — but does not check `millisecond` or `microsecond`. A time of `00:00:00.001` (one millisecond after midnight) is incorrectly reported as midnight.

---

## Reproduction

```dart
final almostMidnight = DateTime(2024, 1, 1, 0, 0, 0, 1); // 00:00:00.001
print(almostMidnight.isMidnight); // ❌ Returns TRUE — should be FALSE

final trueMidnight = DateTime(2024, 1, 1, 0, 0, 0, 0, 0); // 00:00:00.000000
print(trueMidnight.isMidnight); // ✅ Returns TRUE — correct
```

---

## Root Cause

```dart
// lib/datetime/date_time_extensions.dart ~line 206
bool get isMidnight => hour == 0 && minute == 0 && second == 0;
//                                                              ^
//                     Missing: && millisecond == 0 && microsecond == 0
```

---

## Impact

- Date boundary calculations that rely on `isMidnight` to detect exact midnight can silently accept times slightly past midnight.
- Affects any scheduling, "start of day", or event-at-midnight logic.
- Dart's `DateTime` can hold microsecond precision, so sub-second midnight checks are valid and common when working with database timestamps.

---

## Comparison with Related Methods

The related `isEndOfDay` (if it exists) should have a similar check. The general principle of "check all time components" is not applied consistently across datetime predicates.

---

## Suggested Fix

```dart
/// Returns true only if this DateTime represents exactly midnight
/// (00:00:00.000000 — all time components are zero).
bool get isMidnight =>
    hour == 0 &&
    minute == 0 &&
    second == 0 &&
    millisecond == 0 &&
    microsecond == 0;
```

Alternatively, compare against midnight directly:

```dart
bool get isMidnight {
  final midnight = DateTime(year, month, day); // Truncates all time components
  return isAtSameMomentAs(midnight);
}
```

Note: The second form also handles timezone correctly if the DateTime is UTC, since `DateTime(year, month, day)` creates a local DateTime.

---

## Missing Tests

No existing test verifies sub-second precision for `isMidnight`:

```dart
group('isMidnight', () {
  test('exactly midnight returns true', () {
    expect(DateTime(2024, 1, 1, 0, 0, 0, 0, 0).isMidnight, isTrue);
  });

  test('1 millisecond after midnight returns false', () {
    expect(DateTime(2024, 1, 1, 0, 0, 0, 1).isMidnight, isFalse);
  });

  test('1 microsecond after midnight returns false', () {
    expect(DateTime(2024, 1, 1, 0, 0, 0, 0, 1).isMidnight, isFalse);
  });

  test('1 second after midnight returns false', () {
    expect(DateTime(2024, 1, 1, 0, 0, 1).isMidnight, isFalse);
  });

  test('noon is not midnight', () {
    expect(DateTime(2024, 1, 1, 12, 0, 0).isMidnight, isFalse);
  });
});
```
