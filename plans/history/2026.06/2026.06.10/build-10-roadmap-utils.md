# Build the 10 genuinely-outstanding ROADMAP_TO_400 utilities

`ROADMAP_TO_400.md` lists 10 rows confirmed (by repo-wide grep) to have no implementation — distinct from the ~22 TODO-marked rows already implemented but mislabeled in the roadmap's stale "Done" column. These 10 genuinely-absent utilities were built.

## What shipped

10 new tree-shakeable files (one feature per file, top-level functions / extensions, no global state), each with WHY-dartdoc and a dedicated test file.

| # | Utility | lib file | test file |
|---|---|---|---|
| 52 | `nthSmallest` / `nthLargest` (quickselect, median-of-three) | `lib/collections/quickselect_utils.dart` | `test/collections/quickselect_utils_test.dart` |
| 57 | `Iterable.stableSortBy` / `stableSort` | `lib/iterable/iterable_stable_sort_extensions.dart` | `test/iterable/iterable_stable_sort_extensions_test.dart` |
| 69 | `longestCommonSubsequence` / `...Length` | `lib/collections/lcs_sequence_utils.dart` | `test/collections/lcs_sequence_utils_test.dart` |
| 90 | `deepFreeze` | `lib/map/deep_freeze_utils.dart` | `test/map/deep_freeze_utils_test.dart` |
| 157 | `getByJsonPath` | `lib/parsing/json_path_utils.dart` | `test/parsing/json_path_utils_test.dart` |
| 158 | `CronSchedule.tryParse` + `nextRunAfter` | `lib/parsing/cron_utils.dart` | `test/parsing/cron_utils_test.dart` |
| 159 | `parseAcceptLanguage` + `LanguageRange` | `lib/parsing/accept_language_utils.dart` | `test/parsing/accept_language_utils_test.dart` |
| 160 | `parseRangeHeader` + `ByteRange` | `lib/parsing/range_header_utils.dart` | `test/parsing/range_header_utils_test.dart` |
| 175 | `canonicalizeUrl` | `lib/url/url_canonicalize_utils.dart` | `test/url/url_canonicalize_utils_test.dart` |
| 185 | `debounceStream` | `lib/async/stream_debounce_utils.dart` | `test/async/stream_debounce_utils_test.dart` |

## Notable decisions / failure modes addressed

- **quickselect** — median-of-three pivot to avoid the O(n²) worst case on sorted/reverse-sorted input; operates on a copy (no input mutation); returns `null` for out-of-range k.
- **stableSort** — decorate-by-index tie-break, because Dart's `List.sort` is not guaranteed stable (the exact gap roadmap #57 names).
- **LCS** — distinct from the existing contiguous LCS-substring; full table for reconstruction, rolling two-row O(min) variant for length only.
- **deepFreeze** — recursive `unmodifiable` copies of Map/List/Set; it is a copy (later edits to the original do not show through), documented.
- **cron** — Vixie-cron OR semantics for the day-of-month / day-of-week fields (tracked via two `is*Restricted` flags so an expanded `*` is distinguishable from an explicit full range); minute-resolution scan bounded to four years so impossible expressions return `null` instead of looping. DST caveat documented (wall-clock arithmetic; pass UTC for DST-independence).
- **URL canonicalize** — relies on Dart `Uri` already dropping default ports (verified: constructor, parse, and `replace` all drop them; `replace(port: 0)` would WRONGLY emit `:0`). Fragment removed via `removeFragment()` because `replace(fragment: '')` leaves a dangling `#` (both verified by probe).
- **debounceStream** — flushes the trailing pending value on source close and forwards errors immediately (not debounced). Verified the close/done path under the real event loop; `fake_async` does not surface a done event for a controller closed inside a nested `onDone`, so those two tests use real async while the timing tests use `fake_async`.

## Verification

- `dart analyze lib test` → **No issues found** (whole package). A few `avoid_string_substring` false positives (indices provably in range via `indexOf`/`startsWith` guards) carry documented `// ignore:` directives; boolean cron fields renamed to `is*` per `prefer_boolean_prefixes`.
- New tests: **72 across 10 files, all passing.**
- Full suite: **5982 passed** (~2 pre-existing skips) — confirms the 12 new barrel exports introduced no name collisions or extension ambiguity.

## Roadmap

`ROADMAP_TO_400.md`: flipped the 10 built rows (#52, #57, #69, #90, #157–#160, #175, #185) to ✅ and bumped the progress table (Collections 20→23, Map/Object 19→20, Parsing 13→17, URL 12→13, Async 9→10; Total 368→378). The ~22 other TODO-marked rows that were already implemented before this session were left untouched (not built here); the column remains stale for those.
