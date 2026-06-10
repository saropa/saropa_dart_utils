# Implement 5 useful utils

Five net-new utilities were added. `ROADMAP_TO_400.md`'s "Done" column is stale (most "TODO" rows already have implementations, e.g. `takeEveryNth`, `rotate`, `minBy`/`maxBy`, top-k heap, seeded shuffle), so each candidate was confirmed genuinely absent via repo-wide grep first. None of the five corresponds to an open `ROADMAP_TO_400.md` row — they are adjacent to but distinct from existing entries (e.g. roadmap #135 sums an `Iterable<num>`; `sumBy` reduces any element type by a selector).

## Finish Report (2026-06-10)

### Scope

(A) Dart library code (`lib/`) + tests (`test/`) + tracking docs (CHANGELOG, CODE_INDEX). No Flutter UI, no extension, no l10n.

### What shipped

Five new, independently-importable, tree-shakeable files (one feature per file, no global state), each with dartdoc explaining the WHY/failure-mode, plus a dedicated test file:

| Utility | lib file | test file |
|---|---|---|
| `Iterable<T>.none(predicate)` | `lib/iterable/iterable_none_extensions.dart` | `test/iterable/iterable_none_extensions_test.dart` |
| `Iterable<T>.mapNotNull(selector)` + `Iterable<T?>.whereNotNull()` | `lib/iterable/iterable_map_not_null_extensions.dart` | `test/iterable/iterable_map_not_null_extensions_test.dart` |
| `Iterable<T>.sumBy(selector)` + `averageBy(selector)` | `lib/iterable/iterable_sum_by_extensions.dart` | `test/iterable/iterable_sum_by_extensions_test.dart` |
| `String.truncateMiddle(maxLength, {ellipsis})` | `lib/string/string_truncate_middle_extensions.dart` | `test/string/string_truncate_middle_extensions_test.dart` |
| `double.isCloseTo(other, {relativeTolerance, absoluteTolerance})` | `lib/double/double_close_to_extensions.dart` | `test/double/double_close_to_extensions_test.dart` |

### Core logic notes for the Reviewer

- **`none`**: `for` loop, short-circuits on first match, returns `true` for empty (vacuous truth, matching `every`). Reuses the existing `ElementPredicate<T>` typedef from `iterable_extensions.dart`.
- **`mapNotNull`/`whereNotNull`**: `sync*` generators (lazy). `whereNotNull` is on `Iterable<T?>` with `T extends Object` so the non-nullable type is recovered without a cast.
- **`sumBy`/`averageBy`**: single pass. `sumBy` returns `0` for empty; `averageBy` returns `double?` (`null` for empty) to avoid silent `NaN` from divide-by-zero.
- **`truncateMiddle`**: grapheme-cluster safe via `package:characters` (`take`/`takeLast` on `Characters`), so emoji/combining marks are never split. Budget = `maxLength` total incl. ellipsis; odd leftover biases to the front. Degrades to a leading hard cut (no ellipsis) when `maxLength` is too small to hold ellipsis + one cluster per side, so the result never exceeds `maxLength`. Returns input unchanged for null/non-positive/already-fits.
- **`isCloseTo`**: combines an absolute floor (`absoluteTolerance`, meaningful near 0 where a relative tolerance collapses) with a relative tolerance scaled by `max(|a|,|b|)`. Early `==` return covers same-sign infinity without computing `inf-inf` (which would be `NaN`); `NaN`/remaining-infinity short-circuit to `false`.

### Step results

- **Deep review (3):** Logic/safety clean — no recursion, no async, no shared mutable state; all new files are pure functions/extensions. No duplication: confirmed via grep that none of the five symbols pre-existed. Each value lives in one place. No out-of-scope refactor opportunities pursued.
- **Testing (4A):** The only shared file touched is the barrel `lib/saropa_dart_utils.dart` (3 export-line additions). New symbol names (`none`, `mapNotNull`, `whereNotNull`, `sumBy`, `averageBy`, `truncateMiddle`, `isCloseTo`) were grepped repo-wide before implementation and did not previously exist, so no existing test pinned them and no extension-member ambiguity is introduced. Verified by a full analyze (clean) + full affected-suite run.
- **Testing (4B):** 4 new test files, 38 new tests, covering happy path, empty, null, negatives, laziness, custom-ellipsis, grapheme integrity, NaN/infinity, and tolerance edges.
- **l10n (5):** SKIPPED [A-NOT-IN-SCOPE] — pure Dart utility library, no user-facing strings, no ARB.
- **Maintenance (6):** CHANGELOG `[Unreleased] → Added` updated (5 bullets). CODE_INDEX.md updated (4 new rows). README verified — no updates needed (README does not enumerate every method). Roadmap: the five additions do not map to open `ROADMAP_TO_400.md` rows; no rows flipped.
- **Bug archival:** No bug archive — task did not close a `bugs/*.md` file.

### Verification commands

- `dart analyze` → **No issues found!** (whole package)
- `flutter test test/iterable test/double test/string` → **2323 passed** (includes the 38 new tests)
