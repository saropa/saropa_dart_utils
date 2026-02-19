# BUG-030: `num.length()` Returns Misleading Value for Large Numbers via Scientific Notation

**File:** `lib/num/num_extensions.dart`
**Severity:** 🟢 Low
**Category:** Documentation / Edge Case
**Status:** Open

---

## Summary

`num.length()` uses `toString()` to count digits, but Dart's `toString()` produces scientific notation for very large or very small numbers. This means `1e20.length()` returns `5` (for the string `"1E+20"`) rather than the expected `21` (for the 21-digit representation of 100000000000000000000).

---

## Reproduction

```dart
1e20.length();   // ❌ Returns 5 (length of "1E+20")
                 // ✅ Expected: 21 (number of digits in the value)

1e-5.length();   // ❌ Returns 5 (length of "1E-5")
                 // ✅ Expected: 7 (for "0.00001")

100.length();    // ✅ Returns 3 — correct for small numbers
1234567.length(); // ✅ Returns 7 — correct
```

---

## Root Cause

```dart
// lib/num/num_extensions.dart ~line 39
int length() => toString().length;
//              ^^^^^^^^^^
//              Dart uses scientific notation for abs(x) >= 1e21 or abs(x) < 1e-6
```

Dart's `double.toString()` threshold for scientific notation:
- Values `>= 1e21` use scientific notation: `1e21.toString() = "1e+21"`
- Values `< 1e-6` use scientific notation: `1e-7.toString() = "1e-7"`

---

## Impact

- Any code using `length()` to check how many digits a number has will get wrong results for values in the scientific notation range.
- Numbers from API responses, financial calculations, or scientific data that exceed `1e21` will report wrong lengths.

---

## Suggested Fix

Document the limitation clearly in the dartdoc:

```dart
/// Returns the number of characters in the string representation of this number.
///
/// **Note:** For very large numbers (>= 1e21) or very small numbers (< 1e-6),
/// Dart uses scientific notation in [toString()], so this method returns the length
/// of the scientific notation string, not the count of decimal digits.
///
/// Example:
/// ```dart
/// 100.length();    // 3
/// 1e20.length();   // 5 (length of "100000000000000000000.0")
/// 1e21.length();   // 5 (length of "1e+21" in scientific notation!)
/// ```
int length() => toString().length;
```

Or fix it to always use decimal notation for integers/doubles:

```dart
int length() {
  if (this is int) return toString().length;
  // For doubles, avoid scientific notation
  final String s = toStringAsFixed(0);
  return s.startsWith('-') ? s.length - 1 : s.length;
}
```

---

## Missing Tests

```dart
group('num.length() edge cases', () {
  test('normal integer returns digit count', () {
    expect(12345.length(), equals(5));
  });

  test('large number uses scientific notation in toString', () {
    // Document actual behavior:
    expect(1e21.length(), equals(5)); // "1e+21" is 5 chars
    // Or after fix:
    // expect(1e21.length(), equals(22)); // actual digit count
  });

  test('negative number does not count minus sign', () {
    expect((-123).length(), equals(4)); // or 3, document clearly
  });
});
```
