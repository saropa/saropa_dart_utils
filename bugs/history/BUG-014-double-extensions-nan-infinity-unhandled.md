# BUG-014: Double Extensions Don't Handle `NaN` and `Infinity`

**File:** `lib/double/double_extensions.dart`
**Severity:** 🟡 Medium
**Category:** Edge Case
**Status:** Open

---

## Summary

Multiple double extension methods silently produce misleading or broken results when given `double.nan`, `double.infinity`, or `double.negativeInfinity`. These are valid Dart `double` values that occur in division-by-zero, `sqrt(-1)`, JSON parsing, and math operations.

---

## Affected Methods and Their Failures

### `hasDecimals`
```dart
bool get hasDecimals => this % 1 != 0;

double.nan % 1 // = NaN (not 0, not "has decimals")
double.nan.hasDecimals // = true  ← misleading
double.infinity.hasDecimals // = true ← misleading
```

### `formatDouble()`
```dart
double.nan.formatDouble(2);          // Returns "NaN"
double.infinity.formatDouble(2);     // Returns "Infinity"
double.negativeInfinity.formatDouble(2); // Returns "-Infinity"
// These are strings but not formatted numbers — likely to break display code
```

### `toPercentage()`
```dart
double.nan.toPercentage();      // Returns "NaN%"
double.infinity.toPercentage(); // Returns "Infinity%"
// Nonsensical output passed through silently
```

### `formatPrecision()`
```dart
double.nan.formatPrecision();      // Returns "NaN" (or crashes on % check)
double.infinity.formatPrecision(); // Returns "Infinity"
```

### `isInRange()`
```dart
double.nan.isInRange(0, 10); // = false (correct, NaN comparisons always false)
// But NaN is not documented as out-of-range; it's undefined
```

---

## Root Cause

No guard clauses exist for special float values:

```dart
// lib/double/double_extensions.dart
bool get hasDecimals => this % 1 != 0;
// No: if (isNaN || isInfinite) return false;
```

---

## Impact

- Applications receiving data from APIs may get `null` JSON values that become `0.0` (from type coercion), or receive `Infinity` from mathematical operations like `1.0 / 0.0`.
- Silent propagation of `NaN` causes values to appear formatted in UI ("NaN%") instead of gracefully handling the error case.
- `hasDecimals` returning `true` for `NaN` means `formatPrecision` will format it as if it has decimals, not as the error value it is.

---

## Suggested Fix

Add guards to the most-used methods:

```dart
bool get hasDecimals {
  if (isNaN || isInfinite) return false;
  return this % 1 != 0;
}

String formatDouble(int decimalPlaces, {bool showTrailingZeros = true}) {
  if (isNaN) return 'NaN';
  if (isInfinite) return isNegative ? '-∞' : '∞';
  // ... existing implementation
}

String toPercentage({int decimalPlaces = 0, bool roundDown = true}) {
  if (isNaN || isInfinite) return '';
  // ... existing implementation
}
```

---

## Missing Tests

No test exercises any special float values:

```dart
group('NaN and Infinity handling', () {
  test('hasDecimals returns false for NaN', () {
    expect(double.nan.hasDecimals, isFalse);
  });

  test('hasDecimals returns false for infinity', () {
    expect(double.infinity.hasDecimals, isFalse);
  });

  test('formatDouble handles NaN gracefully', () {
    // Should return a safe fallback, not throw
    expect(() => double.nan.formatDouble(2), returnsNormally);
  });

  test('toPercentage handles NaN gracefully', () {
    expect(double.nan.toPercentage(), isEmpty);
  });

  test('isInRange returns false for NaN', () {
    expect(double.nan.isInRange(0, 10), isFalse);
  });
});
```
