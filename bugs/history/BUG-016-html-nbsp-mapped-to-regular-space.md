# BUG-016: `HtmlUtils` Maps `&nbsp;` to Regular Space Instead of Non-Breaking Space

**File:** `lib/html/html_utils.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error / HTML Compliance
**Status:** Open

---

## Summary

The HTML entity map converts `&nbsp;` (non-breaking space, Unicode U+00A0) to a regular ASCII space (`' '`, U+0020). These are different characters with different semantic and rendering behaviors. In HTML, `&nbsp;` prevents line breaks and is used for typographic spacing — converting it to a regular space changes the text's meaning and layout behavior.

---

## Reproduction

```dart
// HTML with non-breaking space
HtmlUtils.unescape('Hello&nbsp;World');
// ❌ ACTUAL:   'Hello World'  (regular space U+0020)
// ✅ EXPECTED: 'Hello\u00A0World'  (non-breaking space U+00A0)

// The difference:
'Hello\u0020World'.contains('\u00A0'); // false
'Hello\u00A0World'.contains('\u0020'); // false
// They look the same visually but are different characters
```

---

## Root Cause

```dart
// lib/html/html_utils.dart ~line 15
const Map<String, String> _htmlEntities = <String, String>{
  '&amp;':  '&',
  '&lt;':   '<',
  '&gt;':   '>',
  '&quot;': '"',
  '&apos;': "'",
  '&nbsp;': ' ',    // ← U+0020 (regular space) instead of U+00A0 (non-breaking)
  '&copy;': '©',
  '&reg;':  '®',
  '&trade;': '™',
  // ...
};
```

---

## Semantic Difference

| Character | Unicode | Name | Line Break? | HTML Entity |
|-----------|---------|------|-------------|-------------|
| ` ` | U+0020 | Space | Yes | `&#32;` |
| ` ` | U+00A0 | Non-Breaking Space | **No** | `&nbsp;` |

When stripping HTML for plain text display (using `toPlainText()`), the distinction matters:
- Regular space: used for word wrapping
- Non-breaking space: prevents wrapping, used in "10 km", "Dr. Smith", "§ 42"

---

## Impact

- Applications displaying plain text from HTML may incorrectly wrap text that was meant to stay together.
- Numeric values like `"100 km"` or `"$ 50"` may wrap between the number and unit.
- Any downstream processing that checks for `\u00A0` to detect non-breaking spaces will get wrong results.

---

## Suggested Fix

```dart
const Map<String, String> _htmlEntities = <String, String>{
  '&amp;':  '&',
  '&lt;':   '<',
  '&gt;':   '>',
  '&quot;': '"',
  '&apos;': "'",
  '&nbsp;': '\u00A0',  // ← Non-breaking space (U+00A0), not regular space
  '&copy;': '©',
  '&reg;':  '®',
  '&trade;': '™',
};
```

---

## Missing Tests

The existing test for `&nbsp;`:

```dart
// test/html/html_utils_test.dart
test('handles &nbsp;', () {
  expect(HtmlUtils.unescape('&nbsp;'), equals(' ')); // ← Testing wrong value!
});
```

The test itself is testing the *wrong* expected value. It should be:

```dart
test('&nbsp; unescapes to non-breaking space (U+00A0)', () {
  expect(HtmlUtils.unescape('&nbsp;'), equals('\u00A0'));
  expect(HtmlUtils.unescape('&nbsp;'), isNot(equals(' '))); // Not regular space
});

test('regular space is different from non-breaking space', () {
  final result = HtmlUtils.unescape('Hello&nbsp;World');
  expect(result, equals('Hello\u00A0World'));
  expect(result, isNot(equals('Hello World'))); // Not the same!
});
```
