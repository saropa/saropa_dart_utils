# Finish Report — 27-SPEC batch build (color / datetime / string / num / map / list / bool / async)

**Date:** 2026-06-11
**Source:** a list of 27 `plans/SPEC-*.md` candidate-utility specs migrated from Saropa Contacts, each naming a target `lib/` path, verbatim source to port, sample tests, and a "Bulletproofing gaps" edge-case list. All 27 were built in parallel via the `build-gate-fix` multi-agent workflow (parallel authors → one shared `flutter analyze`+`flutter test` gate → per-file fix agents), then four over-limit files were split to satisfy the 200-line hard limit.

## 1. Scope

**(A) Flutter/Dart app code** — `lib/` + `test/` only. This is a pure utility library: no UI screens/widgets/dialogs, no l10n catalog, no extension/TypeScript. Section 5 (l10n) is `SKIPPED [A-NOT-IN-SCOPE]` — no user-facing strings exist in a utilities package (the only strings are dartdoc and developer-facing format output, not localizable UI copy).

## 2. What shipped

26 of 27 specs produced new source + tests. One (`SPEC-datetime-timezone.md`) was correctly judged by its author agent to be a rejection/assessment document, not an implementation request — no source produced, by design.

New public capabilities (one line each):
- **color**: `DarkColors` enum + `darkColorMap` (`niche/dark_colors.dart`); `StopRange` gradient-stop (`double/gradient_stop_range.dart`); `MaterialShade` ladder (`color/material_shade.dart`); Flutter `Color` parse/format/contrast extensions (`flutter/color_extensions.dart`); Material swatch helpers (`flutter/material_color_utils.dart`).
- **datetime**: `monthDayCountSafe` (`date_time_utils.dart`); day-in-month named weekday calcs (`month_weekday_named_extensions.dart`); duration clock-format (`duration_clock_format_extensions.dart`); annual-date/day-range bounds (`date_time_bounds_extensions.dart`); intl display (`date_time_intl_display_extensions.dart` + parts); Hebrew calendar converter (`hebrew_date_converter.dart`); relative-time predicates + formatter (`date_time_relative_predicate_extensions.dart` + parts); simple relative-day classifier (`simple_relative_day_utils.dart` + types); instant-based age compare (`date_time_compare_age_extensions.dart`).
- **string**: list helpers (`list/list_string_extensions.dart`), misc `removeEndNullable` (`string_manipulation_extensions.dart`), special-chars/folded-compare (`string_folded_compare_extensions.dart`), text-direction parse (`text_direction_parse_utils.dart`), Unicode block classifier (`unicode_class_utils.dart` + `unicode_class_blocks.dart` + `unicode_class_type.dart`).
- **num/double**: intl number format (`num/num_intl_format_extensions.dart`); aspect-ratio (`double/double_aspect_ratio_extensions.dart`); Uint8List bridging (`typed_data/uint8list_extensions.dart`).
- **map/list/bool**: initials sort (`map/map_initials_sort_extensions.dart`); nullable-string sort (`list/list_nullable_string_sort_extensions.dart`); bool `compareTo` (`bool/bool_sort_extensions.dart`).
- **async**: `ComputeStreamTransformer` (`async/compute_stream_transformer.dart`); `FilterValue<T>` tri-state copyWith (`copy_with/filter_value.dart`).

## 3. Deep Review

- **Logic & safety**: 6 genuine source bugs were found by the gate and fixed at root cause — terse relative-time forms were wrongly pluralized (`min`→`mins`); `String.trim()` was stripping BOM/NBSP and other Unicode space separators before classification/parsing (Unicode-class and text-direction); DST spring-forward made local-midnight day math off by one (simple-relative-day); a grapheme-aware slice was used where the spec pins UTF-16 code-unit semantics (`removeEnd`); intl silently echoed unknown pattern letters instead of yielding `''` (intl display); the compare-age comparator was correct, its test fixture was wrong.
- **Architecture & adherence**: all new files match sibling category structure; barrel exports added (23 self-wired by authors, 1 gap — `compute_stream_transformer` — added in synthesis). No logic duplication introduced by the splits (shared private helpers kept reachable via `part`/`part of`, never copied).
- **Performance/UI**: N/A — pure synchronous utilities except `ComputeStreamTransformer` (offloads per-event work to a background isolate via `compute`, order-preserving `asyncMap`, error-propagating).
- **Refactoring done in-scope**: four files exceeding the 200-line hard limit were split (see §5).
- **Honesty note**: the `DarkColors` palette is the verbatim Material-700 set; its bright Yellow/Amber/Lime members do NOT clear WCAG 3.0 against white. The contrast test's 3.0 floor was an over-claim and was corrected to the true measured floor (1.5), and the source dartdoc was corrected to stop claiming uniform high-contrast. Palette hexes unchanged (fidelity to the named Material constants preserved).

## 4. Testing Validation

- **Audit of existing tests**: the fix phase touched several pre-existing files (`list_string_extensions`, `string_manipulation_extensions`, `date_constants`, `date_time_bounds_extensions`, `map_extensions`). 7 of 13 fixes were spec-justified TEST-expectation corrections (eszett non-expansion per real Dart `toUpperCase`, Hebrew leap-cycle boundary per the closed-form rule, UTC-vs-local instant fixtures, an inverted code-unit comment, the WCAG floor, and an isolate-only behavior unobservable in the test VM) — each documented at the assertion, none deleted or commented out.
- **Run**: `flutter analyze` → No issues found (851 files). `flutter test` → **+7792 passed, 2 skipped, 0 failed.** Re-run after the splits: same result, clean.

## 5. File-split refactor (200-line hard limit)

Four files exceeded 200 lines and were split, public API preserved exactly (consumers import the barrel; symbols unchanged):
- `date_time_intl_display_extensions.dart` 416 → 6 `part`-linked files (97/94/85/64/64/62).
- `date_time_relative_predicate_extensions.dart` 417 → 4 `part`-linked files (17/180/130/106).
- `unicode_class_utils.dart` 294 → `unicode_class_utils.dart` (158) + `unicode_class_blocks.dart` (145, re-exported via `show`).
- `simple_relative_day_utils.dart` 246 → `simple_relative_day_utils.dart` (168) + `simple_relative_day_types.dart` (86, `part of`).

Pre-existing `unicode_class_type.dart` (346 lines) is over the limit but was not part of this task's authored files — flagged, left untouched.

## 6. Workflow + tooling fixes (outside the repo, in ~/.claude)

- `C:\Users\craig\.claude\workflows\build-gate-fix.js` — patched to accept `args` as a JSON **string** as well as an object (the tool delivered a stringified payload, which had silently collapsed to `no-items` twice).
- `C:\Users\craig\.claude\skills\wf\` — new `/wf` skill (script `wf-status.sh`) that reconstructs live workflow status from per-agent JSONL transcripts, since the built-in `/workflows` TUI is not implemented in the VSCode-extension surface and the background Workflow tool only notifies on completion.
- These are user-global tooling, NOT part of the committed repo change set.

## 7. Project maintenance

- **CHANGELOG.md**: `### Added` entries written by the author agents for every new capability; `### Fixed` entries for the 6 source bugs. Verified present.
- **CODE_INDEX.md / CODEBASE_INDEX.md**: updated by author agents with the new capabilities.
- **README**: verified — no updates needed (examples unchanged; README is curated, not auto-generated per-util).
- **pubspec.yaml**: modified (dependency/version housekeeping carried in the tree); no new runtime dependency added by these utilities beyond the existing `intl`/`characters`/`collection`.
- **Bug archive**: `No bug archive — task did not close a bugs/*.md file.`
- **Plan archival**: all 27 `plans/SPEC-*.md` moved to `plans/history/2026.06/2026.06.11/` (mirrors the existing `SPEC-num-unit-conversions.md` / `SPEC-sort-diacritic-fold.md` siblings already archived there).

`Finish report saved: plans/history/2026.06/2026.06.11/spec-batch-build-color-datetime-string-num.md`
