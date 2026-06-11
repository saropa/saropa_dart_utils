# ENH-001: `String.removeLastChars(int count)` — add trailing-character trim

**File (target):** `lib/string/string_manipulation_extensions.dart`
**Type:** Enhancement / Missing Utility
**Severity:** 🟢 Low
**Status:** Open

---

## Summary

There is no extension to drop the last *N* characters of a string. `String`
has `substring`, and the library has `removeNonAlphaNumeric` / `removeNonNumbers`,
but no bounds-safe "remove last N" helper. Consumers hand-roll it.

---

## Absence Evidence

```bash
grep -rn "removeLastChars" ../saropa_dart_utils/lib/
# (no matches in 1.3.0)
```

## Use Case (consumer's local implementation)

Saropa Contacts carries this in `lib/utils/primitive/string/string_utils_local.dart`:

```dart
String removeLastChars(int len) {
  if (len <= 0) return this;
  if (length <= len) return '';
  return substring(0, length - len);
}
```

Bounds-safe (negative/zero is a no-op, over-length returns empty rather than
throwing). The library counterpart should be grapheme-aware or at least document
that it counts UTF-16 code units like `String.length`.

## Suggested API

```dart
extension StringManipulationExtensions on String {
  /// Returns this string with the last [count] characters removed.
  /// [count] <= 0 is a no-op; [count] >= length returns ''.
  String removeLastChars(int count) {
    if (count <= 0) return this;
    if (length <= count) return '';
    return substring(0, length - count);
  }
}
```

## Missing Tests

- `''`, `count = 0`, `count` negative, `count == length`, `count > length`.
- Unicode / emoji (document code-unit vs grapheme behavior, see guide pitfalls).

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `string_utils_local.dart`
