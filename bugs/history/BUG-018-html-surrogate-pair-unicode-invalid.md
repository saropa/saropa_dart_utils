# BUG-018: `HtmlUtils.unescape()` Allows Invalid Unicode Surrogate Codepoints

**File:** `lib/html/html_utils.dart`
**Severity:** 🟡 Medium
**Category:** Edge Case / Security
**Status:** Open

---

## Summary

The numeric HTML entity handler in `HtmlUtils.unescape()` validates that codepoints are within `(0, _maxUnicodeCodePoint]` but does not exclude the surrogate pair range (U+D800–U+DFFF). Surrogates are not valid standalone Unicode characters — calling `String.fromCharCode(0xD800)` produces a malformed string that can cause encoding failures, display issues, or crashes in downstream processing.

---

## Reproduction

```dart
// U+D800 is a high surrogate — invalid standalone character
HtmlUtils.unescape('&#xD800;'); // Should return '&#xD800;' (original), not a surrogate char
// ❌ ACTUAL:   Returns String.fromCharCode(0xD800) — invalid UTF character
// ✅ EXPECTED: Returns '&#xD800;' (original entity, cannot be converted)

// U+DFFF is a low surrogate — also invalid standalone
HtmlUtils.unescape('&#xDFFF;');
// ❌ ACTUAL:   Returns String.fromCharCode(0xDFFF) — invalid
// ✅ EXPECTED: Returns '&#xDFFF;' (original)
```

---

## Root Cause

```dart
// lib/html/html_utils.dart ~line 104
// The entity regex handler:
if (codePoint != null && codePoint > 0 && codePoint <= _maxUnicodeCodePoint) {
  return String.fromCharCode(codePoint);
  //     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //     No check for surrogate range 0xD800-0xDFFF
}
return match.group(0) ?? ''; // Return original if codePoint is out of range
```

The valid Unicode range for scalar values is:
- U+0001 to U+D7FF
- U+E000 to U+10FFFF (where `_maxUnicodeCodePoint = 0x10FFFF`)

The range U+D800 to U+DFFF (surrogates) is explicitly reserved for UTF-16 surrogate pairs and must **never** appear as standalone characters in Unicode text.

---

## Impact

- **Malformed strings**: Dart's `String.fromCharCode(0xD800)` creates a string containing an isolated surrogate, which is not valid Unicode (it's "WTF-8" or "CESU-8", not UTF-8).
- **JSON serialization failure**: `jsonEncode()` will throw on strings containing surrogates.
- **File I/O failures**: `utf8.encode()` on a string with surrogates throws `FormatException`.
- **Crash risk**: Any code path that serializes or exports the unescaped HTML content may crash.

---

## Example Crash

```dart
final bad = HtmlUtils.unescape('test&#xD800;test');
// bad contains a surrogate — looks fine visually
jsonEncode(bad); // THROWS: Invalid or unexpected token
utf8.encode(bad); // THROWS: FormatException: Invalid UTF-8 byte
```

---

## Suggested Fix

```dart
// lib/html/html_utils.dart
const int _minSurrogate = 0xD800;
const int _maxSurrogate = 0xDFFF;

// In the entity handler:
if (codePoint != null &&
    codePoint > 0 &&
    codePoint <= _maxUnicodeCodePoint &&
    !(codePoint >= _minSurrogate && codePoint <= _maxSurrogate)) {
  return String.fromCharCode(codePoint);
}
return match.group(0) ?? ''; // Return original entity for invalid codepoints
```

---

## Missing Tests

The existing test partially covers this:

```dart
test('handles invalid numeric entities gracefully', () {
  expect(HtmlUtils.unescape('&#999999999999;'), equals('&#999999999999;'));
  expect(HtmlUtils.unescape('&#xZZZ;'), equals('&#xZZZ;'));
});
```

But surrogate codepoints are missing:

```dart
test('rejects surrogate codepoints', () {
  // High surrogate
  expect(HtmlUtils.unescape('&#xD800;'), equals('&#xD800;'));
  // Low surrogate
  expect(HtmlUtils.unescape('&#xDFFF;'), equals('&#xDFFF;'));
  // Middle of surrogate range
  expect(HtmlUtils.unescape('&#xDC00;'), equals('&#xDC00;'));
});

test('surrogate result does not cause JSON encode to throw', () {
  final result = HtmlUtils.unescape('test&#xD800;test');
  expect(() => jsonEncode(result), returnsNormally);
});
```
