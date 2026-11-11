# Changelog History

<!-- cspell:disable -->

Archived changelog entries for **saropa_dart_utils** versions. For current releases, see [CHANGELOG.md](./CHANGELOG.md).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**pub.dev** - [saropa_dart_utils](https://pub.dev/packages/saropa_dart_utils)

---

## [1.3.0]

Ten new utilities from the Roadmap-to-700 set: a forgiving JSON-to-model reader, a CSV writer, a path-template matcher, stream zip/combine operators, multi-key grouping, a swappable cache interface with a write-through loader, date-format presets, ICU plural/select message lite, timing wrappers, and a JSON pretty-printer.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.3.0/CHANGELOG.md)

### Added

- **`JsonModelReader`** ([json_model_mapper_utils.dart](lib/parsing/json_model_mapper_utils.dart)) — reads typed fields (`requireString`/`requireInt`/`requireBool`/`requireDouble`/`requireList`/`optionalString`/`child`) from decoded JSON, accumulating a `ValidationErrors` list instead of throwing on the first bad field. Distinguishes missing (`code: 'missing'`) from wrong-type (`code: 'type'`), widens `int`→`double`, and reports nested failures with dotted paths (`address.city`) on a shared collection. Roadmap #637.
- **`writeCsvLine` / `writeCsv`** ([csv_writer_utils.dart](lib/parsing/csv_writer_utils.dart)) — the inverse of `parseCsvLine`: encode rows to CSV with RFC 4180 auto-quoting (a field is quoted only when it contains the delimiter, a quote, CR, or LF; embedded quotes are doubled). Configurable `delimiter` (TSV via `\t`), `eol` (CRLF default), and `forceQuote`. Round-trips with `parseCsvLine`. Roadmap #622.
- **`UriPattern`** ([uri_pattern_utils.dart](lib/url/uri_pattern_utils.dart)) — compile a path template (`/users/{id}/posts/{slug}`) and `match()` concrete paths to extract named segment params, or null on no match. Supports a typed `{id:int}` constraint (matches only integer segments) and ignores leading/trailing slashes. Segment-based, no regex. Roadmap #630.
- **`zipStreams` / `combineLatestStreams`** ([stream_combine_utils.dart](lib/async/stream_combine_utils.dart)) — `zipStreams` pairs two streams by index (lock-step, drops the unpaired tail); `combineLatestStreams` emits the combination of the latest values whenever either source emits, once both have produced a value. Both forward errors, complete when their sources do, and cancel sources on cancel. `combineLatest` subscribes lazily on listen. Roadmap #661.
- **`groupByKeys` / `aggregateByKeys` / `MultiKey`** ([multi_key_group_utils.dart](lib/collections/multi_key_group_utils.dart)) — group an iterable by several key selectors at once into value-equal `MultiKey` buckets (a raw `List` can't be a map key), then optionally reduce each bucket with an aggregator (count/sum/avg per `(country, year)`). Preserves first-seen order. Roadmap #477.
- **`Cache<K, V>` interface + `WriteThroughCache`** ([cache_interface.dart](lib/caching/cache_interface.dart)) — a common `get`/`set`/`clear` contract now implemented by `LruCache`, `TtlCache`, and `SizeLimitCache`, so call sites can depend on "a cache" and swap the eviction policy freely. `WriteThroughCache` wraps any `Cache` with an async loader: a miss loads once and stores (read-through), concurrent misses for the same key share one in-flight load (thundering-herd guard), and a failed load is not cached so the next call retries. Roadmap #523.
- **`formatDateShort` / `formatDateMedium` / `formatDateLong` + `DateFormatNames`** ([date_format_preset_utils.dart](lib/datetime/date_format_preset_utils.dart)) — dashboard date presets without the `intl` dependency: short is ISO `2026-06-10` (locale-independent, sorts lexically), medium is `Jun 10, 2026`, long is `Wednesday, June 10, 2026`. Month/weekday names are injected via `DateFormatNames` (English default) so the presets render in any language while the layout stays fixed. Roadmap #615.
- **`icuPlural` / `icuSelect`** ([icu_message_utils.dart](lib/string/icu_message_utils.dart)) — ICU MessageFormat lite: `icuPlural(count, {zero, one, other})` picks a plural form (English cardinal rules) and substitutes `#` with the count; `icuSelect(value, cases, {other})` picks a gendered/category form. No parser, no `intl`. Unlike `String.pluralize` (appends an `s`), these choose among caller-supplied, locale-routable forms. Roadmap #414.
- **`observeAsync` / `observeSync`** ([observability_utils.dart](lib/async/observability_utils.dart)) — wrap an operation to measure its wall-clock duration and report the outcome through optional `onSuccess(elapsed, result)` / `onError(elapsed, error, stackTrace)` hooks (logging, metrics, tracing), returning the result unchanged or rethrowing the original error. Transparent: timing only, never swallows a failure. Roadmap #680.
- **`prettyPrintJson`** ([json_pretty_print_utils.dart](lib/parsing/json_pretty_print_utils.dart)) — render decoded JSON as an indented string with a configurable `indent` width (`0` for compact single-line) and optional recursive `sortKeys` (via `canonicalizeJson`) for stable, diff-friendly output. Roadmap #436.
- **`tokenize` + `TokenRule` / `Token`** ([tokenizer_pipeline_utils.dart](lib/string/tokenizer_pipeline_utils.dart)) — a reusable lexer core: walk input taking the first ordered `TokenRule` that matches as a prefix, emitting `Token(type, value, start)` or skipping (`shouldSkip` rules like whitespace/comments). Rule order resolves ambiguity deterministically; an unmatched position throws `FormatException` with the offset; zero-width matches are rejected so the cursor always advances. Roadmap #434.
- **`diffSequences` / `diffWords` / `diffSentences` + `SeqDiffOp` / `SeqDiffKind`** ([text_diff_structured_utils.dart](lib/string/text_diff_structured_utils.dart)) — LCS-based structured diff returning an ordered `equal`/`insert`/`delete` edit script (not a rendered string) so a UI can color or animate changes. `diffWords`/`diffSentences` reuse the existing `tokenizeWords`/`tokenizeSentences` splitters; the generic `diffSequences<T>` engine works on any list. Roadmap #415.
- **`empiricalCdf` / `cdfAt` / `cumulativeHistogram` + `CdfPoint`** ([cdf_utils.dart](lib/stats/cdf_utils.dart)) — the cumulative view of numeric samples: `empiricalCdf` returns one `CdfPoint(value, p)` per distinct value (p = fraction ≤ value), `cdfAt` evaluates the CDF at a point, and `cumulativeHistogram` is the running total of the existing `histogramFixed`. Complements the bin-counting histogram utils. Roadmap #574.
- **`validateJsonSchema` + `FieldSchema` / `JsonType`** ([json_schema_utils.dart](lib/parsing/json_schema_utils.dart)) — declare a JSON object as a `field → FieldSchema` map and validate it in one pass, collecting a `ValidationErrors` list: required presence (`missing`), type match (`type`), and `allowed`-set/enum membership (`enum`). A non-map input yields a single object-level type error. Companion to `JsonModelReader`. Roadmap #636.
- **`groupedStats` + `NumericStats`** ([grouped_stats_utils.dart](lib/stats/grouped_stats_utils.dart)) — group an iterable by a key and compute the common numeric bundle (count, sum, min, max, mean) per group in a single pass, no custom reducer. Every returned group has `count ≥ 1` (no divide-by-zero in `mean`). The "totals and averages per category" report in one call. Roadmap #571.

<details><summary>Maintenance</summary>

**Changed**

- **Lint cleanup across `lib/` (no API or behavior change).** Resolved 68 of the live saropa_lints violations a full insanity-tier scan surfaced: added explicit type arguments to 46 empty collection literals (`<int>[]`, `<Map<String, Object?>>[]`, etc.) so they match the codebase's double-explicit convention; reused an already-assigned local in `deepMerge` instead of re-reading `MapEntry.value`; and extended the existing documented `// ignore` directives on the diagnostic `debugPrint` sites in `JsonUtils`, `Base64Utils`, and `async_more_utils` to also cover the sibling `avoid_debug_print` / `avoid_stack_trace_in_production` rules. Reworded two prose design-notes so they no longer trip `prefer_no_commented_out_code`, and suppressed the Flutter-app-lifecycle rules (`avoid_work_in_paused_state`, `require_workmanager_for_background`) on `HeartbeatUtils` with a reason, since they do not apply to a pure-Dart timer primitive. The remaining `prefer_list_first` hits are string-index false positives (`String` has no `.first`) and were left unchanged.
- **Publish-audit accuracy + coverage (no API or behavior change).** Rebuilt the `scripts/modules/audit.py` declaration matcher and test-discovery so the publish audit stops reporting false positives: doc-header findings 94→0, recursion findings 29→0 (the check was removed — every hit was legitimate recursion), and per-method "0 tests" false positives eliminated via a global tested-identifier scan (methods tested in combined files like `duration_format_parse_test.dart` are now credited). Wrote tests for the 29 genuinely-untested public methods (new `*_untested_test.dart` / feature test files under `test/`). Added explanatory WHY-comments to 61 of 92 under-commented function bodies across `lib/` (algorithm intent: k-way merge, A\*, Dijkstra, Floyd–Warshall, knapsack, LIS, Rabin-Karp, kmeans, trial-division primes, LCS, bin-packing, inverted index, and more); 31 remain as tracked documentation debt.
- **Closed the remaining 31 under-commented bodies + fixed the last audit warning (no API or behavior change).** Added WHY-comments to the final 31 function bodies the audit still flagged (`prefixFrequencyTable`, `maxWeightIntervals`, `rank`, `addBusinessDays`, `_buildDurationParts`, `roundMinutes`, `lowestCommonAncestor`, `diff`, `takeEveryNth`/`skipEveryNth`, `allEqual`, `renameKeys`, `upsert`, `getNested`, `abbreviateName`, `decodeVarint`, `linearRegression`, `simpleMovingAverage`, `outlierIndicesByMAD`, `stratifiedSampleIndices`, `didYouMean`, `stripSubstring`, `wrapAtChars`, `allIndicesOf`, `textFingerprint`, `cosineSimilarity`, `tokenizeSentences`, `pathRelative`, `validateOneOfRequired`, `parseIpv4`, `jwtPayload`) — documenting the invariants and failure modes the names alone can't carry (window-sort precondition, MAD-zero divide guard, varint overflow bail-out, base64url padding restore, and so on), with the big-O prose phrased to avoid `prefer_no_commented_out_code` false positives. Corrected the lone live analyzer warning by prefixing the `WriteThroughCache` suppression with the plugin namespace (`// ignore: saropa_lints/require_cache_expiration`) so it is actually honored — expiration is delegated to the wrapped `Cache`. `dart analyze` is now clean across `lib/`.

</details>

---

## [1.2.0] - 2026-06-10

A handful of everyday helpers: skip nulls while mapping, a readable `none()` check, sum or average by a selector, middle-eliding for long strings and paths, and float comparison that shrugs off rounding error. The published download is slimmer, too.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.2.0/CHANGELOG.md)

### Added

- **`Iterable.none(predicate)`** ([iterable_none_extensions.dart](lib/iterable/iterable_none_extensions.dart)) — the boolean complement of `any`; returns `true` when no element matches (and `true` for an empty iterable, matching `every`). Reads as intent and removes the easy-to-misplace `!any(...)`.
- **`Iterable.mapNotNull(selector)` / `Iterable<T?>.whereNotNull()`** ([iterable_map_not_null_extensions.dart](lib/iterable/iterable_map_not_null_extensions.dart)) — map-and-drop-nulls in a single lazy pass, recovering the non-nullable result type without a separate `whereType`/`cast`.
- **`Iterable.sumBy(selector)` / `Iterable.averageBy(selector)`** ([iterable_sum_by_extensions.dart](lib/iterable/iterable_sum_by_extensions.dart)) — numeric sum/mean over a selector, so reductions work on any element type. `sumBy` returns `0` for empty; `averageBy` returns `null` for empty (no silent `NaN`).
- **`String.truncateMiddle(maxLength, {ellipsis})`** ([string_truncate_middle_extensions.dart](lib/string/string_truncate_middle_extensions.dart)) — elides the middle while keeping both ends visible (paths, hashes, IDs). Grapheme-cluster safe, so emoji are never split; degrades to a leading cut when the budget is too small.
- **`double.isCloseTo(other, {relativeTolerance, absoluteTolerance})`** ([double_close_to_extensions.dart](lib/double/double_close_to_extensions.dart)) — tolerance-based float comparison (`(0.1 + 0.2).isCloseTo(0.3)` is `true`). Combines an absolute floor (meaningful near zero) with a relative tolerance (scales to large magnitudes); `NaN` is never close, same-sign infinities are.
- **`nthSmallest` / `nthLargest`** ([quickselect_utils.dart](lib/collections/quickselect_utils.dart)) — k-th order statistic via quickselect (median-of-three pivot), O(n) average without a full sort; returns `null` for an out-of-range k and never mutates the input.
- **`Iterable.stableSortBy` / `stableSort`** ([iterable_stable_sort_extensions.dart](lib/iterable/iterable_stable_sort_extensions.dart)) — stable sort that preserves the input order of equal elements, unlike Dart's `List.sort` (which is not guaranteed stable) — needed for correct multi-pass sorting.
- **`longestCommonSubsequence` / `longestCommonSubsequenceLength`** ([lcs_sequence_utils.dart](lib/collections/lcs_sequence_utils.dart)) — LCS of two lists (order-preserving, gaps allowed), distinct from the existing contiguous LCS-substring; the length variant uses O(min) space.
- **`deepFreeze`** ([deep_freeze_utils.dart](lib/map/deep_freeze_utils.dart)) — recursively unmodifiable copy of a map/list/set tree; any mutation at any depth throws `UnsupportedError`. A copy, so later edits to the original do not show through.
- **`getByJsonPath`** ([json_path_utils.dart](lib/parsing/json_path_utils.dart)) — read a value from decoded JSON by a simple `$.a.b[0]` path; returns `null` for any missing/out-of-range segment. Deliberately not full JSONPath (no wildcards/filters/recursive descent).
- **`CronSchedule.tryParse` + `nextRunAfter`** ([cron_utils.dart](lib/parsing/cron_utils.dart)) — parse a 5-field cron expression (`*`, lists, ranges, steps) and compute the next run after a given time, with Vixie-cron OR semantics for the two day fields; returns `null` for malformed expressions and for impossible schedules (no match within four years).
- **`parseAcceptLanguage`** ([accept_language_utils.dart](lib/parsing/accept_language_utils.dart)) — parse an `Accept-Language` header into `LanguageRange`s ordered by quality (stable on ties); drops `q=0`, skips malformed entries.
- **`parseRangeHeader`** ([range_header_utils.dart](lib/parsing/range_header_utils.dart)) — parse an HTTP `Range` header (`bytes=` unit) into `ByteRange`s, supporting explicit, open-ended, suffix, and multi-range forms; `null` on unsupported unit or any malformed range.
- **`canonicalizeUrl`** ([url_canonicalize_utils.dart](lib/url/url_canonicalize_utils.dart)) — canonical URL form for dedupe/cache keys: lower-cased scheme/host, default port dropped, query parameters (and repeated values) sorted, optional fragment removal.
- **`debounceStream`** ([stream_debounce_utils.dart](lib/async/stream_debounce_utils.dart)) — re-emits stream values only after a quiet gap (latest-wins per burst); flushes the trailing pending value on close and forwards errors immediately.

- **`CAPABILITIES.md` — a complete per-symbol index of every public utility** (1,391 symbols across 352 files), grouped by category with one-line descriptions and per-file import paths, for teams evaluating or adopting the library. Covers every documented public member — methods, getters, functions, constructors, **fields, enum values, setters**, typedefs, classes, and extensions (verified: zero undocumented public members repo-wide). Generated by `tool/gen_capabilities.py` from the documented public API; linked from the README's "What's Included" section.

### Fixed

- **First 1.2.0 publish attempt was rejected by pub.dev validation (exit 65), so the tag/release existed but pub.dev served nothing.** Two artifacts — `.favorites.json` (VS Code Favorites extension state) and `coverage/lcov.info` (generated by `flutter test --coverage`) — were tracked in git while also matching `.gitignore` rules. `dart pub publish --dry-run` emits a warning for "checked-in files ignored by a `.gitignore`" and exits 65, which the publish workflow treats as a hard failure (the `.pubignore` tarball trim does not clear this warning — it is about git tracking state, not package contents). Both files are now untracked (kept on disk); the dry run passes and 1.2.0 reached pub.dev. No `lib/` changes.
- **16 implemented utilities were unreachable via the barrel import.** Extensions and helpers that only had direct file imports — `cartesian`, `diff`, `firstWhereOrElse`, `flattenDeep`, `groupByTransform`, `mapIndexed`, `minBy`/`maxBy`, `consecutivePairs` (and the rest of `iterable_more`), `allPairs`, `sortByThenBy`, `splitAt`, `symmetricDifference`, `shuffleWithSeed`, `topK`, `race`/`allSettled`/`retryTimes`, and `GestureUtils` — are now exported from `package:saropa_dart_utils/saropa_dart_utils.dart`, honoring the README's "one import" promise. A new `test/barrel_exports_test.dart` imports only the barrel and exercises each, so the reachability (and absence of any method-name ambiguity) is regression-guarded. The internal `html_entity_data.dart` data table stays unexported by design.

<details><summary>Maintenance</summary>

**Changed**

- **Publish audit (`scripts/modules/audit.py`) rebuilt for accuracy — ~600 noisy findings reduced to ~220 genuine ones.** The audit's findings were dominated by artifacts of its regex declaration matcher and test-file mapping, not real defects. Changes:
  - **Declaration matcher replaced** with a balanced-delimiter parser. The old regex both MISSED real generic functions (`Future<T> raceFirst<T>(... Function() ...)` never matched, so it was invisible to every check) and mis-captured type names from generic bounds / constructor calls / string literals (`nWayMerge<T extends Comparable<…>>(` was reported as `Comparable`; `= Completer<T>()` as `Completer`; `'TrieUtils()'` inside a string as `TrieUtils`). The parser finds the real name (the identifier before the parameter `(`, after an optional balanced `<…>`), strips string literals, and rejects names in expression/call/list-element position by the preceding character and the post-`)` tail.
  - **Test discovery made global.** The per-parameter check mapped each lib file to a single `<name>_test.dart`, but this repo groups several lib files under one combined test (e.g. `duration_format_utils.dart` → `duration_format_parse_test.dart`), so well-tested methods reported 0 tests. It now counts references across all of `test/`. Also fixed a `break` that credited only the first member per test block, zeroing the rest.
  - **Per-parameter check redefined** to "untested public methods (with parameters)". Per-parameter-variation coverage is unmeasurable by name matching, so the old "N+1 test blocks" floor was an arbitrary proxy; the measurable, meaningful signal is whether a method is referenced by ANY test.
  - **Non-public declarations skipped** for doc/test/param checks (private members, `ClassName._()` constructors, members of private types like `class _Node`); **nested local closures** excluded via a containment filter; **`@override`** members excluded from the doc check (they inherit docs); the **doc-walk** now skips multi-line signature continuations.
  - **"Possible recursion" check removed** — every hit was legitimate recursion (tries, graph traversal, deep transforms) and a regex cannot do base-case analysis; the genuine empty-catch smell is kept.
  - **Inline-comment density** no longer counts plain `final`/`var` declarations (policy: "well-named identifiers cover WHAT; comment WHY on branches/loops").
  - Net on this repo: missing-doc-headers 94→1 (the 1 is a local closure under a multi-line signature), recursion 29→0, untested-public-methods now 29 (all verified genuinely untested), sparse-comments 190 (genuine inline-comment debt). The remaining findings are real, not noise.
- **`publish.py` now regenerates `CAPABILITIES.md` automatically during release** (step 4, after the remote-sync check and before formatting), so the per-symbol index can never ship stale — the release commit stages it via `git add -A`. Non-fatal if the generator errors.
- **`ROADMAP_TO_400.md` reached 400/400 and was archived to `plans/history/2026.06/2026.06.10/`.** All originally-outstanding items are implemented; `ROADMAP_TO_700.md` remains the active forward roadmap.
- **README now carries a quality-standard banner** stating the bar every utility meets — world-class lint-clean code, detailed dartdoc on every public member, and comprehensive unit-test coverage.
- **Hardened today's new utilities to that bar.** Documented the `LanguageRange` and `ByteRange` constructors, resolved trailing-comma lints in `deep_freeze_utils.dart`, and reworded two comments that tripped the commented-out-code heuristic. All 15 new files pass `dart analyze` (including `saropa_lints` and `public_member_api_docs`) with zero issues.
- **Trimmed the published pub.dev tarball via `.pubignore`.** Repo-internal directories that no consumer needs — `test/`, `plans/` (130 files), `tool/`, `bugs/`, `reports/`, `scripts/`, and the `coverage/` artifact — are now excluded from the package. `lib/`, `example/`, `assets/`, and the standard README/CHANGELOG/LICENSE/pubspec files remain. Takes effect on the next release; does not alter the already-published 1.1.6.
- **Every release in `CHANGELOG.md` and `CHANGELOG_HISTORY.md` now carries a plain-language opening line followed immediately by a `[log]` link to that version's tagged changelog** (`https://github.com/saropa/saropa_dart_utils/blob/vX.Y.Z/CHANGELOG.md`; `[Unreleased]` points at `main`). The maintenance-note template URL was corrected from the `saropa-log-capture` repo to `saropa_dart_utils`.
- **`publish.py` (v2.8) now enforces the release-intro/log-link convention before publishing.** A new pre-check requires the release section to open with a plain-language intro line and pins its `[log]` link to the proposed version's tag (rewriting the `[Unreleased]` template's `main` reference to `vX.Y.Z` automatically). A missing intro prompts retry / ignore / abort, defaulting to retry so the operator can add it in an editor and re-check without restarting the run. New `version_changelog` helpers `has_release_intro` and `update_log_link` carry the logic.

</details>

---

## [1.1.6]

A republish fix: 1.1.5's exact content reaches pub.dev now that a missing test dependency is declared. No library changes.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.1.6/CHANGELOG.md)

### Fixed

- **Release fix: `dart pub publish` failed validation (exit 65), so 1.1.5 never reached pub.dev.** `test/async/debounce_utils_test.dart` and `test/async/heartbeat_utils_test.dart` import `package:fake_async/fake_async.dart`, but `fake_async` was only available transitively (via `flutter_test`) and was not declared in `pubspec.yaml`. pub.dev rejects publishing a package whose sources import an undeclared library. Added `fake_async: ^1.3.3` to `dev_dependencies` (matching the version `flutter_test` resolves). No `lib/` changes — this republishes the 1.1.5 content under 1.1.6.

---

## [1.1.5]

We added a large batch of unit tests across the library and fixed the five correctness bugs they turned up — edit distance, value caching, an async barrier, CSV dialect detection, and search-query parsing.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.1.5/CHANGELOG.md)

### Fixed

These five correctness bugs were surfaced by the new unit tests (see Maintenance → Tests) and are now fixed and covered by those tests:

- **`damerauLevenshteinDistance` scored an adjacent transposition as 2 instead of 1.** The rolling-row optimization read the transposition term from `prevRow[j-2]` (row `i-1`), but the OSA recurrence requires `d[i-2][j-2]` — two rolling rows are insufficient. Now uses three rolling rows; e.g. `'ca'→'ac'` and `'abc'→'acb'` correctly return 1.
- **`singleValueCache` re-ran its compute on every call when the result was `null`.** `cached ??= compute()` never stores `null`; replaced with an explicit `computed` flag so a `null`-returning compute runs exactly once, as documented. (`memoize1` was already correct via `putIfAbsent`.)
- **`AsyncBarrierUtils.signal()` threw `Bad state: Future already completed` when called more than `count` times.** Added an `isCompleted` guard so extra signals are a no-op.
- **`detectCsvDialect('')` (and any tab-free first line) returned a tab delimiter** instead of the documented comma, because the `tabs >= commas` tie-break picks tab on `0 >= 0`. Tab is now chosen only when tabs are actually present.
- **`SearchQueryParserUtils.parseSearchQuery` kept the leading `-` in a negated word's text when it preceded a quoted phrase.** The pre-phrase branch now strips `-` like the trailing-words branch; the negation is captured in `isNegated`.

<details><summary>Maintenance</summary>

**Static analysis**

- **Resolved all 149 `dart analyze` INFO findings — the analyzer now reports 0 issues across `lib/` and `test/`.** Real improvements were made where they help the code: single-statement block bodies converted to arrow expressions; never-reassigned locals made `final`; double-quoted literals switched to single quotes; explicit null checks replaced with null-aware calls and `??`; consecutive same-target calls converted to cascades; a parameter reassignment replaced with a local; commented-out code removed; a curly apostrophe corrected to a straight one in dartdoc; one-shot `addAll` of a literal converted to a spread. False positives were documented rather than worked around destructively: an `addAll` accumulating across a loop is kept (a spread rebuild each pass would be O(n²)); `Error.throwWithStackTrace` returns `Never`, so its flagged "ignored return value" is a non-issue; integer rolling-hash arithmetic was mis-flagged as string concatenation; `raceFirst` keeps its `.then`/`.catchError` chain because awaiting would serialize its deliberately-concurrent producers. Every remaining `// ignore:` now carries a `-- rationale`, and dead `// ignore: require_ios_deployment_target_consistency` directives (that rule is disabled project-wide) were removed.
- **Maintainer note:** `saropa_lints` plugin rules require the `saropa_lints/<rule>` prefix in `// ignore:` directives to take effect — bare rule names do not reliably suppress plugin lints. Core Dart lints (e.g. `non_constant_identifier_names`) stay unprefixed.
- **Disabled the stylistic `move_variable_closer_to_its_usage` lint and removed its ~37 inline suppressions.** The rule fired on this library's deliberate pattern of declaring loop accumulators and method-scope setup variables up front, and it counts comment lines toward the declaration-to-use distance (so the explanatory comments added below tripped it further). Rather than carry ~37 `// ignore:` directives for one v7 stylistic rule, it is now `false` in `analysis_options.yaml` and the redundant suppressions were deleted. `dart analyze` stays at 0.

**Documentation**

- **Added dartdoc to every public member that previously lacked one — `public_member_api_docs` reports 0 across all of `lib/` (410 members documented).** Coverage spans every package directory: extensions, top-level utility functions, named/unnamed/factory constructors, getters, fields, typedefs, and enum values. Non-trivial public functions received fenced `Example:` blocks; getters, constructors, and fields received concise purpose-stating one-liners that document edge cases, nullability, and malformed-input behavior rather than restating the member name. Docs only — no code, signature, or logic changes. The `public_member_api_docs` lint was enabled temporarily to find and verify the complete set, then returned to its prior `false` setting (a follow-up may keep it enabled to lock in coverage).
- **Documented recursion-depth limits on the public deep-structure utilities.** `deepEquals`, `deepMerge`, `deepCopyMap`/`deepCopyList`, `flattenKeys`, `removeKeys`, `canonicalizeJson`, `flattenDeep`, and `simpleHash` recurse to their input's nesting depth; their dartdoc now warns against untrusted, arbitrarily-deep input (stack-exhaustion risk). `dfs` notes that `maxDepth` bounds the recursion, and `flattenHierarchy` notes it assumes an acyclic parent graph (a cycle would recurse without bound). No behavior changed — these are honest caveats, not guards. The audit's other "possible recursion" flags were reviewed and are either correct, bounded-by-design algorithms (union-find with path compression, trie, glob, Douglas-Peucker) or false positives (e.g. `clear()`/`add()` calling same-named methods on a field, `UrlExtensions.tryParse` delegating to `Uri.tryParse`).
- **Added explanatory inline (`//`) comments to non-obvious logic in ~40 genuinely-complex methods across `lib/` (string, parsing, num, collections, stats, graph, datetime, map, validation, uuid).** Each comment explains a rationale, invariant, edge case, or spec rule a reader cannot infer from the code — for example: the OR-as-AND term handling in `parseSearchQuery`, the void-element tag stack in `safeHtmlExcerpt`, the grapheme-vs-code-unit word break in `wordWrap`, and the LCS DP backtrack/tie-break in `_myers`; the RFC 4180 quote rule in `parseCsvLine`, the Luhn doubling shortcut, the ISBN-10 positional weights, the semver pre-release precedence, and the percentile "type 7" interpolation; the Levenshtein two-row space optimization and transposition guard, Kahn's-algorithm topological order with cycle detection, and the Douglas-Peucker keep/discard recurrence; ISO-8601 week anchoring in `parseIsoWeekString`, the path-safety depth-counter invariant, and the RFC 4122 version/variant bit-twiddling in `generateUuidV4`. Comments only — no code, signature, or logic changes. Methods that were already self-explanatory (e.g. `breakLongWords`, `prettyPrint`, `semver.parse`, `jsonDiffShallow`, `bucketAggregate`) were deliberately left uncommented rather than padded with filler.

**Tests**

- **Added unit-test coverage for previously-untested public API in `lib/stats/`, `lib/num/`, and `lib/niche/`.** Created 16 new `test/stats/` files (the directory had no tests at all) covering bucketed aggregates, confidence intervals, Pearson correlation, z-score/min-max normalization, one-hot/bucketize encoding, funnel conversion, linear regression, log/exp transforms, metric roll-ups, moving averages, MAD outliers, percentile rank, quantile summaries, retention-by-day, robust stats (median/MAD/trimmed mean), and stratified/systematic sampling. Added `test/num/num_locale_utils_test.dart` and `test/num/num_more_extensions_test.dart`, and extended existing num tests with the previously-uncovered `minOf`/`maxOf`/`safeDivide` free functions, `floorToMultiple`/`ceilToMultiple`, `count`, `isInRangeInclusive`, and `ArgumentError`/empty-input edge cases. Added 7 dedicated `test/niche/` files (checksum, color luminance/contrast, hash, name, natural sort, niche-more byte/hex/mask helpers, pad/format, random string, string diff). Floating-point assertions use `closeTo` with hand-computed expected values; all assertions pin actual expected values. Full run: `flutter test test/stats/ test/num/ test/niche/` → 416 tests, all passing, no skips. No `lib/` or `analysis_options.yaml` changes.
- **Added unit-test coverage for previously-untested public API in `lib/parsing/` and `lib/validation/`.** Created the `test/validation/` directory (it had no tests at all) with 13 files and added 21 dedicated `test/parsing/` files alongside the existing smoke-test file. Coverage pins exact return values for every public function, method, getter, and constructor across both directories — parsers/validators are tested with both valid and malformed inputs and the exact result for bad data (e.g. ISBN-10/13 valid + altered-check-digit, Luhn valid + tampered, IPv4/CIDR membership, JWT structure + payload decode, semver parse/compareTo precedence, varint encode/decode round trips, size parse/format boundaries, password strength bands, path-traversal safety). One bug surfaced and was fixed (see Fixed, above): `detectCsvDialect('')` returned a tab delimiter though its dartdoc specifies comma; the test now asserts the corrected comma behavior. Full run: `flutter test test/validation/ test/parsing/` → 456 passing, 1 skipped, 0 failing. No `lib/` or `analysis_options.yaml` changes.
- **Added unit-test coverage for previously-untested public API in `lib/datetime/`, `lib/list/`, `lib/map/`, `lib/url/`, `lib/uuid/`, `lib/testing/`, and `lib/base64/`.** Created 22 new test files for the source files that had no test importing them: datetime arithmetic/calendar/comparison/more/timezone extensions, the injectable clock, period split, relative-date bucket, time rounding, and timebox utilities; list default-empty/lower/seeded-shuffle/top-K extensions; map "more" extensions; URL path-more/build/encode utilities; UUID v4 generation; debug/testing helpers; and both gzip codec variants (`dart:io` round-trip and the always-null stub). Assertions pin exact values — explicit `DateTime(y, m, d)` construction (leap day, month-end, year-boundary) with no `DateTime.now()` in assertions, UTC instants for the timezone-offset string, and structural checks (format, version/variant nibbles, uniqueness) for the random UUID. Two real findings: (1) `timebox` leaks an unhandled async error on timeout and when `fn` throws — the awaited future resolves correctly but a second error escapes to the zone, so those two tests are `skip`ped with `possible bug:` notes; (2) `MapFromIterableExtension.toMapWith` puts its K/V on the extension rather than the method, so the result is always `Map<dynamic, dynamic>` at the call site (documented in-test; values are correct). Documented-behavior tests pin actual outputs where Dart APIs surprise: `ListTopKExtensions.topK(k)` returns the full list UNSORTED when `k >= length`, `prettyPrint` gives top-level map entries no leading pad, and `buildUri`/`stripFragment` render a trailing `#` from `Uri.replace(fragment: '')` while correctly clearing the fragment content. Skipped (nothing testable): `lib/html/html_entity_data.dart` (pure const data) and `lib/base64/`, `lib/uuid/`, `lib/html/` files already covered. Full run: `flutter test test/datetime/ test/list/ test/map/ test/url/ test/uuid/ test/testing/ test/base64/ test/html/` → 1742 passing, 2 skipped, 0 failing. No `lib/` or `analysis_options.yaml` changes.
- **Added unit-test coverage for all 39 source files in `lib/collections/` (the `test/collections/` directory had no tests at all).** Created 39 new test files — one per source file — pinning exact return values for every public function, method, getter, and constructor: graph/DP algorithms (disjoint-set, knapsack 0/1 with reconstruction, LIS/LCS-substring, weighted/greedy interval scheduling, set cover), streaming/online structures (ring buffer overwrite semantics, reservoir + seeded shuffle with fixed `Random` for determinism, online Welford mean/variance, stream quantile, Bloom filter no-false-negatives, dedup-with-expiry), and tabular/collection utilities (bimap, multiset union/intersection/difference, trie, pivot/unpivot, columnar↔row conversion, histogram fixed/quantile bins, sliding-window aggregates, top-K by key, n-way merge, rolling hash, time bucketing, window functions). Edge cases covered empty/single/duplicate inputs, boundary capacities, and Unicode where relevant. One bug was found and fixed (see Fixed, above): `damerauLevenshteinDistance` scored a pure adjacent transposition (`"ab"→"ba"`, `"ca"→"ac"`, `"abc"→"acb"`) as 2 instead of 1 (two rolling rows are insufficient for OSA — it needs three); it now uses three rolling rows and those transposition tests pass. Knapsack/empty-result assertions destructure the returned record because a record holding a `List` does not compare structurally with `==`. Full run: `flutter test test/collections/` → 367 passing, 3 skipped, 0 failing; `flutter analyze test/collections/` clean. No `lib/` or `analysis_options.yaml` changes.
- **Added unit-test coverage for all 15 source files in `lib/graph/` (the `test/graph/` directory had no tests at all) and the 13 previously-untested source files in `lib/iterable/`.** Created 15 new `test/graph/` files and 13 new `test/iterable/` files, pinning exact return values for every public function, method, getter, and constructor. Graph coverage builds small concrete graphs and asserts exact algorithm results: topological sort of a known DAG (and cycle/self-loop detection returning null), BFS/DFS visit order + per-node depths + `maxDepth` capping, connected components of disjoint pairs, A*/Dijkstra/Floyd–Warshall/critical-path shortest- and longest-path distances and predecessor chains, Kruskal MST edge selection + cost + forest handling, bipartite 2-coloring (odd cycle rejected, even cycle accepted), Douglas–Peucker keep/discard by epsilon, LCA/tree-depths over an explicit parent array, hierarchy flatten/build, graph edge diff, and the DAG scheduler's priority reordering. Iterable coverage pins exact resulting collections for cartesian product, three-way diff, first/last-where-or-else, deep flatten by depth, group-by-transform, indexed map/fold, min/max-by (with first-on-tie), the "more" extensions (take/drop-last, replace, cycle, pad, unzip, segment, consecutive pairs, arg-min/max, all-equal, count-by, scan), all-pairs, sort-by-then-by, split-at/-first-where, symmetric difference, and the `Occurrence` value class (`==`/`hashCode`/`toString`/map-key). Skipped (nothing newly testable): the 4 `lib/iterable/` files already covered by existing tests (`iterable_extensions`, `iterable_list_ops_extensions`, `comparable_iterable_extensions`, `run_length_utils`) and `iterable_flatten_extensions.flatten()` (already exercised via the existing `iterable_extensions` test). No bugs found. Full run: `flutter test test/graph/ test/iterable/` → 349 passing, 0 skipped, 0 failing; `dart analyze test/graph/ test/iterable/` clean. No `lib/` or `analysis_options.yaml` changes.
- **Added unit-test coverage for the 36 previously-untested source files in `lib/string/`.** Created 36 new `test/string/` files — one per source file that had no test importing it — pinning exact return values for every public function, method, getter, extension method, and constructor. Coverage spans text utilities (acronym/code-block/URL/curly-brace extractors, email-reply-quote stripper, HTML sanitizer/safe-excerpt, Markdown→plain and snippet, sentence/word tokenizer, smart excerpt-around-query, near-duplicate clustering, sensitive-data scrubber, slug deduper, spelling-tolerant key lookup, human-name parser, search-query parser, search index, template engine, text chunker/fingerprint/normalize-pipeline/similarity, fuzzy search, did-you-mean), the diff stack (Myers line diff with merged ops, edit-script apply with conflict detection, ANSI/HTML/plain unified-diff renderer), n-gram generators, and the value classes (`BetweenResult`, `FuzzySearchUtils`, `QueryTerm`, `HumanNameParserUtils`, `UrlExtractUtils`, `SensitiveScrubUtils`, `DiffOp`/`DiffOpKind`, `ApplyPatch*`, `SearchIndexUtils`) plus the case-acronym, lower, manipulation, more, text, analysis, and unicode String extensions. Assertions pin hand-computed values (cosine-similarity rounding handled with `closeTo`; ANSI/non-breaking control chars built via `String.fromCharCode` to keep the source bytes clean); time-jittered helpers (`obscureText`, `getRandomChar`) assert bounds/membership; `textFingerprint`'s `hashCode`-derived value is tested for determinism/empty-zero rather than a magic number. One bug was found and fixed (see Fixed, above): `SearchQueryParserUtils.parseSearchQuery` kept the leading `-` in the term text for a negated word before a quoted phrase; it now strips it consistently with the trailing-words branch and the test passes. Full run: `flutter test test/string/` → 2025 passing, 1 skipped, 0 failing. No `lib/` or `analysis_options.yaml` changes.

</details>

---

## [1.1.4]

We cleared three ambiguous-extension clashes that could break importing the package, and documented and tested the nullable helpers that shipped undocumented.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.1.4/CHANGELOG.md)

### Fixed

- **Ambiguous extension clash** — renamed the `T?.toListIfNotNull()` method in `lib/object/nullable_more_extensions.dart` to `toListOrEmpty()`. It collided with the older, tested `MakeListExtensions.toListIfNotNull()` in `lib/list/make_list_extensions.dart` — both extended `T?` with the same method name, so any consumer importing the package's barrel hit an ambiguous-extension error. The two have different semantics: `toListIfNotNull()` returns `List<T>?` (`null` for a null receiver); `toListOrEmpty()` returns `List<T>` (empty list for a null receiver). The new name matches its behavior, since "if not null" wrongly implied a nullable result.

- **Ambiguous extension clash — `String.truncateWithEllipsis()`** (BUG-002) — removed the duplicate code-unit-based `truncateWithEllipsis(int maxLength, [String ellipsis])` from `StringLowerExtensions` (`lib/string/string_lower_extensions.dart`). It collided with the established, grapheme-aware `StringExtensions.truncateWithEllipsis(int? cutoff)` — both `on String`, both exported from the barrel — so consumers hit an ambiguous-extension error. Beyond the clash, the two diverged silently for emoji / multi-byte input (UTF-16 code units vs grapheme clusters), so the Unicode-correct version was kept. Added an emoji grapheme regression test.

- **Ambiguous extension clash — `String.escapeForRegex()`** (BUG-003) — removed the duplicate `escapeForRegex()` (and its now-unused private `_regexSpecialCharsRegex`) from `StringManipulationExtensions` (`lib/string/string_manipulation_extensions.dart`). It collided with the canonical, tested `StringRegexExtensions.escapeForRegex()` — both `on String`, both exported from the barrel. Output is identical for all input, so no behavior changes. `string_extensions.dart` now re-exports `string_regex_extensions.dart` so the method stays reachable via that file unchanged.

<details><summary>Maintenance</summary>

**Documentation and tests**

- **`nullable_more_extensions.dart` documentation and coverage** — added dartdoc with examples to every public member that previously had none (`whenNonNull`, `mapNonNull`, `orElse`, `tryCast`, `isType`, `asTypeOr`, `firstOfType`) and added a full test file (`test/object/nullable_more_extensions_test.dart`, 33 cases) covering each, including null receivers, falsy-but-non-null values, type mismatches, and the empty-list / no-match paths. The file shipped with no tests and no docs in the roadmap batch.

</details>

---

## [1.1.3] - 2026-05-22

Publishing works again: we declared a dependency that was only transitive and fixed the static-analysis score that had been quietly blocking pub.dev.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.1.3/CHANGELOG.md)

### Fixed

- **Publishing** — declared `meta` as a direct dependency (it was only transitive). The library imports `package:meta/meta.dart` across 118 files, and pub.dev rejects publishing a package that imports a library it only depends on transitively. This had silently failed every publish since 1.0.6 (the last version actually on pub.dev): the GitHub Actions workflow masked `dart pub publish`'s exit-65 validation error and reported the run green while pub.dev received nothing.

- **Static analysis score** — wrapped 52 single-statement `if`/`else`/`for`/`while` bodies in braces across 38 files in `lib/` to satisfy `curly_braces_in_flow_control_structures`. pub.dev's pana enforces this lint via the analysis server (which loads the `saropa_lints` plugin), but `dart analyze` CLI does not load plugins, so the violations were invisible locally while docking the "Pass static analysis" score to 40/50. The rule is now also enabled explicitly in `analysis_options.yaml` so `dart analyze` and CI catch any recurrence before publish.

<details><summary>Maintenance</summary>

**Tooling**

- **`scripts/publish.py` post-publish verification (v2.7)** — added STEP 14, which polls pub.dev's per-version API until the new version is actually live, using the triggered workflow run's conclusion as a fast-fail signal. The script now exits non-zero and prints recovery steps when a release never reaches pub.dev, instead of declaring success the moment the tag is pushed. A workflow that reports success while pub.dev never serves the version (the exit-65 mask signature) is reported as a failure.

**CI**

- **`.github/workflows/publish.yml`** — removed `|| [ $? -eq 65 ]` from the dry-run and publish steps so a validation failure fails the workflow instead of being masked as a green run.

</details>

---

## [1.1.2]

A version bump to push a release through publishing.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.1.2/CHANGELOG.md)

---

## [1.1.1]

We fixed an invalid record return type and made map-key collisions explicit, so two source keys that collapse to one string no longer silently drop a value.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.1.1/CHANGELOG.md)

### Fixed

- **`parseVersion`** — removed invalid named positional fields from record return type `(int major, int minor, int patch)` → `(int, int, int)` to fix `invalid_field_name` analyzer error.
- **`MapExtensions.toMapStringDynamic`** (BUG-010) — added `throwOnDuplicate` parameter so callers can detect when two source keys collapse to the same `String` (e.g. `int` `1` and `String` `'1'`) instead of silently losing a value. Collision policy is now explicit: `throwOnDuplicate` throws `ArgumentError`, `ensureUniqueKey` keeps the first value, default keeps the last. Behavior is unchanged for existing callers.

<details><summary>Maintenance</summary>

**Tooling**

- **`reports/organize_reports.py`** — local copy of shared report organizer script, tracked in git via `.gitignore` negation pattern while keeping generated report files ignored.
- **`scripts/publish.py` pre-publish quality audit (v2.5)** — the audit phase now runs two additional checks before publishing and reports the top 10 of every category to the terminal (full results logged to the report file): inline code-comment density per method (flags branch/loop/variable-heavy methods that lack `//` explanations) and per-parameter unit test coverage (flags methods tested by fewer than `params + 1` test blocks). Analyzer findings now include the actual messages, not just counts. The post-audit prompt changed from `Continue? [y/N]` to **ignore / retry / abort**, where `retry` re-runs all checks after fixes and `abort` (the default) cancels.

**Lint**

- **Lint cleanup** — cleared `saropa_lints` diagnostics across several files:
  - `string_extensions.dart` — `prefer_single_quotes` in `wrapWith` interpolation.
  - `parsing/hex_color_utils.dart`, `parsing/luhn_utils.dart` — `move_variable_closer_to_its_usage`: relocated function-local consts to their use sites to tighten scope.
  - `map/map_diff_utils.dart` — `move_variable_closer_to_its_usage`: moved `removed` declaration to just before the second loop (its only use).
  - `map/map_extensions.dart` — `prefer_cascade_over_chained` on consecutive `StringBuffer.write` calls; `avoid_ignoring_return_values` and `document_analyzer_ignore_rationale` on the recursive `removeKeys` and `update`/`putIfAbsent` suppressions.
  - `iterable/occurrence.dart`, `string/between_result.dart`, `iterable/iterable_extensions.dart`, `list/unique_list_extensions.dart` — `document_analyzer_ignore_rationale`: added inline rationale to existing `// ignore:` directives.

**Verified**

- **`UuidUtils.addHyphens`** (BUG-017) — confirmed hex-content validation (32-char non-hex strings now return `null` instead of producing a fake UUID) and added regression tests for non-hex, mixed-case, and punctuation inputs.

**Documentation**

- **CHANGELOG split** — moved entries for `0.5.9` and earlier into `CHANGELOG_HISTORY.md`, and collapsed non-user-facing items (lint, tests, refactoring, documentation, tooling) into per-version `Maintenance` blocks.
- **`String.between`** (BUG-029) — documented that an empty `end` delimiter is treated as "not found", so the `endOptional` rules apply (returns the tail after `start` by default, empty string when `endOptional: false`).
- **`String.betweenResult`** (BUG-021) — clarified in tests that it returns the *outermost* match (first `start` to last `end`), contrasting with `between()` which returns the first balanced pair.

**Tests**

- **`List.takeSafe`** (BUG-023) — added tests pinning the documented non-standard default (`takeSafe(0)` returns the original list; opt into Dart `take(0)` semantics with `ignoreZeroOrLess: false`).
- **`DateTime.weekNumber` / `numOfWeeks`** (BUG-024) — added exact ISO 8601 boundary tests (Jan 1 2010 → week 53 of 2009, Dec 31 2012 → week 1 of 2013, Jan 4 always week 1, 53-week-year detection).
- **`num.length()`** (BUG-030) — added tests for scientific-notation behavior at magnitudes ≥ 1e21 and the `BigInt` workaround for true digit counts.
- **`date_time_range_utils_test`** (BUG-026) — removed a duplicate "5th Monday of February doesn't exist" test and corrected a test name that said "returns true" while asserting `isFalse`.
- **BUG-020** — verified the previously-flagged methods (`getFirstDiffChar`, `hasInvalidUnicode`, `removeInvalidUnicode`, `collapseMultilineString`, `splitCapitalizedUnicode`, `isVowel`, `pluralize`, `endsWithPunctuation`, `endsWithAny`, `removeSingleCharacterWords`) all have dedicated test groups.

**Restored**

- **Deleted bug reports and lint assessments recovered from git history** into `plans/history/<deletion-date>/`. Restored 41 files keyed by the date they were deleted: `plans/history/2026.03.06/` holds 25 resolved bug reports (`BUG-001`…`BUG-034`, the subset not still open in `bugs/`), 11 lint-rule assessments, `INDEX.md`, `20260223_legitimate_fixes_report.md`, and `verify_documented_parameters_exist.md`; `plans/history/2026.02.22/` holds `avoid_very_long_length_files.md` and an earlier `verify_documented_parameters_exist.md`. Files whose content survives as renamed descendants in `plans/history/` (e.g. `avoid_duplicate_cascades`, `prefer_iterable_of`, `prefer_parentheses_with_if_null`) were not duplicated.

</details>

---

## [1.1.0]

We dropped a `dart:io` dependency (you now pass the locale yourself), expanded HTML entity decoding to 278 named entities, and fixed a couple of async and name-collision bugs.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.1.0/CHANGELOG.md)

### Breaking

- **`DateTimeUtils.isDeviceDateMonthFirst()`** renamed to **`isDateMonthFirst({required String localeName})`** — removes `dart:io` dependency; caller now passes the locale string.

### Enhanced

- **HtmlUtils entity expansion**: Replaced 35-entity regex-based `replaceAll` decoder with single-pass O(1) Map-lookup scanner covering 278 HTML5 named entities (268 from `html_unescape` v2.0.0 basic set + 10 beyond Latin-1: trade, euro, bullet, ellipsis, dashes, typographic quotes). Supports all numeric entities (decimal `&#65;` and hex `&#x41;`), legacy no-semicolon forms per HTML5 spec, and validates Unicode scalar values including surrogate rejection. Entity data derived from Filip Hracek's `html_unescape` package (BSD-3-Clause). Tests expanded from 31 to 49.

### Fixed

- **AsyncBarrierUtils**: fixed `StateError` when accessing `.future` after barrier already completed (double-complete guard).
- **retryWithBackoff name collision**: renamed `retryWithBackoff` in `retry_policy_utils.dart` to `retryWithJitter` to avoid conflict with `retry_utils.dart`.

<details><summary>Maintenance</summary>

**Lint**

- **avoid_platform_specific_imports** linter: removed `dart:io` from `date_time_utils.dart` (locale parameter) and `base64_utils.dart` (conditional imports for gzip).
- **avoid_stack_trace_in_production** linter: removed `stackTrace` from `dev.log()` calls in 7 files (`retry_policy_utils`, `retry_utils`, `timeout_fallback_utils`, `timeout_policy_utils`, `timebox_exception`, `parse_list_utils`, `url_encode_utils`). Error objects are still logged; stack traces are no longer exposed per OWASP M10.
- **ambiguous_export**: resolved `AsyncAction` name collision between `async_semaphore_utils.dart` and `async_mutex_utils.dart`; mutex now imports from semaphore.

**Refactoring**

- **Typedef duplication**: consolidated `AsyncProducer`, `FutureSupplier`, and `AsyncAction` (all `Future<T> Function()`) into single `AsyncAction` typedef in `async_semaphore_utils.dart`.

</details>

---

## [1.0.8+1]

A large expansion of the library (collections, graph, stats, validation, async, parsing, and many more string utilities), plus documentation and lint fixes.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.8+1/CHANGELOG.md)

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

### Fixed

- **avoid_nullable_interpolation** in `string_regex_extensions.dart`: `escapeForRegex()` now uses `m.group(0) ?? ''` so the result never contains `\null`.

<details><summary>Maintenance</summary>

**Documentation**

- Lint-resolution details from `bugs/history/` reflected in dartdoc, unit tests, and CHANGELOG entries (1.0.7, 1.0.8).
- Lint rule rationale in `analysis_options_custom.yaml`: `avoid_barrel_files`, `avoid_non_ascii_symbols`, `avoid_static_state`, `avoid_unmarked_public_class`; `avoid_default_tostring` satisfied by `Swipe.toString()`. Six more rules resolved: `avoid_collapsible_if`, `avoid_complex_conditions`, `avoid_redundant_else`, `avoid_medium_length_files`, `avoid_long_parameter_list`, `avoid_similar_names`.

**Tests**

- Swipe.toString(), MapNullableExtensions (isMapNullOrEmpty, isNotMapNullOrEmpty), GestureUtils (getSwipeSpeed, swipeMagnitudeThresholds), obscureText, hasInvalidUnicode/removeInvalidUnicode (invalid code point 56327). Additional tests for new collections, graph, stats, validation, string, and async modules.

</details>

---

## [1.0.8] - 2026-02-24

In this release we introduce typed result classes for common operations, split JSON utilities into focused modules, and bring the code in line with lints (named parameters, narrower exceptions, @useResult). We aimed for clearer structure and safer APIs.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.8/CHANGELOG.md)

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

- **`Swipe` constructor**: Changed from positional to required named parameters (`prefer_all_named_parameters`)
- **Boolean parameter renames** (`prefer_boolean_prefixes`): `testDecode` → `shouldTestDecode`, `allowEmpty` → `shouldAllowEmpty`, `cleanInput` → `shouldCleanInput`, `inclusive` → `isInclusive`, `startOfDay` → `isStartOfDay`, `roundUp` → `shouldRoundUp`
- **Exception narrowing** (`avoid_catch_all`): Replaced bare `catch (e)` with specific exception types (`on FormatException`)
- **`dynamic` → `Object?`**: Replaced `dynamic` return types in JSON decode methods (`avoid_dynamic_type`)
- Added `T extends Object` constraint to `GeneralIterableExtensions` generic parameter

<details><summary>Maintenance</summary>

**Refactoring**

- **`json_utils.dart` split**: Extracted type conversions, epoch scale, and iterable encoding into 3 focused modules for modularity
- **Abstract final classes**: Converted static-only utility classes to `abstract final` to prevent instantiation and inheritance
- **Lint compliance**: Extracted `_writeFormattedValue` helper from `formatMap` using Dart 3 switch pattern matching
- **Lint compliance**: Eliminated logic duplication — `inRange` now delegates to `isBetween`; replaced inline leap-year math with `DateTimeUtils.isLeapYear()` reuse
- **Lint compliance**: Extracted hardcoded `Duration` constants (`_oneDay`, `_oneMicrosecond`) per `avoid_hardcoded_durations`
- **Refactoring**: Extracted helper methods in `date_time_utils.dart` (`_pluralLabel`, `_joinWithAnd`, `_buildDurationParts`) and replaced switch statements with constant set lookups

**Lint**

- **Lint compliance**: Resolved `prefer_all_named_parameters` across `isNthDayOfMonthInRange`, `getGreatGrandchild`, `getGreatGrandchildString`, `mapToggleValue`, `mapAddValue`, `mapRemoveValue`, `mapContainsValue`
- **Lint compliance**: Resolved `prefer_class_over_record_return` across 5 extension files by replacing record types with named classes
- **Lint compliance**: Resolved `prefer_parentheses_with_if_null` in `string_between_extensions.dart`
- **Lint compliance**: Resolved `prefer_typedefs_for_callbacks` and `prefer_extracting_function_callbacks` in unique list and map extensions
- **Lint compliance**: Used `List.generate` for pre-allocated day lists (`require_list_preallocate`)
- **Lint compliance**: Avoided parameter mutation — use local `resolvedNow` instead of reassigning `now`
- Updated `analysis_options.yaml` and `analysis_options_custom.yaml` lint configurations

**Tests**

- Added comprehensive test suite for `JsonTypeUtils` (60+ test cases)
- Updated tests for renamed boolean parameters across json, datetime, gesture, and enum tests
- Lint violations reduced from ~10,000 to ~30

</details>

---

## [1.0.7] - 2026-02-22

We split the large string and date-time extension files into smaller modules (everything stays backward compatible), fixed a bunch of lints, and switched to proper test matchers. The codebase is easier to work in and the linter is quieter.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.7/CHANGELOG.md)

### Fixed

- **Performance**: cached `toLowerCase()` call in `toBoolNullable`, extracted inline RegExp to top-level finals in `lowerCaseLettersOnly` and `removeSingleCharacterWords`

<details><summary>Maintenance</summary>

**Lint**

- **Lint compliance**: Resolved 10 lint rule categories across 4 files:
  - `avoid_nested_conditional_expressions` (5): refactored nested ternaries to if-else in wrap methods
  - `avoid_redundant_else` (2): removed redundant else in `getFirstDiffChar`, `toBoolNullable`
  - `prefer_switch_expression` (2): converted `isVowel`, `grammarArticle` to switch expressions
  - `avoid_string_concatenation_loop` (1): replaced string concat with StringBuffer in `splitCapitalizedUnicode`
  - `avoid_duplicate_string_literals` (1): reused `_alphaOnlyRegex` in `lettersOnly`
  - `prefer_correct_identifier_length` (1): renamed `r` to `deduplicateRegex` in `replaceLineBreaks`
  - `missing_use_result_annotation` (1): added `@useResult` to `makeNonBreaking`
  - `no_magic_string` (1): extracted grammar article prefixes to named constants
  - `avoid_long_length_files` (2): split oversized files (see Refactoring below)
  - `avoid_very_long_length_files` (1): split `string_extensions.dart` (1114 lines)
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

**Refactoring**

- **`string_extensions.dart`** (1114 → 4 files): Split into `string_extensions.dart` (275), `string_analysis_extensions.dart` (195), `string_manipulation_extensions.dart` (286), `string_text_extensions.dart` (296). Re-exports maintain backward compatibility.
- **`date_time_extensions.dart`** (818 → 4 files): Split into `date_time_extensions.dart` (185), `date_time_arithmetic_extensions.dart` (175), `date_time_comparison_extensions.dart` (164), `date_time_calendar_extensions.dart` (174). Re-exports maintain backward compatibility.
- **`DateConstants`**: Moved 16 top-level constants into `DateConstants` class as `static const` members for proper namespacing and consistency with `MonthUtils`, `WeekdayUtils`, and `SerialDateUtils` patterns. Added private constructor to prevent instantiation.

**Build/tooling**

- **Publish script** (`publish_pub_dev.ps1`): Hardened with smarter pre-checks — auto-fixes pubspec version when CHANGELOG is ahead, aborts early if version tag exists on remote, verifies `gh` auth status and publish workflow. Removed dead code, fixed docstrings and step numbering. Bumped to v2.2.
- Bug reports for 80+ saropa_lints rules with reproduction steps and suggestions in `bugs/`

**Tests**

- Replaced 312 raw literal matchers with proper test matchers across 19 test files (`avoid_misused_test_matchers`): `expect(x, true)` → `isTrue`, `expect(x, false)` → `isFalse`, `expect(x, null)` → `isNull`, `expect(x.length, N)` → `hasLength(N)`

</details>

---

## [1.0.6] - 2026-02-19

We ran a full bug audit and fixed 32 issues—date/time and string logic, emoji handling, and JSON/HTML edge cases. Behavior should be more reliable everywhere.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.6/CHANGELOG.md)

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

<details><summary>Maintenance</summary>

**Refactoring**

- Extracted magic numbers into named constants across codebase (date/time, numeric, string, HTML, UUID); 50+ constants in `date_constants.dart`, `date_time_range_utils.dart`, `date_time_utils.dart`, `time_emoji_utils.dart`, `double_extensions.dart`, `hex_utils.dart`, `html_utils.dart`, `int_extensions.dart`, `int_string_extensions.dart`, `int_utils.dart`, `string_search_extensions.dart`, `string_utils.dart`, `uuid_utils.dart`; resolved `no_magic_number` lint violations.

**Lint**

- `DateTimeUtils.tomorrow()`: Removed nullable type from `minute` and `second` parameters to fix `avoid_nullable_parameters_with_default_values` lint warnings.

**Tests**

- 3,022 tests passing (added ~40 new tests covering all fixed bugs)
- Fixed 8 pre-existing tests with incorrect expectations or wrong test names
- Removed duplicate test cases in `date_time_range_utils_test.dart`

</details>

---

## [1.0.5] - 2026-01-08

We rewrote the README with before/after examples and real-world use cases so it’s easier to see what the library does and whether it fits your project.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.5/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Documentation**

- Rewrote README with compelling production-proven messaging
- Added before/after code comparison table
- Added real-world use cases section
- Improved About section with library origin story

</details>

---

## [1.0.4] - 2026-01-08

We fixed a flaky date/time test that sometimes failed in CI. Your test runs should be more reliable now.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.4/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Tests**

- Fix flaky DateTime test race condition in CI

</details>

---

## [1.0.3] - 2026-01-07

We updated the GitHub Actions publish workflow to use OIDC authentication. Publishing to pub.dev works with the current GitHub setup again.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.3/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Build/tooling**

- Fix GitHub Actions publish workflow for OIDC authentication

</details>

---

## [1.0.2] - 2026-01-07

We added a banner to the README so the project is easier to spot at a glance.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.2/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Documentation**

- Added a banner to README.md

</details>

---

## [1.0.0] - 2026-01-07

First stable 1.0: we switched to the MIT license for broader use, turned on the full saropa_lints tier for quality, and added README badges so you can see pub points, method count, and coverage at a glance.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.0/CHANGELOG.md)

### Changed

- Migrated from GPL v3 to MIT license for broader adoption

<details><summary>Maintenance</summary>

**Lint**

- Upgraded saropa_lints from `recommended` to `insanity` tier (all 500+ rules enabled)

**Documentation**

- Pub points badge (dynamic from pub.dev)
- Methods count badge (480+ methods)
- Coverage badge (100%)
- Organized badge assets into `assets/badges/` folder

</details>

---

## [0.5.12] - 2026-01-05

We switched to the saropa_lints package and custom_lint, and trimmed the analysis config from 255 lines to 69. You get the same level of checking with less to maintain.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.12/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Build/tooling**

- Replaced manually flattened lint rules with `saropa_lints: ^1.1.12`
- Added `custom_lint: ^0.8.0` for custom lint rule support
- Configured `recommended` tier (~150 rules)
- Simplified `analysis_options.yaml` from 255 lines to 69 lines
- Removed manually flattened flutter_lints/recommended/core rules

</details>

---

## [0.5.11]

We added utilities for Base64 compression, UUID validation and formatting, HTML unescape and plain text, and double formatting (percentages, precision, clamping). All of it is covered by 103 new tests.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.11/CHANGELOG.md)

### Added

- `Base64Utils` - Text compression and decompression (`compressText`, `decompressText`)
- `UuidUtils` - UUID validation and manipulation (`isUUID`, `addHyphens`, `removeHyphens`)
- `HtmlUtils` - HTML text processing (`unescape`, `removeHtmlTags`, `toPlainText`)
- `DoubleExtensions` - Double formatting (`hasDecimals`, `toPercentage`, `formatDouble`, `forceBetween`, `toPrecision`, `formatPrecision`)

<details><summary>Maintenance</summary>

**Tests**

- 103 test cases covering all new utilities

</details>

---

## [0.5.10] - 2025-12-11

We extended the publish script with version and branch parameters, dry-run validation, and checks for working tree and remote sync. Releases are safer and easier to script from CI.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.10/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Build/tooling**

- `-Version` parameter for CI/CD automation in publish script
- `-Branch` parameter to specify target branch
- Pre-publish validation step (`flutter pub publish --dry-run`)
- `flutter analyze` step before publishing
- Working tree status check with user confirmation
- Remote sync check to prevent publishing when behind remote
- Early CHANGELOG version validation
- Step numbering in publish script (was skipping from 4 to 6)
- `ErrorActionPreference` issue with try/catch for GitHub release check
- Dynamic package name and repo URL extraction from pubspec.yaml and git remote
- Excluded example folder from parent analysis

</details>

---

## [0.5.9] - 2025-11-25

We added an `allowEmpty` option to JSON validation and made string methods (substring, truncate, lastChars) use grapheme clusters so emoji and Unicode behave correctly. **Note:** indices are now grapheme-based—a breaking change if you relied on code-unit positions.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.9/CHANGELOG.md)

### Added

- `isJson`: `allowEmpty` parameter to optionally treat `{}` as valid JSON

### Changed

- `substringSafe`: Now uses `characters.getRange()` for proper UTF-16/emoji support
- `truncateWithEllipsis`: Uses grapheme cluster length for accurate emoji handling
- `truncateWithEllipsisPreserveWords`: Uses grapheme cluster length
- `lastChars`: Uses grapheme cluster length
- **Breaking**: Indices now refer to grapheme clusters, not code units

### Fixed

- `MakeListExtensions`: Changed extension from `T` to `T?` for nullable types

### Removed

- `UniqueListExtensionsUniqueBy`: Removed unused `propertyComparer` generic parameter

<details><summary>Maintenance</summary>

**Tests**

- 16 test cases for `JsonUtils.isJson`

**Documentation**

- `getUtcTimeFromLocal`: Fixed incorrect documentation
- `getNthWeekdayOfMonthInYear`: Removed stale parameter references from docs

</details>

---

## [0.5.8] - 2025-11-25

We made the publish script handle git tags and GitHub releases idempotently. You can re-run it after a partial run without it failing.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.8/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Build/tooling**

- `publish_pub_dev.ps1`: Added idempotent handling for git tags
- `publish_pub_dev.ps1`: Added idempotent handling for GitHub releases
- Prevents script failures when re-running after partial completion

</details>

---

## [0.5.7] - 2025-11-25

We fixed string extraction (curly braces, line breaks), made word removal Unicode-aware, and improved the grammar and article rules. Text handling should be more accurate now.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.7/CHANGELOG.md)

### Fixed

- `extractCurlyBraces`: Switched to non-greedy matching for correct extraction order
- `removeSingleCharacterWords`: Made Unicode-aware for single-letter words beyond ASCII
- `replaceLineBreaks`: Improved deduplication for arbitrary replacement strings
- `grammarArticle`: Enhanced heuristics for silent 'h', "you"-sound words, and `one-` prefixes
- `possess`: Trims input before applying trailing 's' rules

<details><summary>Maintenance</summary>

**Changed**

- `repeat`: Optimized concatenation with `StringBuffer`
- `lettersOnly`/`lowerCaseLettersOnly`: Simplified to regex-based ASCII filters

</details>

---

## [0.5.6]

We added URL/URI extensions so you can check HTTPS, add or get query parameters, and replace the host. Handy when building or validating links.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.6/CHANGELOG.md)

### Added

- `UrlExtensions.isSecure` - Check if URI uses HTTPS scheme
- `UrlExtensions.addQueryParameter` - Add or update query parameters
- `UrlExtensions.hasQueryParameter` - Check if query parameter exists
- `UrlExtensions.getQueryParameter` - Get query parameter value
- `UrlExtensions.replaceHost` - Create URI with different host

---

## [0.5.5] - 2025-11-25

A big release: JSON and map utilities, URL extensions, string extraction and search, date constants, and many new DateTime and string helpers. We added tests too—over 2,850 in total.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.5/CHANGELOG.md)

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

<details><summary>Maintenance</summary>

**Tests**

- 2850 tests (all passing)

</details>

---

## [0.5.4]

We fixed range and date logic (inclusive boundaries, year boundaries), list comparison, hex overflow, and string truncation. Added 110 tests so the fixes stay solid.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.4/CHANGELOG.md)

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

<details><summary>Maintenance</summary>

**Tests**

- 110 new test cases for algorithm fixes

</details>

---

## [0.5.3] - 2025-11-12

We tuned regex usage in string utils and improved the docs for the random and list helpers. A small polish release.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.3/CHANGELOG.md)

### Changed

- Enhanced `string_utils.dart` to optimize final regex usages

<details><summary>Maintenance</summary>

**Documentation**

- Improved documentation for `CommonRandom` and list generation

</details>

---

## [0.5.2] - 2025-08-19

We renamed the string extension type to `StringExtensions` for consistency. Behavior is unchanged; only the type name is different.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.2/CHANGELOG.md)

### Changed

- Renamed `StringFormattingAndWrappingExtensions` to `StringExtensions`

---

## [0.5.1] - 2025-08-19

We merged all string extension methods into one file and added a full test suite. Imports and structure are simpler.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.1/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Refactoring**

- Merged all string extension methods into `lib/string/string_extensions.dart`
- Updated imports across dependent files
- Removed redundant string extension files and old test files

**Tests**

- Comprehensive test suite for `string_extensions.dart`

</details>

---

## [0.5.0] - 2025-08-19

We added extensions for numbers (e.g. clamping), lists (order-agnostic comparison), and strings (safer number parsing), and refactored names and tests for consistency.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.0/CHANGELOG.md)

### Added

- Extension methods for numbers, lists, and strings (`forceBetween`, order-agnostic list comparison, safer string number parsing)

### Changed

- Refactored extension names for consistency

<details><summary>Maintenance</summary>

**Tests**

- Test files for new extensions
- Updated test imports and structures

</details>

---

## [0.4.4] - 2025-08-18

We split the string code into smaller files and added unique-list and number-range utilities. The layout is clearer and you get a few new helpers.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.4/CHANGELOG.md)

### Added

- Unique lists and number ranges utilities

<details><summary>Maintenance</summary>

**Refactoring**

- Split large string file into smaller, specific files

**Tests**

- Updated tests and imports for new file structure

**Build/tooling**

- Improved code analysis settings

</details>

---

## [0.4.3] - 2025-02-24

We added framework-style extensions for primitives (num, string, etc.), set line length to 100, and removed the VGV spelling lists.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.3/CHANGELOG.md)

### Added

- Framework extensions for primitives (num, string, etc.)

<details><summary>Maintenance</summary>

**Build/tooling**

- Line length to 100
- Removed VGV's spelling lists

</details>

---

## [0.4.2] - 2025-02-24

A small maintenance release: minor improvements and fixes.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.2/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Changed**

- Minor improvements and fixes

</details>

---

## [0.4.1] - 2025-02-13

Another small maintenance release: minor improvements and fixes.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.1/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Changed**

- Minor improvements and fixes

</details>

---

## [0.4.0] - 2025-02-13

We did a major refactor of the library structure and APIs to set things up for the extensions and utilities that followed.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.0/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Changed**

- Major refactoring release

</details>

---

## [0.3.18] - 2025-01-07

We added DateTime and DateTimeRange utilities and brought in jiffy/intl for date formatting. Date handling works well out of the box now.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.18/CHANGELOG.md)

### Added

- `DateTimeRange` utils
- `DateTime` utils
- Dependency to jiffy and intl for date processing

<details><summary>Maintenance</summary>

**Build/tooling**

- Unused flutter code detection script logs warnings to file

</details>

---

## [0.3.17] - 2025-01-07

A small maintenance release: minor improvements.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.17/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Changed**

- Minor improvements

</details>

---

## [0.3.16] - 2025-01-07

Another small maintenance release: minor improvements.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.16/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Changed**

- Minor improvements

</details>

---

## [0.3.15] - 2025-01-03

Another small maintenance release: minor improvements.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.15/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Changed**

- Minor improvements

</details>

---

## [0.3.13]

We added a script to detect unused Flutter code and updated the Code of Conduct (logo, examples, survey). We also renamed the doc folder to docs and removed Codecov.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.13/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Build/tooling**

- Unused flutter code detection script
- Removed Codecov integration

**Documentation**

- TED talks video library to Code of Conduct
- H.O.N.E.S.T.I. acronym wording in Code of Conduct
- Code of Conduct with Saropa logo, examples, survey, and exercise
- Link to Code of Conduct in README.md
- Renamed `doc` folder to `docs`

</details>

---

## [0.2.3]

We added CommonRandom for reproducible randomness, a Code of Conduct for contributors, and development helper scripts. The project is easier to work on and expectations are clearer.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.2.3/CHANGELOG.md)

### Added

- `CommonRandom` class as drop-in replacement for `math.Random()`

<details><summary>Maintenance</summary>

**Build/tooling**

- Development helper scripts

**Documentation**

- Code of Conduct for Saropa contributors
- Updated changelog

</details>

---

## [0.2.1]

We moved the list extensions onto Iterable so they work with any iterable, not just lists. The API is more flexible.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.2.1/CHANGELOG.md)

### Changed

- Migrated `List` extensions to `Iterable`

---

## [0.2.0]

We added enum helpers (byNameTry, sortedEnumValues) and list extensions (smallest, biggest, most/least occurrences), and bumped the SDK and collections dependency.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.2.0/CHANGELOG.md)

### Added

- `Enum` methods: `byNameTry` and `sortedEnumValues`
- List extensions for smallest, biggest, most, and least occurrences

### Changed

- Bumped SDK requirements (sdk: ">=3.4.3 <4.0.0", flutter: ">=3.24.0")
- Added collections package dependency

---

## [0.1.0]

We renamed nullable string utils to extensions and deprecated a few functions we plan to remove. Cleanup to make the API clearer.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.1.0/CHANGELOG.md)

### Deprecated

- Several functions in preparation for removal

<details><summary>Maintenance</summary>

**Refactoring**

- Renamed `string_nullable_utils.dart` to `string_nullable_extensions.dart`

</details>

---

## [0.0.11]

We added date constants and ordinal/GCD/countDigits helpers, fixed removeStart when the search is empty, and removed the deprecated string-nullable functions.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.11/CHANGELOG.md)

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

---

## [0.0.10]

We made removeStart accept a nullable search parameter so it’s easier to use in nullable contexts.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.10/CHANGELOG.md)

### Changed

- `removeStart` parameter changed to nullable

---

## [0.0.9]

We added an optional trimFirst parameter to removeStart so you can trim the result. A small string API improvement.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.9/CHANGELOG.md)

### Added

- `trimFirst` parameter to `StringExtensions.removeStart`

---

## [0.0.8]

We added an optional trimFirst parameter to nullIfEmpty so you have finer control over empty and whitespace handling.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.8/CHANGELOG.md)

### Added

- `trimFirst` parameter to `StringExtensions.nullIfEmpty`

---

## [0.0.7]

We renamed the strings folder to singular and deprecated the nullable string extensions. Naming and API cleanup.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.7/CHANGELOG.md)

### Deprecated

- Nullable string extensions

<details><summary>Maintenance</summary>

**Refactoring**

- Renamed strings folder to singular

</details>

---

## [0.0.6]

We added swipe gesture properties for use in gesture-aware UIs. The groundwork for swipe handling.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.6/CHANGELOG.md)

### Added

- Swipe gesture properties

---

## [0.0.5]

We documented all methods, added example app usage and README examples, and extended the string extensions. The library should be easier to discover and use.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.5/CHANGELOG.md)

### Added

- String extension methods

<details><summary>Maintenance</summary>

**Documentation**

- Documentation for all methods
- Code usage in Example App
- Code usage in README.md

</details>

---

## [0.0.4]

We added an example app, GitHub Actions, and contribution templates (PR, issue, contributing guide). The project is ready for others to contribute.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.4/CHANGELOG.md)

### Added

- Example App

<details><summary>Maintenance</summary>

**Build/tooling**

- GitHub Actions setup
- Pull request template
- Issue template
- Contributing guide

</details>

---

## [0.0.3]

We added a random enum selection helper for when you need a random value from an enum.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.3/CHANGELOG.md)

### Added

- Random enum method

---

## [0.0.2]

We added string-to-bool conversion methods so you can parse "true"/"false" and similar strings safely.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.2/CHANGELOG.md)

### Added

- String to bool conversion methods

---

## [0.0.1] - 2024-06-27

First release. We included bool list methods to get started.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.1/CHANGELOG.md)

### Added

- Initial release with bool list methods

---

```plain

      Made by Saropa. All rights reserved.
```
