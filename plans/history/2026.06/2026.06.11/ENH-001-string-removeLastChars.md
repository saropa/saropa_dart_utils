# ENH-001: `String.removeLastChars(int count)` — add trailing-character trim

**File (target):** `lib/string/string_manipulation_extensions.dart`
**Type:** Enhancement / Missing Utility
**Severity:** 🟢 Low
**Status:** Fixed

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

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension.

**What shipped:** Added `String.removeLastChars(int count)` to `StringManipulationExtensions`, generalizing the existing single-char `removeLastChar()`. Bounds-safe per the bug spec: `count <= 0` is a no-op, `count >= length` returns `''`, otherwise `substringSafe(0, length - count)`.

**Implementation notes:**
- Used the codebase idiom `substringSafe` (consistent with the rest of the extension) rather than the raw `substring` in the bug's suggested snippet; behavior is identical given the guards.
- `@useResult` annotation matches every sibling method.
- Documented that it counts UTF-16 code units like `String.length`, not graphemes (the bug explicitly asked for this to be documented).

**Tests (Section 4):**
- Audit: grepped `test/string/string_manipulation_extensions_test.dart` for `removeLastChar` — the existing `removeLastChar`/`removeFirstChar` group does not assert on `removeLastChars`, so nothing pre-existing broke.
- Added a 7-case `removeLastChars` group: drop N, count 0 no-op, negative no-op, count == length → '', count > length → '', empty string → '', and a UTF-16-vs-grapheme case (`'a😀'.removeLastChars(2) == 'a'`).
- Ran `flutter test test/string/string_manipulation_extensions_test.dart` → **All 81 tests passed**.
- Ran `dart analyze` → **No issues found**.

**Maintenance:** CHANGELOG 1.4.0 (untagged/unreleased) Added section updated. CODEBASE_INDEX already lists `string_manipulation_extensions.dart` (file-level index, not per-method) — no index change needed. README verified — no updates needed (no curated per-method README list for this file).

**Dependency note:** `pubspec.yaml` carried an uncommitted bump to `saropa_lints ^13.12.5`, which is unpublished (lock + pub.dev top out at 13.12.3), so the whole test suite could not resolve. Pinned to `^13.12.3` to run tests. This is NOT part of ENH-001 and is left out of the ENH-001 commit.

**Outstanding:** None for ENH-001.
