# ENH-002: `String.isNumber` — add integer-string predicate

**File (target):** `lib/string/string_number_extensions.dart`
**Type:** Enhancement / Missing Utility
**Severity:** 🟢 Low
**Status:** Open

---

## Summary

No getter answers "is this string a parseable integer?". `string_number_extensions.dart`
has numeric *conversion* helpers but no boolean `isNumber` / `isInteger` predicate,
so consumers write `int.tryParse(s) != null` inline.

---

## Absence Evidence

```bash
grep -rnE "\bisNumber\b|\bisInteger\b" ../saropa_dart_utils/lib/string/
# (no matches in 1.3.0)
```

## Use Case (consumer's local implementation)

`lib/utils/primitive/string/string_utils_local.dart`:

```dart
bool get isNumber => int.tryParse(this) != null;
```

## Suggested API

```dart
extension StringNumberExtensions on String {
  /// True if this string parses as an integer via [int.tryParse].
  bool get isNumber => int.tryParse(this) != null;
}
```

Consider a sibling `isNumeric` (accepts a decimal point, via `num.tryParse`) so the
int-only vs numeric distinction is explicit and documented.

## Missing Tests

- `'42'` true; `'4.2'` false (for `isNumber`); `''`, `'  '`, `'1e3'`, `'-7'`, `'0x1F'`,
  leading/trailing whitespace, very large values (scientific-notation pitfall).

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `string_utils_local.dart`
