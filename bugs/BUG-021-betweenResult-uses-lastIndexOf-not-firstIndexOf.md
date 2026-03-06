# BUG-021: `betweenResult()` Returns Outermost Match Instead of First Match — Unexpected Behavior

**File:** `lib/string/string_search_extensions.dart`
**Severity:** 🟡 Medium
**Category:** Logic Error / Unexpected Behavior
**Status:** Open

---

## Summary

`betweenResult()` (and the underlying `between()`) uses `indexOf()` for the start delimiter but `lastIndexOf()` for the end delimiter. This means it returns the content between the **first** opening delimiter and the **last** closing delimiter — not the first balanced pair. Most callers expect the first balanced pair to be returned.

---

## Reproduction

```dart
'(first) (second)'.betweenResult('(', ')');
// ❌ ACTUAL:   ('first) (second', null)  — from first '(' to last ')'
// ✅ EXPECTED: ('first', '(second)')      — first balanced pair

'<b>bold</b> and <i>italic</i>'.betweenResult('<', '>');
// ❌ ACTUAL:   ('b>bold</b> and <i>italic</i', null)
// ✅ EXPECTED: ('b', '</b> and <i>italic</i>')
```

---

## Root Cause

```dart
// lib/string/string_search_extensions.dart ~line 87
// (Or in string_between_extensions.dart — the underlying between method)
final int startIndex = indexOf(start);
// ...
final int endIndex = lastIndexOf(end, ...);
//                   ^^^^^^^^^^^
//                   Uses LAST occurrence of end delimiter, not first after start
```

This was likely an intentional design choice for some use cases (like extracting content from outermost wrapper), but it creates an inconsistency with how `between()` and similar methods typically work in string utilities.

---

## Impact

- Any code extracting content from templated strings like `"prefix(content)suffix"` expecting the first match will get wrong results for multiple occurrences.
- Parsing HTML attribute values, template tokens, or parenthetical expressions fails for multi-occurrence inputs.
- The test at `test/string/string_search_extensions_test.dart` line 181 actually **tests the wrong expected value** — it asserts `'first) (second'` is the expected result, locking in the surprising behavior without documenting it.

---

## Existing Test Confirms the Bug (Not a Feature)

```dart
// test/string/string_search_extensions_test.dart ~line 181
test('7. Multiple delimiters', () {
  final (String, String?)? result = '(first) (second)'.betweenResult('(', ')');
  expect(result?.$1, 'first) (second'); // ← Tests the surprising behavior as correct!
});
```

The test name says "Multiple delimiters" but doesn't explain WHY `lastIndexOf` is used. A comment explaining the design intent is missing.

---

## Two Valid Approaches

### Option A: Fix to use `indexOf` for end delimiter (first balanced pair)

```dart
final int endIndex = indexOf(end, startIndex + start.length);
// Returns 'first' for '(first) (second)'
```

### Option B: Keep `lastIndexOf` but document it clearly as "outermost match"

```dart
/// Returns the content between the FIRST occurrence of [start] and the
/// LAST occurrence of [end] (outermost match). For innermost/first-match
/// behavior, use [betweenFirst].
```

Option B is the safest for a public library (no breaking change), but requires adding a new `betweenFirst()` method and clear documentation.

---

## Suggested Fix (Non-Breaking — Option B)

Add a new method and document the existing behavior:

```dart
/// Returns the content between the first [start] and the first [end] after it
/// (first balanced pair). See also [between] which uses the last [end].
String? betweenFirst(String start, String end, {bool trim = true}) {
  final int startIndex = indexOf(start);
  if (startIndex == -1) return null;
  final int endIndex = indexOf(end, startIndex + start.length); // first, not last
  if (endIndex == -1) return null;
  final String result = substring(startIndex + start.length, endIndex);
  return trim ? result.trim() : result;
}
```

---

## Missing Tests

```dart
group('betweenResult - multiple delimiters behavior', () {
  test('documents that lastIndexOf is used for end (outermost match)', () {
    // This test documents the CURRENT behavior (not necessarily desired)
    final result = '(first) (second)'.betweenResult('(', ')');
    expect(result?.$1, equals('first) (second'),
        reason: 'Uses lastIndexOf for end delimiter — outermost match');
  });

  // Test for new betweenFirst method (if added):
  test('betweenFirst returns first balanced pair', () {
    expect('(first) (second)'.betweenFirst('(', ')'), equals('first'));
  });

  test('betweenFirst with HTML-like content', () {
    expect('<b>bold</b><i>italic</i>'.betweenFirst('<', '>'), equals('b'));
  });
});
```
