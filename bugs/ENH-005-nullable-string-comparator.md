# ENH-005: nullable-aware string comparator + null-positioned sort helper

**File (target):** `lib/string/string_lower_extensions.dart` (or a new `lib/string/string_compare_extensions.dart`)
**Type:** Enhancement / Missing Utility
**Severity:** 🟡 Medium
**Status:** Open

---

## Summary

There is a `compareDateTimeNullable` for `DateTime?` but no equivalent for `String?`.
Sorting a `List<String?>` (or sorting objects by a nullable string field) requires a
comparator that (a) tolerates nulls without throwing and (b) lets the caller decide
case-sensitivity and where nulls land. `naturalCompare` exists but assumes non-null
inputs and does not address null positioning.

---

## Absence Evidence

```bash
grep -rnE "compareStringNullable|compareNullableStrings" ../saropa_dart_utils/lib/
# (no matches in 1.3.0 — only compareDateTimeNullable exists, for DateTime?)
```

## Use Case (consumer's local implementation)

Saropa Contacts (`lib/utils/primitive/sort/sort_utils.dart`):

```dart
int compareNullableStringsForSort(String? a, String? b, {bool caseSensitive = false}) {
  if (!caseSensitive) {
    return (a?.toLowerCase() ?? '').compareTo(b?.toLowerCase() ?? '');
  }
  // explicit null handling: null sorts before non-null
  ...
}
```

## Suggested API

Mirror `compareDateTimeNullable`'s shape and null-before-non-null convention, plus a
`caseSensitive` flag and an optional `nullsLast`:

```dart
extension StringNullableCompareExtensions on String? {
  int compareStringNullable(
    String? other, {
    bool caseSensitive = false,
    bool nullsLast = false,
  }) { ... }
}
```

Document the null-position convention explicitly (the `DateTime?` one puts null first).

## Missing Tests

- both null (0); one null each way with `nullsLast` true/false; case-sensitive vs
  case-insensitive ordering; equal strings; diacritics.

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `sort_utils.dart`
