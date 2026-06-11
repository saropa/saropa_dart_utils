# ENH-003: `Iterable<String>.joinDisplayList(...)` — human-readable Oxford-comma join

**File (target):** `lib/list/list_string_extensions.dart`
**Type:** Enhancement / Missing Utility
**Severity:** 🟡 Medium
**Status:** Fixed

---

## Summary

`join()` produces `a, b, c`; there is no helper for the natural-language form
`a, b, and c` (or `a and b` for two items) with de-duplication and empty-trimming.
This is a common UI/display need ("shared with Alice, Bob, and Carol").

---

## Absence Evidence

```bash
grep -rn "joinDisplayList" ../saropa_dart_utils/lib/
# (no matches in 1.3.0)
```

## Use Case (consumer's local implementation)

Saropa Contacts (`lib/utils/primitive/string/string_list_utils.dart`) — note it is
already built **on top of** library primitives (`toUnique`, `takeSafe`, `nullIfEmpty`),
so it is a natural fit to absorb upstream:

```dart
String? joinDisplayList({
  String joiner = ', ',
  String doubleJoiner = ' and ',
  String lastJoiner = ', and ',   // Oxford comma
  bool isUnique = true,
}) {
  final List<String>? list = isUnique ? removeTrimmedEmpty()?.toUnique() : removeTrimmedEmpty();
  if (list == null || list.isEmpty) return null;
  if (list.length == 1) return list.firstOrNull;
  if (list.length == 2) return '${list.first}$doubleJoiner${list.last}';
  return list.takeSafe(list.length - 1).join(joiner) + lastJoiner + list.last;
}
```

## Suggested API

Add to the existing `List<String>` / `Iterable<String>` extension, with the joiners
as named params (defaults as above) so locale/style is caller-controlled. Reuse the
existing `toUnique` / `nullIfEmpty` internally. Returns `null` for an effectively-empty
input (distinct from `''`).

## Missing Tests

- 0 / 1 / 2 / 3+ items; duplicates with `isUnique` true/false; entries that are empty or
  whitespace-only (trimmed out); custom joiners; null-vs-empty return contract.

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `string_list_utils.dart`

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension.

**What shipped:** Added `List<String>.joinDisplayList({joiner, doubleJoiner, lastJoiner, isUnique})` to `ListStringExtensions`, returning `String?`.

**Implementation notes:**
- Placed on the existing `List<String>` extension (not a new `Iterable<String>` one) — the bug's title says `Iterable<String>` but the consumer and the existing sibling methods (`commonPrefix`/`commonSuffix`) are `List<String>`, and the impl needs indexed/`takeSafe` access. `List` is the right receiver.
- Reused library primitives per the bug: `toUnique()` for de-dup, `takeSafe(length-1)` for the lead slice. Added imports for `list_extensions.dart` (`takeSafe`) and `unique_list_extensions.dart` (`toUnique`).
- `removeTrimmedEmpty()` from the consumer does NOT exist in this library, so the trim-and-drop-blank step is inlined as a collection-`for` (`if (s.trim().isNotEmpty) s.trim()`). Entries are trimmed in the output, matching display intent.
- `.first`/`.last` are reached only after an explicit length check on the same list, so emptiness is proven inline (commented). No unguarded throwing accessor on an unproven collection.
- Returns `null` (not `''`) for effectively-empty input, preserving the consumer's null-vs-empty contract.

**Tests (Section 4):**
- Audit: grepped `test/list/list_string_extensions_test.dart` — only `commonPrefix`/`commonSuffix` groups existed; nothing pinned `joinDisplayList`. No regressions possible.
- Added an 11-case `joinDisplayList` group: empty→null, 1/2/3-item shapes, dedup on/off, trim+drop-blank, collapse-to-one, all-blank→null, custom joiners, custom double joiner.
- Ran `flutter test test/list/list_string_extensions_test.dart` → **All 16 tests passed**.
- Ran `dart analyze` on both files → **No issues found**.

**Maintenance:** CHANGELOG 1.4.0 Added section updated. CODEBASE_INDEX lists the file already. README verified — no updates needed.

**Dependency note:** Same uncommitted `saropa_lints ^13.12.5` (unpublished) pubspec bump; pinned locally to `^13.12.3` to run tests, left out of the commit.

**Outstanding:** None for ENH-003.
