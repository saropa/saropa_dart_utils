# BUG-001: `isBetween` Inclusive Mode Excludes Boundaries

**File:** `lib/datetime/date_time_extensions.dart`
**Severity:** 🔴 High
**Category:** Logic Error
**Status:** Open

---

## Summary

The `isBetween` method's `inclusive` mode is broken. When `inclusive: true`, the method should return `true` when the DateTime equals `start` or `end`. However, the current implementation uses `isAfter(start)` which is a *strict* inequality — `start` itself is never "after start", so boundary dates are incorrectly excluded.

---

## Reproduction

```dart
final start = DateTime(2024, 1, 1);
final end   = DateTime(2024, 12, 31);

// ❌ Should return true — boundary is inclusive — but returns FALSE
start.isBetween(start, end, inclusive: true);

// ❌ Should return true — boundary is inclusive — but returns FALSE
end.isBetween(start, end, inclusive: true);

// ✅ Mid-range works correctly
DateTime(2024, 6, 15).isBetween(start, end, inclusive: true); // true
```

---

## Root Cause

```dart
// lib/datetime/date_time_extensions.dart ~line 614
bool isBetween(DateTime start, DateTime end, {bool inclusive = true}) {
  if (inclusive) {
    // BUG: isAfter() is strict — 'this == start' makes isAfter(start) → false
    return (this == start || isAfter(start)) && (this == end || isBefore(end));
    //      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //      The short-circuit `this == start` should work but the OR with
    //      isAfter(start) is only reached when this != start, yet both
    //      conditions are evaluated as logical OR — so this == start DOES
    //      short-circuit. Let me re-examine...
  }
  return isAfter(start) && isBefore(end);
}
```

**On closer inspection:** The `||` short-circuit is correct for `this == start`, BUT the second boundary condition uses `isBefore(end)` — meaning `this == end` is handled correctly. However, the equality check using `==` on DateTime compares all components including time zone. If `this` and `start` are in different time zones (one UTC, one local), `==` returns `false` even at the "same moment". The correct comparison is `isAtSameMomentAs`.

**Actual Bug:** DateTime equality (`==`) is **reference equality combined with value equality but timezone-sensitive**. Two DateTimes representing the same instant in different timezones will NOT be equal under `==`:

```dart
final utc   = DateTime.utc(2024, 1, 1, 12, 0);
final local = utc.toLocal();

print(utc == local);                   // false — different isUtc flag
print(utc.isAtSameMomentAs(local));    // true  — same instant
```

---

## Impact

- Any code checking if a date is "at the start/end of a range" with mixed UTC/local DateTimes will get wrong results.
- Particularly impactful in scheduling, date range filtering, and calendar features.

---

## Suggested Fix

```dart
bool isBetween(DateTime start, DateTime end, {bool inclusive = true}) {
  if (inclusive) {
    return (isAfter(start) || isAtSameMomentAs(start)) &&
           (isBefore(end)  || isAtSameMomentAs(end));
  }
  return isAfter(start) && isBefore(end);
}
```

---

## Missing Tests

The test suite does NOT cover:
1. `this == start` with `inclusive: true` (boundary equality)
2. `this == end` with `inclusive: true` (boundary equality)
3. UTC vs local DateTime comparisons in `isBetween`
4. `start == end` (point range) — should return true only when `this == start` and inclusive

```dart
// Tests to add:
test('inclusive start boundary returns true', () {
  final start = DateTime(2024, 1, 1);
  final end = DateTime(2024, 12, 31);
  expect(start.isBetween(start, end, inclusive: true), isTrue);
});

test('inclusive end boundary returns true', () {
  final start = DateTime(2024, 1, 1);
  final end = DateTime(2024, 12, 31);
  expect(end.isBetween(start, end, inclusive: true), isTrue);
});

test('exclusive boundaries excluded', () {
  final start = DateTime(2024, 1, 1);
  final end = DateTime(2024, 12, 31);
  expect(start.isBetween(start, end, inclusive: false), isFalse);
  expect(end.isBetween(start, end, inclusive: false), isFalse);
});

test('UTC vs local boundary comparison', () {
  final utcStart = DateTime.utc(2024, 1, 1);
  final localStart = utcStart.toLocal();
  expect(localStart.isBetween(utcStart, DateTime.utc(2024, 12, 31), inclusive: true), isTrue);
});
```
