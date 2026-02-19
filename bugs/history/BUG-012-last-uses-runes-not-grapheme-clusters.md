# BUG-012: `last()` Uses Rune-Based Indexing, Breaking Multi-Codepoint Emoji

**File:** `lib/string/string_extensions.dart`
**Severity:** 🔴 High
**Category:** Logic Error / Unicode Handling
**Status:** Open

---

## Summary

The `last(int len)` method uses `runes.length` for length calculation and rune list slicing. This produces incorrect results for grapheme clusters that consist of multiple Unicode codepoints — such as family emoji (`👨‍👩‍👧‍👦`), skin-tone modifier emoji (`👋🏽`), or flag emoji (`🇺🇸`). The related `lastChars()` method correctly uses the `characters` package (grapheme clusters), but `last()` does not — creating an inconsistency.

---

## Reproduction

```dart
// 'test' preceded by a family emoji (multi-codepoint: 8 runes, 1 grapheme cluster)
final s = '👨‍👩‍👧‍👦test';

// ✅ lastChars uses grapheme clusters — correct
s.lastChars(4); // Returns 'test'
s.lastChars(1); // Returns 't'

// ❌ last() uses runes — returns broken output for emoji-adjacent chars
s.last(4); // May return partial emoji bytes + 'tes', splitting the 'e' from context
s.last(1); // Returns 't' here by luck — but emoji + any string is unsafe
```

---

## Concrete Failing Example

```dart
const emoji = '👋🏽'; // wave with medium skin tone modifier: 2 runes
// Rune 1: 👋 (U+1F44B) — waving hand
// Rune 2: 🏽 (U+1F3FD) — medium skin tone modifier
// Together they form ONE grapheme cluster

'hello👋🏽'.last(1);
// Rune-based: takes the LAST 1 rune = '🏽' (skin tone modifier)
// This is a meaningless codepoint — visually wrong and not a standalone character

'hello👋🏽'.lastChars(1);
// Grapheme-based: takes last 1 grapheme = '👋🏽' (full emoji with skin tone)
// Correct!
```

---

## Root Cause

```dart
// lib/string/string_extensions.dart ~line 684
String last(int len) {
  if (isEmpty || len <= 0) return '';
  if (len >= runes.length) return this;           // ← rune count, not grapheme count
  final List<int> runeList = runes.toList().sublist(runes.length - len);
  //                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //                         Slice by rune position — splits grapheme clusters!
  return String.fromCharCodes(runeList);
}
```

Compare with `lastChars()` which is correct:

```dart
// lib/string/string_extensions.dart ~line 529
String lastChars(int len) {
  if (isEmpty || len <= 0) return '';
  if (len >= characters.length) return this;      // ← grapheme count ✅
  return characters.takeLast(len).toString();     // ← grapheme-aware slicing ✅
}
```

---

## Impact

- `last()` is a core method likely used throughout applications for displaying previews, truncated text, etc.
- Any string containing combined emoji, letters with diacritics, or other multi-codepoint sequences will produce visually broken or invalid output.
- The inconsistency with `lastChars()` is especially confusing — they appear to do the same thing but behave differently for the same inputs.

---

## Why Both Methods Exist

It's unclear why both `last()` and `lastChars()` exist. If `lastChars()` is grapheme-correct, `last()` should either:
1. Be deprecated in favor of `lastChars()`
2. Be fixed to use grapheme clusters
3. Be clearly documented as "operates on Unicode codepoints, not grapheme clusters"

---

## Suggested Fix

```dart
/// Returns the last [len] grapheme clusters (user-perceived characters) of this string.
///
/// Uses the `characters` package for proper Unicode grapheme cluster support,
/// correctly handling emoji, diacritics, and other multi-codepoint sequences.
///
/// Example:
/// ```dart
/// 'hello👋🏽'.last(1); // '👋🏽' — full emoji with skin tone
/// 'hello'.last(3);     // 'llo'
/// ```
String last(int len) {
  if (isEmpty || len <= 0) return '';
  if (len >= characters.length) return this;
  return characters.takeLast(len).toString();
}
```

---

## Missing Tests

No existing test uses multi-codepoint emoji for `last()`:

```dart
group('last() - grapheme cluster correctness', () {
  test('simple ASCII returns correct chars', () {
    expect('hello'.last(3), equals('llo'));
  });

  test('family emoji is one grapheme cluster', () {
    expect('ab👨‍👩‍👧‍👦'.last(1), equals('👨‍👩‍👧‍👦')); // full family emoji
  });

  test('skin-tone modifier emoji stays together', () {
    expect('hello👋🏽'.last(1), equals('👋🏽')); // waving hand + skin tone
  });

  test('flag emoji stays together', () {
    expect('hi🇺🇸'.last(1), equals('🇺🇸')); // flag = 2 regional indicators
  });

  test('last() and lastChars() return same result', () {
    const s = 'test👨‍👩‍👧‍👦hello';
    for (int i = 1; i <= 5; i++) {
      expect(s.last(i), equals(s.lastChars(i)),
          reason: 'last($i) should equal lastChars($i)');
    }
  });
});
```
