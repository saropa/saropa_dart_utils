# BUG-002: `getUtcTimeFromLocal` Has Backwards Conversion Logic and Negative Offset Bug

**File:** `lib/datetime/date_time_extensions.dart`
**Severity:** 🔴 Critical
**Category:** Logic Error / Timezone Handling
**Status:** Open

---

## Summary

`getUtcTimeFromLocal` contains two compounding bugs:

1. **Backwards arithmetic**: It *adds* the UTC offset to get UTC time, but converting from local-to-UTC requires *subtracting* the offset.
2. **Negative fractional offset floor() bug**: For negative offsets like `-5.5`, `floor()` returns `-6` (not `-5`), producing wrong hour/minute decomposition.

---

## Reproduction

```dart
// Scenario: You have a local time of 15:00 in timezone UTC+2 (e.g., CEST)
// Converting to UTC should give 13:00 (subtract 2 hours)

final local = DateTime(2024, 6, 15, 15, 0, 0);
final result = local.getUtcTimeFromLocal(2.0);

// ❌ ACTUAL:   17:00 (adds 2 hours instead of subtracting)
// ✅ EXPECTED: 13:00 (UTC+2 means local is 2 hours ahead of UTC)
```

```dart
// Scenario: Negative fractional offset -5.5 (UTC-5:30, e.g., India Standard offset inverted)
final local = DateTime(2024, 1, 1, 10, 0, 0);
final result = local.getUtcTimeFromLocal(-5.5);

// hours = (-5.5).floor() = -6   ← BUG: should be -5
// minutes = ((-5.5 - (-6)) * 60).round() = (0.5 * 60).round() = 30
// Adds Duration(hours: -6, minutes: 30) = -5h30m net (accidentally correct result!)
// BUT: the ADD instead of SUBTRACT bug means it's still wrong directionally
```

---

## Root Cause

```dart
// lib/datetime/date_time_extensions.dart ~line 499
DateTime? getUtcTimeFromLocal(double offset) {
  if (offset == 0) {
    return this;
  }

  final int hours = offset.floor();                         // BUG for negative fractions
  final int minutes = ((offset - hours) * 60).round();

  return toUtc().add(Duration(hours: hours, minutes: minutes));
  //             ^^^
  //             WRONG DIRECTION: should subtract to get UTC from local
}
```

### The `floor()` Problem with Negative Fractions

```
offset = -5.5
hours  = (-5.5).floor() = -6          ← floor rounds towards negative infinity
minutes = ((-5.5 - (-6)) * 60)
        = ((- 5.5 + 6) * 60)
        = (0.5 * 60) = 30             ← positive 30 minutes

Net duration: -6 hours + 30 minutes = -5h30m
Correct would be: -5 hours + 30 minutes but with minutes negative too
```

For negative offsets, the hours and minutes should both be negative, or you should use `truncate()` instead of `floor()`:

```
offset = -5.5
truncate(-5.5) = -5                   ← correct!
minutes = ((-5.5 - (-5)) * 60)
        = (-0.5 * 60) = -30           ← negative, correct sign
```

---

## Impact

- All timezone conversion logic using this method will silently produce wrong results.
- Affects scheduling, meeting time conversion, international date handling.
- The bug produces plausible-looking wrong times (off by 2×offset hours), hard to catch without timezone-aware testing.

---

## Suggested Fix

```dart
/// Converts this local DateTime to UTC using the given offset.
///
/// [offset] is positive for timezones ahead of UTC (e.g., +2.0 for UTC+2),
/// negative for timezones behind UTC (e.g., -5.0 for UTC-5).
///
/// Example:
/// ```dart
/// // 15:00 local in UTC+2 → 13:00 UTC
/// DateTime(2024, 6, 15, 15, 0).getUtcTimeFromLocal(2.0); // 13:00
/// ```
DateTime? getUtcTimeFromLocal(double offset) {
  if (offset == 0) return this;

  // Use truncate (not floor) so -5.5 → hours=-5, fraction=-0.5
  final int hours = offset.truncate();
  final int minutes = ((offset - hours) * 60).round();

  // Subtract offset to convert local→UTC: UTC = local - offset
  return subtract(Duration(hours: hours, minutes: minutes));
}
```

---

## Missing Tests

The test suite for `getUtcTimeFromLocal` does NOT cover:
1. Positive offset round-trip (local → UTC → local)
2. Negative offsets
3. Fractional offsets (half-hour timezones like India UTC+5:30, Iran UTC+3:30)
4. Zero offset
5. Extreme offsets (UTC+14, UTC-12)
6. The direction of conversion (is it local→UTC or UTC→local?)

```dart
group('getUtcTimeFromLocal', () {
  test('UTC+2: 15:00 local → 13:00 UTC', () {
    final local = DateTime(2024, 6, 15, 15, 0, 0);
    expect(local.getUtcTimeFromLocal(2.0)?.hour, equals(13));
  });

  test('UTC-5: 10:00 local → 15:00 UTC', () {
    final local = DateTime(2024, 1, 15, 10, 0, 0);
    expect(local.getUtcTimeFromLocal(-5.0)?.hour, equals(15));
  });

  test('UTC+5:30 (India): 10:30 local → 05:00 UTC', () {
    final local = DateTime(2024, 1, 15, 10, 30, 0);
    final utc = local.getUtcTimeFromLocal(5.5);
    expect(utc?.hour, equals(5));
    expect(utc?.minute, equals(0));
  });

  test('zero offset returns same time', () {
    final dt = DateTime(2024, 1, 1, 12, 0);
    expect(dt.getUtcTimeFromLocal(0.0), equals(dt));
  });
});
```
