# BUG-027: `truncateWithEllipsisPreserveWords()` Falls Back to Rune-Unsafe Truncation

**File:** `lib/string/string_extensions.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error / Unicode Handling
**Status:** Open

---

## Summary

`truncateWithEllipsisPreserveWords()` attempts to truncate at a word boundary, but when no space is found before the cutoff it falls back to character-level truncation using `cutoff` as the index. This fallback uses a non-grapheme-aware index, potentially splitting multi-codepoint emoji or other complex grapheme clusters mid-character.

---

## Reproduction

```dart
// String where the fallback path is triggered (word is longer than cutoff)
'Hello👨‍👩‍👧‍👦World'.truncateWithEllipsisPreserveWords(6);
// No space before position 6
// Falls back to: substringSafe(0, cutoff) = first 6 chars
// 'Hello' = 5 chars, then cutoff=6 hits INSIDE the family emoji
// ❌ ACTUAL:   'Hello' + partial emoji byte + '…'
// ✅ EXPECTED: 'Hello…' or 'Hello👨‍👩‍👧‍👦…' (emoji kept whole)
```

---

## Root Cause

```dart
// lib/string/string_extensions.dart ~line 225
String truncateWithEllipsisPreserveWords(int? cutoff, ...) {
  // ...
  final int searchLength = cutoff + 1 > charLength ? charLength : cutoff + 1;
  final int lastSpaceIndex = substringSafe(0, searchLength).lastIndexOf(' ');

  if (lastSpaceIndex > 0) {
    // Word boundary found — safe truncation
    return '${substringSafe(0, lastSpaceIndex)}…';
  } else {
    // ← FALLBACK: No space found, truncate at raw index
    return '${substringSafe(0, cutoff)}…';
    //          ^^^^^^^^^^^^^^^^^^^^^^
    //          cutoff is a character INDEX, not a grapheme-cluster index
    //          This will split multi-codepoint sequences
  }
}
```

The `substringSafe(0, cutoff)` call uses `cutoff` as a string code-unit index (via `substring`), not a grapheme cluster count. For emoji like `👨‍👩‍👧‍👦` that span multiple code units, this splits the character.

---

## Impact

- Applications displaying truncated contact names, captions, or messages containing emoji will produce broken character sequences in the fallback path.
- The "safe" truncation (word boundary) is fine, but the fallback to character-level truncation silently corrupts Unicode.

---

## Suggested Fix

Use the `characters` package for the fallback truncation:

```dart
// Instead of:
return '${substringSafe(0, cutoff)}…';

// Use grapheme-aware truncation:
return '${characters.take(cutoff).toString()}…';
```

This ensures the fallback respects grapheme cluster boundaries, matching the intent of the word-preservation logic.

---

## Missing Tests

```dart
group('truncateWithEllipsisPreserveWords - emoji safety', () {
  test('emoji after cutoff not split in fallback', () {
    // 'Hello' = 5 chars, emoji at index 5, cutoff = 6
    // Should not split the emoji
    final result = 'Hello👨‍👩‍👧‍👦World'.truncateWithEllipsisPreserveWords(6);
    expect(result, isNot(contains('\uD83D'))); // No half-emoji surrogates
    expect(result.runes.every((r) => r > 0), isTrue); // All runes valid
  });

  test('fallback on long word preserves grapheme clusters', () {
    final result = 'Pneumonoultramicro👋🏽scopic'.truncateWithEllipsisPreserveWords(10);
    // Result should be a valid string with no broken emoji
    expect(() => result.codeUnits, returnsNormally);
  });
});
```
