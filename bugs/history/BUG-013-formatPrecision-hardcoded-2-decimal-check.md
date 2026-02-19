# BUG-013: `formatPrecision()` Ignores `precision` Parameter When Checking for Whole Numbers

**File:** `lib/double/double_extensions.dart`
**Severity:** 🔴 High
**Category:** Logic Error
**Status:** Open

---

## Summary

`formatPrecision({int precision = 2})` accepts a `precision` parameter but hardcodes `toStringAsFixed(2)` for the "is this a whole number" check. When `precision` is anything other than `2`, the whole-number detection is wrong — a value like `15.5` with `precision: 3` will not match `.00` and will return `15.500`, which is correct, but the detection path is unreliable for future values. More critically, if someone passes `precision: 4` and the value is `15.0`, the check is against `"15.00"` which ends with `.00` — accidentally returns `"15"` (correct). But for `precision: 1`, `15.0.toStringAsFixed(2)` = `"15.00"` still returns `"15"` (happens to work). The hardcoding is a logic smell that creates fragile, non-obvious code.

The real bug: `15.5.formatPrecision(precision: 3)` should return `"15.500"` but the logic checks `toStringAsFixed(2)` = `"15.50"` which does NOT end with `.00`, so falls through to `toStringAsFixed(3)` = `"15.500"` — accidentally correct. However, this is only lucky coincidence.

The **actual failure** case:

```dart
// A value that rounds to X.X0 at precision 2 but not a true whole number
15.001.formatPrecision(precision: 4);
// toStringAsFixed(2) = "15.00" → endsWith('.00') = TRUE → returns "15"
// But the actual value is 15.001, not 15!
// With precision: 4 the user expected "15.0010"
```

---

## Reproduction

```dart
// Precision issue: the number is NOT a whole number but rounds to look like one
15.001.formatPrecision(precision: 4);
// ❌ ACTUAL:   '15'    (treated as whole number because toStringAsFixed(2) = "15.00")
// ✅ EXPECTED: '15.0010' (shows the actual precision at 4 decimal places)

// Consistency issue: the precision parameter doesn't control the whole-number threshold
15.005.formatPrecision(precision: 2); // '15.01' (rounds up at 2dp — not whole)
15.004.formatPrecision(precision: 2); // '15.00' (rounds to appear whole at 2dp)
// The threshold for "is whole?" matches precision: 2 but not other values
```

---

## Root Cause

```dart
// lib/double/double_extensions.dart ~line 144
String formatPrecision({int precision = 2}) {
  return toStringAsFixed(2).endsWith('.00')  // ← HARDCODED 2, ignores 'precision'
      ? toStringAsFixed(0)
      : toStringAsFixed(precision);
}
```

The fix is to use the existing `hasDecimals` getter (which correctly uses `% 1 != 0`) or to use `toStringAsFixed(precision)` for both checks:

---

## Suggested Fix

```dart
String formatPrecision({int precision = 2}) {
  // Use actual integer check, not string-based check
  if (this % 1 == 0) {
    return toStringAsFixed(0); // True whole number — no decimals
  }
  return toStringAsFixed(precision);
}
```

Or using the existing `hasDecimals` getter:

```dart
String formatPrecision({int precision = 2}) {
  return hasDecimals ? toStringAsFixed(precision) : toStringAsFixed(0);
}
```

**Note:** The `hasDecimals` getter also uses `% 1 != 0` which has the same floating-point caveat — `0.1 + 0.2 - 0.3` returns a tiny non-zero value. For a more robust solution, use `precision`-aware rounding:

```dart
String formatPrecision({int precision = 2}) {
  final rounded = toStringAsFixed(precision);
  // Check if all decimal digits are zero
  final parts = rounded.split('.');
  if (parts.length > 1 && int.tryParse(parts[1]) == 0) {
    return parts[0]; // Whole number at this precision
  }
  return rounded;
}
```

---

## Missing Tests

No test covers `precision` parameter values other than the default `2`:

```dart
group('formatPrecision', () {
  test('whole number at precision 4 should not show decimals', () {
    expect(15.0.formatPrecision(precision: 4), equals('15'));
  });

  test('near-whole at precision 2 treated as whole', () {
    // 15.001 rounds to 15.00 at 2dp — this should show 15, not 15.0010
    // (debatable — document chosen behavior)
    expect(15.001.formatPrecision(precision: 4), equals('15.0010')); // not '15'
  });

  test('precision 1 with decimal', () {
    expect(15.5.formatPrecision(precision: 1), equals('15.5'));
  });

  test('precision 3 with decimal', () {
    expect(15.123.formatPrecision(precision: 3), equals('15.123'));
  });

  test('precision 0 whole number', () {
    expect(15.0.formatPrecision(precision: 0), equals('15'));
  });
});
```
