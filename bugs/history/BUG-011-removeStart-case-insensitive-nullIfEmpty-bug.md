# BUG-011: `removeStart()` Returns Null Instead of Original String on Case-Insensitive Non-Match

**File:** `lib/string/string_extensions.dart`
**Severity:** 🔴 High
**Category:** Logic Error
**Status:** Open

---

## Summary

In `removeStart()`, the case-insensitive code path calls `nullIfEmpty()` on `this` when the prefix doesn't match. This converts any non-empty string to itself... but any empty string (or whitespace-only string after trim) to `null`. This is inconsistent with the case-sensitive path which returns `this` directly.

---

## Reproduction

```dart
// Case-sensitive (correct behavior)
'HelloWorld'.removeStart('xyz');                      // Returns 'HelloWorld' ✅

// Case-insensitive — no match
'HelloWorld'.removeStart('xyz', isCaseSensitive: false); // Returns 'HelloWorld' ✅ (for non-empty)

// But for whitespace-only strings with case-insensitive non-match:
'   '.removeStart('xyz', isCaseSensitive: false);     // ❌ Returns NULL
'   '.removeStart('xyz');                             // ✅ Returns '   '
```

---

## Root Cause

```dart
// lib/string/string_extensions.dart ~line 327
if (isCaseSensitive) {
  return startsWith(start) ? substringSafe(start.length).nullIfEmpty() : this;
  //                                                                      ^^^^
  //                                                             Returns 'this' directly
}

// Case-insensitive branch:
return toLowerCase().startsWith(start.toLowerCase())
    ? substringSafe(start.length).nullIfEmpty()
    : nullIfEmpty();   // ← BUG: Should be 'this', not 'nullIfEmpty()'
//    ^^^^^^^^^^^
//    Converts '   ' (whitespace) to null!
```

The case-insensitive path was clearly meant to mirror the case-sensitive path, but `this` was accidentally replaced with `nullIfEmpty()`.

---

## Impact

- Any whitespace string (e.g., `'   '`) passed to `removeStart(prefix, isCaseSensitive: false)` where the prefix doesn't match will return `null` instead of the original string.
- Code that relies on `removeStart` for non-matching inputs will silently get `null` instead of the original value, potentially causing null-pointer-like bugs downstream.

---

## Suggested Fix

```dart
// Case-insensitive branch:
return toLowerCase().startsWith(start.toLowerCase())
    ? substringSafe(start.length).nullIfEmpty()
    : this;  // ← Return 'this', not nullIfEmpty()
```

---

## Missing Tests

The test suite for `removeStart` with `isCaseSensitive: false` does NOT cover the non-match path:

```dart
// test/string/string_extensions_test.dart
group('removeStart', () {
  // EXISTING: Case-insensitive match
  test('3. Case insensitive match',
    () => expect('HelloWorld'.removeStart('hello', isCaseSensitive: false), 'World'));

  // MISSING: Case-insensitive non-match
  test('case insensitive no match returns original', () {
    expect('HelloWorld'.removeStart('xyz', isCaseSensitive: false), 'HelloWorld');
  });

  test('case insensitive no match on whitespace returns whitespace', () {
    expect('   '.removeStart('xyz', isCaseSensitive: false), '   ');
  });
});
```
