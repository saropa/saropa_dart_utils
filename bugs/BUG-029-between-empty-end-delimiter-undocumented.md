# BUG-029: `between()` Empty End Delimiter Has Undocumented Behavior

**File:** `lib/string/string_between_extensions.dart`
**Severity:** 🟢 Low
**Category:** Documentation / Edge Case
**Status:** Open

---

## Summary

`between(start, end)` contains special handling for when `end` is an empty string — it treats empty `end` as `-1` (not found), which then triggers the `endOptional` path and returns everything from `start` to end-of-string. This is neither documented nor intuitive. Callers passing `''` as `end` get a very different result than callers passing a non-matching delimiter.

---

## Reproduction

```dart
// Empty end delimiter — triggers special path
'Hello World'.between('Hello ', '');
// endIndex = (end.isEmpty ? -1 : indexOf('', ...))
// endIndex = -1 → endOptional path → returns 'World' (everything after 'Hello ')

// Non-matching delimiter
'Hello World'.between('Hello ', 'NOMATCH');
// Returns null (endOptional=false default) or 'World' (endOptional=true)
// Different behavior!

// The two cases have different semantics:
'Hello World'.between('Hello ', '', endOptional: false);
// ??? What should happen — end is '' so endOptional doesn't apply?
// Current: returns 'World' (empty end treated as absent, then endOptional kicks in)
```

---

## Root Cause

```dart
// lib/string/string_between_extensions.dart ~line 145
final int endIndex = end.isEmpty ? -1 : indexOf(end, startIndex + start.length);
//                   ^^^^^^^^^^^^
//                   Empty end → treated as "end not found"
//                   Then falls into the endOptional logic:

if (endIndex == -1) {
  if (endOptional) {
    return substringSafe(startIndex + start.length); // Everything after start
  }
  return null;
}
```

---

## Impact

- Callers who accidentally pass an empty string as `end` (e.g., from a variable that might be empty) will get the entire tail of the string instead of null or an error.
- The behavior is surprising: "find content between 'Hello ' and nothing" returns everything after "Hello " rather than failing.
- This undocumented shortcut could be useful, but only if explicitly designed and documented.

---

## Suggested Fix

Option A: Guard against empty `end`:
```dart
/// [end] must be non-empty. If [end] is empty, returns null.
String? between(String start, String end, {bool endOptional = false, bool trim = true}) {
  if (start.isEmpty && end.isEmpty) return null;
  // ...
  if (end.isEmpty) return null; // Don't treat empty end as "not found"
```

Option B: Document the current behavior clearly:
```dart
/// Returns the substring between [start] and [end].
///
/// If [end] is empty string, behaves as if [end] was not found —
/// when [endOptional] is `true`, returns everything after [start].
/// When [endOptional] is `false` (default), returns null.
```

---

## Missing Tests

```dart
group('between - empty delimiter edge cases', () {
  test('empty end with endOptional:false returns null', () {
    expect('Hello World'.between('Hello ', '', endOptional: false), isNull);
  });

  test('empty end with endOptional:true returns everything after start', () {
    expect('Hello World'.between('Hello ', '', endOptional: true), equals('World'));
  });

  test('empty start and empty end returns null', () {
    expect('Hello World'.between('', ''), isNull);
  });

  test('empty start returns null (or documented behavior)', () {
    // What happens when start is also empty?
    expect('Hello World'.between('', 'World'), isNotNull);
  });
});
```
