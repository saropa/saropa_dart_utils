# Changelog

<!-- cspell:ignore ints docstrings codepoint codepoints sublist -->

``````text
                                                ....
                                       -+shdmNMMMMNmdhs+-
                                    -odMMMNyo/-..``.++:+o+/-
                                 /dMMMMMM/               `````
                                dMMMMMMMMNdhhhdddmmmNmmddhs+-
                                /MMMMMMMMMMMMMMMMMMMMMMMMMMMMMNh/
                              . :sdmNNNNMMMMMNNNMMMMMMMMMMMMMMMMm+
                              o     ..~~~::~+==+~:/+sdNMMMMMMMMMMMo
                              m                        .+NMMMMMMMMMN
                              m+                         :MMMMMMMMMm
                              /N:                        :MMMMMMMMM/
                               oNs.                    +NMMMMMMMMo
                                :dNy/.              ./smMMMMMMMMm:
                                 /dMNmhyso+++oosydNNMMMMMMMMMd/
                                    .odMMMMMMMMMMMMMMMMMMMMdo-
                                       -+shdNNMMMMNNdhs+-
                                               ``

Made by Saropa. All rights reserved.

Learn more at https://saropa.com, or mailto://dev.tools@saropa.com
``````

<!-- cspell:disable -->

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**pub.dev** - [saropa_dart_utils](https://pub.dev/packages/saropa_dart_utils)

**Published version**: See field `version` in [pubspec.yaml](./pubspec.yaml)

## [Unreleased]

### Breaking

- **`DateTimeUtils.isDeviceDateMonthFirst()`** renamed to **`isDateMonthFirst({required String localeName})`** — removes `dart:io` dependency; caller now passes the locale string.

### Fixed

- **avoid_platform_specific_imports** linter: removed `dart:io` from `date_time_utils.dart` (locale parameter) and `base64_utils.dart` (conditional imports for gzip).
- **avoid_stack_trace_in_production** linter: removed `stackTrace` from `dev.log()` calls in 7 files (`retry_policy_utils`, `retry_utils`, `timeout_fallback_utils`, `timeout_policy_utils`, `timebox_exception`, `parse_list_utils`, `url_encode_utils`). Error objects are still logged; stack traces are no longer exposed per OWASP M10.

---

## [1.0.8+1]

A large expansion of the library (collections, graph, stats, validation, async, parsing, and many more string utilities), plus documentation and lint fixes.

### Documentation

- Lint-resolution details from `bugs/history/` reflected in dartdoc, unit tests, and CHANGELOG entries (1.0.7, 1.0.8).
- Lint rule rationale in `analysis_options_custom.yaml`: `avoid_barrel_files`, `avoid_non_ascii_symbols`, `avoid_static_state`, `avoid_unmarked_public_class`; `avoid_default_tostring` satisfied by `Swipe.toString()`. Six more rules resolved: `avoid_collapsible_if`, `avoid_complex_conditions`, `avoid_redundant_else`, `avoid_medium_length_files`, `avoid_long_parameter_list`, `avoid_similar_names`.

### Fixed

- **avoid_nullable_interpolation** in `string_regex_extensions.dart`: `escapeForRegex()` now uses `m.group(0) ?? ''` so the result never contains `\null`.

### Added

New and expanded APIs (all exported from `package:saropa_dart_utils`):

- **Collections** (`lib/collections/`): lis_utils, lcs_substring_utils, sliding_window_aggregate_utils, reservoir_sampling_utils, interval_scheduling_utils, trie_utils, disjoint_set_utils, damerau_levenshtein_utils, knapsack_utils, bloom_filter_utils, nway_merge_utils, ring_buffer_utils, multiset_utils, online_mean_variance_utils, histogram_utils, difference_array_utils, bimap_utils, kmeans_utils, weighted_interval_utils, greedy_set_cover_utils, chunk_overlap_utils, pivot_unpivot_utils, run_detection_utils, stream_quantile_utils, inverted_index_utils, top_k_heap_utils, time_bucket_utils, multi_criteria_sort_utils, columnar_view_utils, window_functions_utils, balanced_partition_utils, bin_packing_utils, prefix_frequency_utils, rolling_hash_utils, dedup_set_expiry_utils, string_pool_utils, row_column_table_utils, priority_map_utils, seeded_shuffle_utils.
- **Graph** (`lib/graph/`): graph_utils, bfs_dfs_utils, dijkstra_utils, astar_utils, connected_components_utils, line_simplify_utils, hierarchy_utils, floyd_warshall_utils, topological_sort_utils, mst_utils, critical_path_utils, bipartite_utils, tree_utils, graph_diff_utils, dag_scheduler_utils.
- **Stats** (`lib/stats/`): robust_stats_utils, moving_average_utils, data_normalization_utils, quantile_summary_utils, correlation_utils, linear_regression_utils, bucketed_aggregate_utils, confidence_interval_utils, funnel_utils, outlier_mad_utils, percentile_rank_utils, retention_utils, sampling_utils, metric_rollup_utils, log_transform_utils, feature_encoding_utils.
- **Validation** (`lib/validation/`): validation_error_utils, path_validator_utils, input_shaping_utils, guard_utils, cross_field_validation_utils, safe_temp_name_utils, password_strength_utils, pii_detector_utils, data_redaction_utils, safe_parse_utils, typed_positive_utils, ip_cidr_utils, jwt_structure_utils.
- **String** (extensions + utils): levenshtein_utils, string_slug/mask/template/regex/wildcard/line/wrap/indent/replace_n/highlight/csv/ansi/words/key_value/split/unicode/case_acronym_extensions; glob_utils, soundex_utils; myers_diff_utils, diff_render_utils, apply_patch_utils, ngram_utils, slug_dedup_utils, fuzzy_search_utils, excerpt_utils, text_similarity_utils, sensitive_scrub_utils, text_chunk_utils, html_sanitizer_utils, tokenize_sentences_utils, markdown_plain_utils, search_query_parser_utils, code_block_extract_utils, url_extract_utils, safe_html_excerpt_utils, template_engine_utils, acronym_extract_utils, text_normalize_pipeline_utils, duplicate_doc_utils, human_name_parser_utils, search_index_utils, markdown_snippet_utils, text_fingerprint_utils, spelling_key_lookup_utils, email_quote_strip_utils, did_you_mean_utils.
- **Async**: debounce_utils, delay_utils, memoize_future_utils, retry_utils, sequential_async_utils, throttle_utils, timeout_fallback_utils, batch_async_utils, cancel_previous_exception (cancelPrevious + CancelPreviousException), async_semaphore_utils, async_mutex_utils, stream_buffer_utils, exponential_backoff_utils, retry_policy_utils, batch_flush_utils, circuit_breaker_utils, async_barrier_utils, timeout_policy_utils, race_cancel_utils, idempotent_async_utils, stream_window_utils, heartbeat_utils.
- **Parsing**: csv_parse_utils, email_validation_utils, hex_color_utils, isbn_utils, luhn_utils, parse_bool_utils, parse_list_utils, phone_normalize_utils, semver_utils, size_parse_utils, validate_non_empty_utils, version_parse_utils, version_compare_utils, parsing_more_utils, config_precedence_utils, csv_dialect_utils, parser_error_utils, canonicalize_json_utils, changelog_section_utils, json_diff_patch_utils, nested_query_parser_utils, varint_utils.
- **DateTime**: date_time_more_extensions, time_rounding_utils, relative_date_bucket_utils, period_split_utils, injectable_clock_utils, timebox_exception (timebox + TimeboxException) (plus existing bounds, business days, duration format/parse, relative, fiscal, week, timezone, clamp, list, overlap).
- **Map**: map_pick_omit_extensions, map_more_extensions (plus existing deep merge/deep/utils, default, diff, flatten, from_entries, invert, merge, nested, transform, nullable).
- **List**: list_lower_extensions, list_default_empty_extensions (plus existing binary search, rotate, string, nullable, of_list, make_list, unique).
- **Num**: num_more_extensions (plus existing math, clamp, compact_parse, format, iterable, lerp, locale, min_max, modulo, prime, factorial, range, round_multiple, safe_division, stats, utils).
- **Object / pipe**: pipe_compose_utils, nullable_more_extensions (plus existing assert, cast, coalesce, copy_with_defaults, default_value_extensions, identity, pipe, require, shallow_copy).
- **Niche**: hash_utils, string_diff_utils, checksum_utils, natural_sort_utils, uuid_v4_utils, niche_more_utils (plus color_utils, name_utils, pad_format_utils, random_string_utils).
- **URL/Path**: path_more_utils (plus path_extension, path_join, url_absolute, url_build, url_encode, url_extensions, url_query).
- **Caching**: lru_cache, memoize_sync_utils, size_limit_cache, ttl_cache.
- **Regex**: regex_common_utils, regex_match_utils.
- **Testing**: debug_utils (exported from barrel).
- **Scanner tool** (`tool/suggest_saropa_utils.dart`): CLI to suggest saropa_dart_utils replacements (e.g. `x == null || x.isEmpty` → `x.isNullOrEmpty`). Options: `[path]`, `--help`, `--version`. Core in `tool/suggest_saropa_utils_lib.dart`; tests in `test/tool/suggest_saropa_utils_test.dart`.

### Tests

- Swipe.toString(), MapNullableExtensions (isMapNullOrEmpty, isNotMapNullOrEmpty), GestureUtils (getSwipeSpeed, swipeMagnitudeThresholds), obscureText, hasInvalidUnicode/removeInvalidUnicode (invalid code point 56327). Additional tests for new collections, graph, stats, validation, string, and async modules.

## [1.0.8] - 2026-02-24

In this release we introduce typed result classes for common operations, split JSON utilities into focused modules, and bring the code in line with lints (named parameters, narrower exceptions, @useResult). We aimed for clearer structure and safer APIs.

### Added

- **`Occurrence<T>` class** (`lib/iterable/occurrence.dart`): typed result for `mostOccurrences()` and `leastOccurrences()` methods, replacing record return types
- **`BetweenResult` class** (`lib/string/between_result.dart`): typed result for `betweenResult()`, `betweenResultLast()`, and bracket-extraction methods, replacing record return types
- **`GestureUtils`** (`lib/gesture/gesture_utils.dart`): extracted swipe speed/magnitude classification into standalone utility class with public thresholds
- **`JsonEpochScale` enum** (`lib/json/json_epoch_scale.dart`): epoch timestamp scale (seconds, milliseconds, microseconds) extracted from `json_utils.dart`
- **`JsonIterablesUtils`** (`lib/json/json_iterables_utils.dart`): generic JSON encoding for iterables
- **`JsonTypeUtils`** (`lib/json/json_type_utils.dart`): 13 type-safe JSON conversion methods (lists, strings, ints, doubles, booleans, dates, epochs) extracted from `json_utils.dart`
- **`@useResult` annotations**: Added to 40+ public methods across string, datetime, gesture, json, list, map, num, and other extensions to prevent silent discard of return values
- **`KeyExtractor<T, E>` typedef**: for `toUniqueBy`/`toUniqueByInPlace` parameters (`prefer_typedefs_for_callbacks`)
- **`Swipe.toString()`**: Added string representation for debugging

### Changed

- **`json_utils.dart` split**: Extracted type conversions, epoch scale, and iterable encoding into 3 focused modules for modularity
- **`Swipe` constructor**: Changed from positional to required named parameters (`prefer_all_named_parameters`)
- **Boolean parameter renames** (`prefer_boolean_prefixes`): `testDecode` → `shouldTestDecode`, `allowEmpty` → `shouldAllowEmpty`, `cleanInput` → `shouldCleanInput`, `inclusive` → `isInclusive`, `startOfDay` → `isStartOfDay`, `roundUp` → `shouldRoundUp`
- **Exception narrowing** (`avoid_catch_all`): Replaced bare `catch (e)` with specific exception types (`on FormatException`)
- **`dynamic` → `Object?`**: Replaced `dynamic` return types in JSON decode methods (`avoid_dynamic_type`)
- **Abstract final classes**: Converted static-only utility classes to `abstract final` to prevent instantiation and inheritance
- **Lint compliance**: Resolved `prefer_all_named_parameters` across `isNthDayOfMonthInRange`, `getGreatGrandchild`, `getGreatGrandchildString`, `mapToggleValue`, `mapAddValue`, `mapRemoveValue`, `mapContainsValue`
- **Lint compliance**: Resolved `prefer_class_over_record_return` across 5 extension files by replacing record types with named classes
- **Lint compliance**: Resolved `prefer_parentheses_with_if_null` in `string_between_extensions.dart`
- **Lint compliance**: Resolved `prefer_typedefs_for_callbacks` and `prefer_extracting_function_callbacks` in unique list and map extensions
- **Lint compliance**: Extracted `_writeFormattedValue` helper from `formatMap` using Dart 3 switch pattern matching
- **Lint compliance**: Eliminated logic duplication — `inRange` now delegates to `isBetween`; replaced inline leap-year math with `DateTimeUtils.isLeapYear()` reuse
- **Lint compliance**: Used `List.generate` for pre-allocated day lists (`require_list_preallocate`)
- **Lint compliance**: Extracted hardcoded `Duration` constants (`_oneDay`, `_oneMicrosecond`) per `avoid_hardcoded_durations`
- **Lint compliance**: Avoided parameter mutation — use local `resolvedNow` instead of reassigning `now`
- **Refactoring**: Extracted helper methods in `date_time_utils.dart` (`_pluralLabel`, `_joinWithAnd`, `_buildDurationParts`) and replaced switch statements with constant set lookups
- Added `T extends Object` constraint to `GeneralIterableExtensions` generic parameter
- Updated `analysis_options.yaml` and `analysis_options_custom.yaml` lint configurations

### Tests

- Added comprehensive test suite for `JsonTypeUtils` (60+ test cases)
- Updated tests for renamed boolean parameters across json, datetime, gesture, and enum tests
- Lint violations reduced from ~10,000 to ~30

## [1.0.7] - 2026-02-22

We split the large string and date-time extension files into smaller modules (everything stays backward compatible), fixed a bunch of lints, and switched to proper test matchers. The codebase is easier to work in and the linter is quieter.

### Fixed

- **Lint compliance**: Resolved 10 lint rule categories across 4 files:
  - `avoid_nested_conditional_expressions` (5): refactored nested ternaries to if-else in wrap methods
  - `avoid_redundant_else` (2): removed redundant else in `getFirstDiffChar`, `toBoolNullable`
  - `prefer_switch_expression` (2): converted `isVowel`, `grammarArticle` to switch expressions
  - `avoid_string_concatenation_loop` (1): replaced string concat with StringBuffer in `splitCapitalizedUnicode`
  - `avoid_duplicate_string_literals` (1): reused `_alphaOnlyRegex` in `lettersOnly`
  - `prefer_correct_identifier_length` (1): renamed `r` to `deduplicateRegex` in `replaceLineBreaks`
  - `missing_use_result_annotation` (1): added `@useResult` to `makeNonBreaking`
  - `no_magic_string` (1): extracted grammar article prefixes to named constants
  - `avoid_long_length_files` (2): split oversized files (see Refactored below)
  - `avoid_very_long_length_files` (1): split `string_extensions.dart` (1114 lines)
- **Performance**: cached `toLowerCase()` call in `toBoolNullable`, extracted inline RegExp to top-level finals in `lowerCaseLettersOnly` and `removeSingleCharacterWords`
- **Lint compliance (prior)**: Resolved 59 high-priority warnings across 9 saropa_lints rules:
  - `avoid_type_casts` (7): replaced `as` casts with `is` checks in map/json utils
  - `verify_documented_parameters_exist` (31): fixed stale dartdoc references
  - `avoid_string_substring` (9): replaced `substring()` with `substringSafe()`
  - `prefer_iterable_of` (5): replaced `.from()` with `.of()` for type safety
  - `avoid_duplicate_cascades` (3): refactored UUID StringBuffer to `List.join()`
  - `avoid_nullable_interpolation` (1): added `??` fallback in `escapeForRegex`
  - `avoid_unsafe_cast` (1): used type promotion in `make_list_extensions`
  - `avoid_wildcard_cases_with_sealed_classes` (1): narrowed `num` to `int`
  - `avoid_god_class` (1): suppressed (constants namespace)

### Refactored

- **`string_extensions.dart`** (1114 → 4 files): Split into `string_extensions.dart` (275), `string_analysis_extensions.dart` (195), `string_manipulation_extensions.dart` (286), `string_text_extensions.dart` (296). Re-exports maintain backward compatibility.
- **`date_time_extensions.dart`** (818 → 4 files): Split into `date_time_extensions.dart` (185), `date_time_arithmetic_extensions.dart` (175), `date_time_comparison_extensions.dart` (164), `date_time_calendar_extensions.dart` (174). Re-exports maintain backward compatibility.
- **`DateConstants`**: Moved 16 top-level constants into `DateConstants` class as `static const` members for proper namespacing and consistency with `MonthUtils`, `WeekdayUtils`, and `SerialDateUtils` patterns. Added private constructor to prevent instantiation.

### Changed

- **Publish script** (`publish_pub_dev.ps1`): Hardened with smarter pre-checks — auto-fixes pubspec version when CHANGELOG is ahead, aborts early if version tag exists on remote, verifies `gh` auth status and publish workflow. Removed dead code, fixed docstrings and step numbering. Bumped to v2.2.

### Tests

- Replaced 312 raw literal matchers with proper test matchers across 19 test files (`avoid_misused_test_matchers`): `expect(x, true)` → `isTrue`, `expect(x, false)` → `isFalse`, `expect(x, null)` → `isNull`, `expect(x.length, N)` → `hasLength(N)`

### Added

- Bug reports for 80+ saropa_lints rules with reproduction steps and suggestions in `bugs/`

## [1.0.6] - 2026-02-19

We ran a full bug audit and fixed 32 issues—date/time and string logic, emoji handling, and JSON/HTML edge cases. Behavior should be more reliable everywhere.

### Fixed (32 bugs resolved — full audit)

#### Critical / Logic Errors

- **`getUtcTimeFromLocal`**: was adding offset instead of subtracting; used `floor()` instead of `truncate()` for negative fractional offsets (e.g. UTC-5:30). Return type narrowed from `DateTime?` to `DateTime` (never null).
- **`isDateAfterToday`**: was an instance method that ignored `this` entirely, only checking the `dateToCheck` parameter. Removed the parameter — now correctly checks the receiver against today. Added injectable `{DateTime? now}` for testability.
- **`randomElement`**: was using `DateTime.now().microsecondsSinceEpoch % length` (deterministic, biased). Now uses a module-level `Random` instance with `nextInt()`.
- **`isBetween`**: inclusive mode was using `==` instead of `isAtSameMomentAs` for boundary equality — boundary values were excluded.
- **`removeStart`**: case-insensitive path was calling `nullIfEmpty()` on the trimmed match, returning `null` instead of the original string on non-match.
- **`last()`**: was using rune-based indexing, splitting multi-codepoint emoji. Now uses `characters` package grapheme clusters. Also optimized: replaces `toList()` + `sublist()` with `chars.skip()` to avoid full list allocation.
- **`toDateInYear`**: was crashing with `ArgumentError` for Feb 29 → non-leap year. Now returns `null`.
- **`cleanJsonResponse`**: was unescaping `\"` before detecting outer quotes, corrupting strings like `"hello \"world\""`. Now detects outer quotes first.

#### Medium

- **`betweenResult`**: `endOptional` parameter was declared but never consulted — end-not-found always returned `null`. Now correctly returns the tail when `endOptional: true` is passed. Default changed to `false` to preserve backward compatibility.
- **`isSameDateOrAfter` / `isSameDateOrBefore`**: replaced fragile cascaded year/month/day if-chains with clean `toDateOnly()` + `!isBefore` / `!isAfter`.
- **`isJson('[]')`**: empty array was returning `true` without `allowEmpty: true`, inconsistent with empty object `{}` behavior. Now requires `allowEmpty: true` for both.
- **`isJson` colon check**: was checking `value.contains(':')` (untrimmed) instead of `trimmed.contains(':')`.
- **`formatDouble`**: no guard for negative `decimalPlaces` — `toStringAsFixed` would throw `RangeError`. Now clamps to 0–20.
- **`hasDecimals` / `formatDouble`**: did not guard against `NaN` / `Infinity` — `NaN % 1` returns `NaN` (not `0`). Now returns `false` / `'NaN'` / `'∞'` respectively.
- **`unescape` (HTML)**: `&nbsp;` was mapped to regular space (U+0020) instead of non-breaking space (U+00A0). Fixed.
- **`unescape` (HTML)**: numeric entity handler allowed surrogate codepoints (U+D800–U+DFFF) which crash `jsonEncode`. Now rejected with named constants `_surrogateMin` / `_surrogateMax`.
- **`addHyphens`**: accepted any 32-char string without validating hex content. Now validates with `_hexOnly32Regex`.
- **`exclude` / `containsAny`**: O(n×m) — converted to `Set` for O(n) lookup.
- **`toFlattenedList`**: returned `null` for empty outer but `[]` for all-empty inners. Now returns `null` consistently for empty results.

#### Low / Documentation

- **`isYearCurrent`**: hardcoded `DateTime.now()` made it untestable. Converted from getter to method with `{DateTime? now}` injectable parameter.
- **`isDateAfterToday`** / **`isToday`** etc.: same injectable `now` pattern applied for testability.
- **`weekOfYear`**: added warning in docs that value can be 0 or 53 at year boundaries; recommend `weekNumber()` for ISO 8601 compliance.
- **`isMidnight`**: now checks all time components including milliseconds and microseconds.
- **`leastOccurrences`**: corrected copy-paste doc comment that said "highest" instead of "lowest".
- **`formatPrecision`**: hardcoded `toStringAsFixed(2)` whole-number check now uses the actual `precision` parameter.
- **`betweenResult`**: improved doc to explain intentional `lastIndexOf` ("outermost match") design.
- **`between`**: documented special case where empty `end` returns the tail from `start`.
- **`takeSafe(0)`**: documented that `count == 0` returns the original list (unlike `take(0)`).
- **`weekOfYear`** / **`weekNumber()`**: documented ISO 8601 edge cases at year boundaries.
- **`num.length()`**: documented scientific notation behavior for values ≥ 1e21.
- **`pluralize`**: removed `length == 1` guard that incorrectly skipped single-character strings.
- **`forceBetween`**: corrected misleading dartdoc ("NOT greater than" → correctly describes clamping).
- **`truncateWithEllipsisPreserveWords`**: fixed grapheme-unsafe fallback that could split multi-codepoint emoji; now uses `characters.take()` for the search window.
- **`toMapStringDynamic`**: documented silent key collision behavior when `ensureUniqueKey: false`.
- **`timeToEmoji`**: boundary was `>` instead of `>=` — 7:00am showed moon emoji instead of sun.

### Changed

- Extracted magic numbers into named constants across codebase (date/time, numeric, string, HTML, UUID); 50+ constants in `date_constants.dart`, `date_time_range_utils.dart`, `date_time_utils.dart`, `time_emoji_utils.dart`, `double_extensions.dart`, `hex_utils.dart`, `html_utils.dart`, `int_extensions.dart`, `int_string_extensions.dart`, `int_utils.dart`, `string_search_extensions.dart`, `string_utils.dart`, `uuid_utils.dart`; resolved `no_magic_number` lint violations.

### Fixed

- `DateTimeUtils.tomorrow()`: Removed nullable type from `minute` and `second` parameters to fix `avoid_nullable_parameters_with_default_values` lint warnings.

### Tests

- 3,022 tests passing (added ~40 new tests covering all fixed bugs)
- Fixed 8 pre-existing tests with incorrect expectations or wrong test names
- Removed duplicate test cases in `date_time_range_utils_test.dart`

## [1.0.5] - 2026-01-08

We rewrote the README with before/after examples and real-world use cases so it’s easier to see what the library does and whether it fits your project.

### Changed

- Rewrote README with compelling production-proven messaging
- Added before/after code comparison table
- Added real-world use cases section
- Improved About section with library origin story

## [1.0.4] - 2026-01-08

We fixed a flaky date/time test that sometimes failed in CI. Your test runs should be more reliable now.

### Fixed

- Fix flaky DateTime test race condition in CI

## [1.0.3] - 2026-01-07

We updated the GitHub Actions publish workflow to use OIDC authentication. Publishing to pub.dev works with the current GitHub setup again.

### Changed

- Fix GitHub Actions publish workflow for OIDC authentication

## [1.0.2] - 2026-01-07

We added a banner to the README so the project is easier to spot at a glance.

### Changed

- Added a banner to README.md

## [1.0.0] - 2026-01-07

First stable 1.0: we switched to the MIT license for broader use, turned on the full saropa_lints tier for quality, and added README badges so you can see pub points, method count, and coverage at a glance.

### Changed

- Migrated from GPL v3 to MIT license for broader adoption
- Upgraded saropa_lints from `recommended` to `insanity` tier (all 500+ rules enabled)

### Added

- Pub points badge (dynamic from pub.dev)
- Methods count badge (480+ methods)
- Coverage badge (100%)
- Organized badge assets into `assets/badges/` folder

## [0.5.12] - 2026-01-05

We switched to the saropa_lints package and custom_lint, and trimmed the analysis config from 255 lines to 69. You get the same level of checking with less to maintain.

### Changed

- Replaced manually flattened lint rules with `saropa_lints: ^1.1.12`
- Added `custom_lint: ^0.8.0` for custom lint rule support
- Configured `recommended` tier (~150 rules)
- Simplified `analysis_options.yaml` from 255 lines to 69 lines
- Removed manually flattened flutter_lints/recommended/core rules

## [0.5.11]

We added utilities for Base64 compression, UUID validation and formatting, HTML unescape and plain text, and double formatting (percentages, precision, clamping). All of it is covered by 103 new tests.

### Added

- `Base64Utils` - Text compression and decompression (`compressText`, `decompressText`)
- `UuidUtils` - UUID validation and manipulation (`isUUID`, `addHyphens`, `removeHyphens`)
- `HtmlUtils` - HTML text processing (`unescape`, `removeHtmlTags`, `toPlainText`)
- `DoubleExtensions` - Double formatting (`hasDecimals`, `toPercentage`, `formatDouble`, `forceBetween`, `toPrecision`, `formatPrecision`)
- 103 test cases covering all new utilities

## [0.5.10] - 2025-12-11

We extended the publish script with version and branch parameters, dry-run validation, and checks for working tree and remote sync. Releases are safer and easier to script from CI.

### Added

- `-Version` parameter for CI/CD automation in publish script
- `-Branch` parameter to specify target branch
- Pre-publish validation step (`flutter pub publish --dry-run`)
- `flutter analyze` step before publishing
- Working tree status check with user confirmation
- Remote sync check to prevent publishing when behind remote
- Early CHANGELOG version validation

### Fixed

- Step numbering in publish script (was skipping from 4 to 6)
- `ErrorActionPreference` issue with try/catch for GitHub release check

### Changed

- Dynamic package name and repo URL extraction from pubspec.yaml and git remote
- Excluded example folder from parent analysis

## [0.5.9] - 2025-11-25

We added an `allowEmpty` option to JSON validation and made string methods (substring, truncate, lastChars) use grapheme clusters so emoji and Unicode behave correctly. **Note:** indices are now grapheme-based—a breaking change if you relied on code-unit positions.

### Added

- `isJson`: `allowEmpty` parameter to optionally treat `{}` as valid JSON
- 16 test cases for `JsonUtils.isJson`

### Changed

- `substringSafe`: Now uses `characters.getRange()` for proper UTF-16/emoji support
- `truncateWithEllipsis`: Uses grapheme cluster length for accurate emoji handling
- `truncateWithEllipsisPreserveWords`: Uses grapheme cluster length
- `lastChars`: Uses grapheme cluster length
- **Breaking**: Indices now refer to grapheme clusters, not code units

### Fixed

- `MakeListExtensions`: Changed extension from `T` to `T?` for nullable types
- `getUtcTimeFromLocal`: Fixed incorrect documentation
- `getNthWeekdayOfMonthInYear`: Removed stale parameter references from docs

### Removed

- `UniqueListExtensionsUniqueBy`: Removed unused `propertyComparer` generic parameter

## [0.5.8] - 2025-11-25

We made the publish script handle git tags and GitHub releases idempotently. You can re-run it after a partial run without it failing.

### Changed

- `publish_pub_dev.ps1`: Added idempotent handling for git tags
- `publish_pub_dev.ps1`: Added idempotent handling for GitHub releases
- Prevents script failures when re-running after partial completion

## [0.5.7] - 2025-11-25

We fixed string extraction (curly braces, line breaks), made word removal Unicode-aware, and improved the grammar and article rules. Text handling should be more accurate now.

### Fixed

- `extractCurlyBraces`: Switched to non-greedy matching for correct extraction order
- `removeSingleCharacterWords`: Made Unicode-aware for single-letter words beyond ASCII
- `replaceLineBreaks`: Improved deduplication for arbitrary replacement strings
- `grammarArticle`: Enhanced heuristics for silent 'h', "you"-sound words, and `one-` prefixes
- `possess`: Trims input before applying trailing 's' rules

### Changed

- `repeat`: Optimized concatenation with `StringBuffer`
- `lettersOnly`/`lowerCaseLettersOnly`: Simplified to regex-based ASCII filters

## [0.5.6]

We added URL/URI extensions so you can check HTTPS, add or get query parameters, and replace the host. Handy when building or validating links.

### Added

- `UrlExtensions.isSecure` - Check if URI uses HTTPS scheme
- `UrlExtensions.addQueryParameter` - Add or update query parameters
- `UrlExtensions.hasQueryParameter` - Check if query parameter exists
- `UrlExtensions.getQueryParameter` - Get query parameter value
- `UrlExtensions.replaceHost` - Create URI with different host

## [0.5.5] - 2025-11-25

A big release: JSON and map utilities, URL extensions, string extraction and search, date constants, and many new DateTime and string helpers. We added tests too—over 2,850 in total.

### Added

- `JsonUtils` - JSON parsing, type conversion, and validation
- `MapExtensions` - Map manipulation utilities
- `UrlExtensions` - URI manipulation (`removeQuery`, `fileName`, `isValidUrl`, `isValidHttpUrl`, `tryParse`)
- `StringBetweenExtensions` - Content extraction (`between`, `betweenLast`, `removeBetween`, etc.)
- `StringCharacterExtensions` - Character operations (`splitByCharacterCount`, `charAtOrNull`)
- `StringSearchExtensions` - Search utilities (`containsAnyIgnoreCase`, `indexOfAll`, `lastIndexOfPattern`)
- `MonthUtils`, `WeekdayUtils`, `SerialDateUtils` - Date constant lookups
- DateTime extensions: `mostRecentSunday`, `mostRecentWeekday`, `dayOfYear`, `weekOfYear`, `numOfWeeks`, `weekNumber`, `toSerialString`, `toSerialStringDay`
- String extensions: `removeSingleCharacterWords`, `removeLeadingAndTrailing`, `firstWord`, `secondWord`, `endsWithAny`, `endsWithPunctuation`, `isAny`, `extractCurlyBraces`, `obscureText`, `hasInvalidUnicode`, `isVowel`, `hasAnyDigits`
- Iterable/Num extensions: `randomElement`, `containsAll`, `toDoubleOrNull`, `toIntOrNull`
- `DateTimeUtils.isValidDateParts` - Comprehensive date part validation
- `convertDaysToYearsAndMonths` - `includeRemainingDays` option
- 2850 tests (all passing)

## [0.5.4]

We fixed range and date logic (inclusive boundaries, year boundaries), list comparison, hex overflow, and string truncation. Added 110 tests so the fixes stay solid.

### Fixed

- `isBetweenRange`: Properly forwards `inclusive` parameter
- `isAnnualDateInRange`: Correctly handles date ranges spanning year boundaries
- `isNthDayOfMonthInRange`: Cross-year range validation
- `inRange` and `isNowInRange`: Default to inclusive boundary semantics
- `equalsIgnoringOrder`: Correctly compares duplicate counts
- `hexToInt`: Case-sensitive overflow check
- `toUpperLatinOnly`: O(n²) → O(n) using StringBuffer
- `upperCaseLettersOnly`: O(n²) → O(n) using StringBuffer
- `truncateWithEllipsisPreserveWords`: Returns truncated content when first word exceeds cutoff
- `containsIgnoreCase`: Empty string is contained in any string
- `convertDaysToYearsAndMonths`: Improved precision using average days

### Added

- 110 new test cases for algorithm fixes

## [0.5.3] - 2025-11-12

We tuned regex usage in string utils and improved the docs for the random and list helpers. A small polish release.

### Changed

- Enhanced `string_utils.dart` to optimize final regex usages
- Improved documentation for `CommonRandom` and list generation

## [0.5.2] - 2025-08-19

We renamed the string extension type to `StringExtensions` for consistency. Behavior is unchanged; only the type name is different.

### Changed

- Renamed `StringFormattingAndWrappingExtensions` to `StringExtensions`

## [0.5.1] - 2025-08-19

We merged all string extension methods into one file and added a full test suite. Imports and structure are simpler.

### Changed

- Merged all string extension methods into `lib/string/string_extensions.dart`
- Updated imports across dependent files

### Removed

- Redundant string extension files and old test files

### Added

- Comprehensive test suite for `string_extensions.dart`

## [0.5.0] - 2025-08-19

We added extensions for numbers (e.g. clamping), lists (order-agnostic comparison), and strings (safer number parsing), and refactored names and tests for consistency.

### Added

- Extension methods for numbers, lists, and strings (`forceBetween`, order-agnostic list comparison, safer string number parsing)
- Test files for new extensions

### Changed

- Refactored extension names for consistency
- Updated test imports and structures

## [0.4.4] - 2025-08-18

We split the string code into smaller files and added unique-list and number-range utilities. The layout is clearer and you get a few new helpers.

### Changed

- Split large string file into smaller, specific files
- Updated tests and imports for new file structure
- Improved code analysis settings

### Added

- Unique lists and number ranges utilities

## [0.4.3] - 2025-02-24

We added framework-style extensions for primitives (num, string, etc.), set line length to 100, and removed the VGV spelling lists.

### Added

- Framework extensions for primitives (num, string, etc.)

### Changed

- Line length to 100

### Removed

- VGV's spelling lists

## [0.4.2] - 2025-02-24

A small maintenance release: minor improvements and fixes.

### Changed

- Minor improvements and fixes

## [0.4.1] - 2025-02-13

Another small maintenance release: minor improvements and fixes.

### Changed

- Minor improvements and fixes

## [0.4.0] - 2025-02-13

We did a major refactor of the library structure and APIs to set things up for the extensions and utilities that followed.

### Changed

- Major refactoring release

## [0.3.18] - 2025-01-07

We added DateTime and DateTimeRange utilities and brought in jiffy/intl for date formatting. Date handling works well out of the box now.

### Added

- `DateTimeRange` utils
- `DateTime` utils
- Dependency to jiffy and intl for date processing

### Changed

- Unused flutter code detection script logs warnings to file

## [0.3.17] - 2025-01-07

A small maintenance release: minor improvements.

### Changed

- Minor improvements

## [0.3.16] - 2025-01-07

Another small maintenance release: minor improvements.

### Changed

- Minor improvements

## [0.3.15] - 2025-01-03

Another small maintenance release: minor improvements.

### Changed

- Minor improvements

## [0.3.13]

We added a script to detect unused Flutter code and updated the Code of Conduct (logo, examples, survey). We also renamed the doc folder to docs and removed Codecov.

### Added

- Unused flutter code detection script
- TED talks video library to Code of Conduct

### Changed

- H.O.N.E.S.T.I. acronym wording in Code of Conduct
- Code of Conduct with Saropa logo, examples, survey, and exercise
- Link to Code of Conduct in README.md
- Renamed `doc` folder to `docs`

### Removed

- Codecov integration

## [0.2.3]

We added CommonRandom for reproducible randomness, a Code of Conduct for contributors, and development helper scripts. The project is easier to work on and expectations are clearer.

### Added

- `CommonRandom` class as drop-in replacement for `math.Random()`
- Code of Conduct for Saropa contributors
- Development helper scripts

### Changed

- Updated changelog

## [0.2.1]

We moved the list extensions onto Iterable so they work with any iterable, not just lists. The API is more flexible.

### Changed

- Migrated `List` extensions to `Iterable`

## [0.2.0]

We added enum helpers (byNameTry, sortedEnumValues) and list extensions (smallest, biggest, most/least occurrences), and bumped the SDK and collections dependency.

### Added

- `Enum` methods: `byNameTry` and `sortedEnumValues`
- List extensions for smallest, biggest, most, and least occurrences

### Changed

- Bumped SDK requirements (sdk: ">=3.4.3 <4.0.0", flutter: ">=3.24.0")
- Added collections package dependency

## [0.1.0]

We renamed nullable string utils to extensions and deprecated a few functions we plan to remove. Cleanup to make the API clearer.

### Changed

- Renamed `string_nullable_utils.dart` to `string_nullable_extensions.dart`

### Deprecated

- Several functions in preparation for removal

## [0.0.11]

We added date constants and ordinal/GCD/countDigits helpers, fixed removeStart when the search is empty, and removed the deprecated string-nullable functions.

### Added

- `DateConstants.unixEpochDate`
- `DateConstantExtensions.isUnixEpochDate`
- `DateConstantExtensions.isUnixEpochDateTime`
- `IntStringExtensions.ordinal`
- `StringUtils.getNthLatinLetterLower`
- `StringUtils.getNthLatinLetterUpper`
- `IntUtils.findGreatestCommonDenominator`
- `IntExtensions.countDigits`

### Fixed

- `StringExtensions.removeStart` returns input when search param is empty

### Removed

- Deprecated functions in `StringNullableExtensions`

## [0.0.10]

We made removeStart accept a nullable search parameter so it’s easier to use in nullable contexts.

### Changed

- `removeStart` parameter changed to nullable

## [0.0.9]

We added an optional trimFirst parameter to removeStart so you can trim the result. A small string API improvement.

### Added

- `trimFirst` parameter to `StringExtensions.removeStart`

## [0.0.8]

We added an optional trimFirst parameter to nullIfEmpty so you have finer control over empty and whitespace handling.

### Added

- `trimFirst` parameter to `StringExtensions.nullIfEmpty`

## [0.0.7]

We renamed the strings folder to singular and deprecated the nullable string extensions. Naming and API cleanup.

### Changed

- Renamed strings folder to singular

### Deprecated

- Nullable string extensions

## [0.0.6]

We added swipe gesture properties for use in gesture-aware UIs. The groundwork for swipe handling.

### Added

- Swipe gesture properties

## [0.0.5]

We documented all methods, added example app usage and README examples, and extended the string extensions. The library should be easier to discover and use.

### Added

- Documentation for all methods
- Code usage in Example App
- Code usage in README.md
- String extension methods

## [0.0.4]

We added an example app, GitHub Actions, and contribution templates (PR, issue, contributing guide). The project is ready for others to contribute.

### Added

- Example App
- GitHub Actions setup
- Pull request template
- Issue template
- Contributing guide

## [0.0.3]

We added a random enum selection helper for when you need a random value from an enum.

### Added

- Random enum method

## [0.0.2]

We added string-to-bool conversion methods so you can parse "true"/"false" and similar strings safely.

### Added

- String to bool conversion methods

## [0.0.1] - 2024-06-27

First release. We included bool list methods to get started.

### Added

- Initial release with bool list methods

---

```plain

      Made by Saropa. All rights reserved.
```
