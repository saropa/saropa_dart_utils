# ENH-005: nullable-aware string comparator + null-positioned sort helper

**File (target):** `lib/string/string_lower_extensions.dart` (or a new `lib/string/string_compare_extensions.dart`)
**Type:** Enhancement / Missing Utility
**Severity:** 🟡 Medium
**Status:** Fixed

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

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension.

**What shipped:** New file `lib/string/string_compare_extensions.dart` with `extension StringNullableCompareExtensions on String?` exposing `compareStringNullable(String? other, {bool caseSensitive = false, bool nullsLast = false})`. Exported from the barrel `lib/saropa_dart_utils.dart`.

**Design — mirrors `compareDateTimeNullable`:**
- Default null convention is **null-before-non-null**, exactly like the DateTime sibling, so the two read consistently.
- `caseSensitive` defaults to `false` (lowercased compare), matching the consumer's `sort_utils.dart` default.
- `nullsLast` added per the bug to let the caller flip null positioning without inverting the whole comparator.
- Non-null comparison is `String.compareTo` (UTF-16 code unit). Documented explicitly that this is NOT locale collation — `'z' < 'é'` — so a reader doesn't expect alphabetic diacritic ordering.

**Tests (Section 4):**
- Audit: no existing test referenced `compareStringNullable` (brand-new symbol); grepped `test/` to confirm. The barrel change only adds an export, so no existing barrel-consumer test breaks (verified `dart analyze` clean on `saropa_dart_utils.dart`).
- New `test/string/string_compare_extensions_test.dart`, 12 cases: both-null, null-first/last each direction, two-nulls-with-nullsLast, case-insensitive equality + ordering, case-sensitive code-unit ordering, identical strings, diacritic code-unit ordering, and two end-to-end `List<String?>.sort` cases (nulls-first and nulls-last).
- Ran `flutter test test/string/string_compare_extensions_test.dart` → **All 12 tests passed**.
- Ran `dart analyze` on the new file, its test, and the barrel → **No issues found**.

**Maintenance:** CHANGELOG 1.4.1 Added section updated. CODEBASE_INDEX gained a row for the new file (new file = index update required, unlike the prior method-on-existing-file ENHs). README verified — no updates needed.

**Dependency note:** Same `saropa_lints ^13.12.5` situation; committed pubspec keeps `^13.12.5`, local runs use `^13.12.3`.

**Outstanding:** None for ENH-005.
