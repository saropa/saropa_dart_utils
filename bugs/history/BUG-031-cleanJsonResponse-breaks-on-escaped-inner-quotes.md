# BUG-031: `cleanJsonResponse()` Breaks on Strings with Escaped Inner Quotes

**File:** `lib/json/json_utils.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error
**Status:** Open

---

## Summary

`cleanJsonResponse()` strips escaped quote sequences (`\"`) then applies a pattern match for outer quotes. When the input contains escaped inner quotes (a valid JSON string like `"hello \"world\""`), the unescaping step corrupts the string before the pattern match, causing the method to fail or return the wrong content.

---

## Reproduction

```dart
// A JSON-encoded string with escaped inner quotes
final input = '"hello \\"world\\""';  // Represents: "hello \"world\""

// Step 1: replaceAll(r'\"', '"')
// Input:  "hello \"world\""
// After:  "hello "world""      ← now has unmatched inner quotes

// Step 2: _jsonStringPattern.hasMatch(clean)
// Pattern matches "..." (entire string in outer quotes)
// But "hello "world"" has multiple quote pairs — pattern fails!

final result = JsonUtils.cleanJsonResponse(input);
// ❌ ACTUAL:   Returns the whole mangled string (no outer quote stripping)
// ✅ EXPECTED: Returns 'hello "world"' (inner quotes preserved)
```

---

## Root Cause

```dart
// lib/json/json_utils.dart ~line 87
static String? cleanJsonResponse(String? value) {
  if (value == null || value.isEmpty) return null;
  final String clean = value.replaceAll(r'\"', '"');
  //                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //                   Replaces ALL escaped quotes, including inner ones
  //                   This breaks the structure before pattern matching

  if (clean.isEmpty) return null;
  if (_jsonStringPattern.hasMatch(clean)) {
    return clean.substringSafe(1, clean.length - 1);
    // Now 'clean' may have unbalanced quotes — this might strip wrong chars
  }
  return clean;
}
```

The order of operations is wrong:

1. All `\"` are converted to `"` (both outer wrapper quotes and inner content quotes)
2. Then the pattern tries to match the outer `"..."` wrapper
3. But inner quotes now look like outer quotes — pattern may not match

---

## Impact

- API responses that include JSON strings with escaped quotes (common in LLM responses, serialized JSON, etc.) will be returned incorrectly.
- The method is supposed to handle "JSON string cleanup" but corrupts valid inputs with inner escaped quotes.

---

## Example API Response that Fails

This is a common pattern from REST APIs and LLM responses:

```
"Hello, I said \"goodbye\" to them."
```

After the buggy `replaceAll`:

```
"Hello, I said "goodbye" to them."
```

The pattern `^".*"$` won't match this because `"goodbye"` creates a perceived inner string boundary.

---

## Suggested Fix

Process the outer quotes properly without destroying the inner escaped quotes:

```dart
static String? cleanJsonResponse(String? value) {
  if (value == null || value.isEmpty) return null;

  final String trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  // Check if wrapped in outer double quotes
  if (trimmed.startsWith('"') && trimmed.endsWith('"') && trimmed.length >= 2) {
    // Strip outer quotes, then unescape inner quotes
    final String inner = trimmed.substring(1, trimmed.length - 1);

    return inner.replaceAll(r'\"', '"');
  }

  // No outer quotes — just unescape any escaped quotes
  return trimmed.replaceAll(r'\"', '"').nullIfEmpty();
}
```

This correctly:

1. Detects outer quotes first (before destroying inner ones)
2. Strips outer quotes
3. Then unescapes inner `\"` → `"`

---

## Missing Tests

```dart
group('cleanJsonResponse', () {
  test('simple quoted string', () {
    expect(JsonUtils.cleanJsonResponse('"hello"'), equals('hello'));
  });

  test('string with escaped inner quotes', () {
    expect(
      JsonUtils.cleanJsonResponse('"hello \\"world\\""'),
      equals('hello "world"'),
    );
  });

  test('unquoted string returned as-is', () {
    expect(JsonUtils.cleanJsonResponse('hello'), equals('hello'));
  });

  test('empty string returns null', () {
    expect(JsonUtils.cleanJsonResponse('""'), isNull); // or '' depending on design
  });

  test('json with escaped backslash', () {
    expect(
      JsonUtils.cleanJsonResponse('"path\\\\to\\\\file"'),
      equals('path\\to\\file'),
    );
  });
});
```
