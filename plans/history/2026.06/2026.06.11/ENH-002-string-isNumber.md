# ENH-002: `String.isNumber` — add integer-string predicate

**File (target):** `lib/string/string_number_extensions.dart`
**Type:** Enhancement / Missing Utility
**Severity:** 🟢 Low
**Status:** Fixed

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

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension.

**What shipped:** Added the `String.isNumber` getter to `StringNumberExtensions` (`int.tryParse(this) != null`).

**Design decision — did NOT add the suggested sibling `isNumeric`:** the file already has `bool isNumeric()` (a `double.tryParse` predicate that accepts decimals/scientific notation). The bug's suggested "sibling `isNumeric` accepting a decimal point" already exists by that exact name. Adding a second one would collide. So the int-only `isNumber` is the only new symbol; its dartdoc explicitly contrasts it with the existing `isNumeric()` so the int-vs-numeric distinction is documented.

**Behavior verified against the real `int.tryParse` (ran a probe), corrected two dartdoc claims from the bug's assumptions:**
- `'0x1F'` → `true` (hex prefix IS accepted).
- `' 42 '` → `true` (surrounding whitespace IS trimmed — the bug's test list implied it might not be).
- `'98765432109876543210'` → `false` on the native VM (overflows int64). Documented the web-vs-native difference.
- `'4.2'`, `'1e3'`, `''`, `'   '`, `'123a'` → `false`.

**Tests (Section 4):**
- Audit: grepped the test file for `isNumber` / `isNumeric` — the existing `isNumeric` group (10 cases) is untouched and still passes; no assertion pinned `isNumber`.
- Added an 11-case `isNumber` group covering int, negative, leading-plus, hex, trimmed-whitespace, decimal, scientific, empty, whitespace-only, letters, and out-of-range.
- Ran `flutter test test/string/string_number_extensions_test.dart` → **All 43 tests passed**.
- Ran `dart analyze` on both files → **No issues found**.

**Maintenance:** CHANGELOG 1.4.0 Added section updated. CODEBASE_INDEX lists the file already (file-level). README verified — no updates needed.

**Dependency note:** Same uncommitted `saropa_lints ^13.12.5` (unpublished) pubspec bump as ENH-001; pinned locally to `^13.12.3` to run tests, left out of the commit.

**Outstanding:** None for ENH-002.
