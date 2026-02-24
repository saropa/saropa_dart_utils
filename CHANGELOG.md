# Changelog

``` text
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
```

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**pub.dev** - [saropa.saropa-log-capture](https://pub.dev/packages/saropa_dart_utils)

**Published version**: See field "version": "x.y.z" in [package.json](./package.json)

## [1.0.8] - 2026-02-24

### Added
- **`Occurrence<T>` class** (`lib/iterable/occurrence.dart`): typed result for `mostOccurrences()` and `leastOccurrences()` methods, replacing record return types
- **`BetweenResult` class** (`lib/string/between_result.dart`): typed result for `betweenResult()`, `betweenResultLast()`, and bracket-extraction methods, replacing record return types

### Changed
- **Lint compliance**: Resolved `prefer_all_named_parameters` warnings by converting positional parameters to required named parameters in `isNthDayOfMonthInRange`, `getGreatGrandchild`, `getGreatGrandchildString`, `mapToggleValue`, `mapAddValue`, `mapRemoveValue`, and `mapContainsValue`
- **Lint compliance**: Resolved `prefer_class_over_record_return` warnings across 5 extension files by replacing record `(T, int)?` and `(String, String?)?` return types with named classes
- Updated `bool_iterable_extensions.dart`, `int_iterable_extensions.dart`, `double_iterable_extensions.dart`, `iterable_extensions.dart`, and `string_between_extensions.dart`
- Added `T extends Object` constraint to `GeneralIterableExtensions` generic parameter

## [1.0.7] - 2026-02-22

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

### Fixed (32 bugs resolved — full audit)

#### Critical / Logic Errors
- **`getUtcTimeFromLocal`**: was adding offset instead of subtracting; used `floor()` instead of `truncate()` for negative fractional offsets (e.g. UTC-5:30). Return type narrowed from `DateTime?` to `DateTime` (never null).
- **`isDateAfterToday`**: was an instance method that ignored `this` entirely, only checking the `dateToCheck` parameter. Removed the parameter — now correctly checks the receiver against today. Added injectable `{DateTime? now}` for testability.
- **`randomElement`**: was using `DateTime.now().microsecondsSinceEpoch % length` (deterministic, biased). Now uses a module-level `Random` instance with `nextInt()`.
- **`isBetween`**: inclusive mode was using `==` instead of `isAtSameMomentAs` for boundary equality — boundary values were excluded.
- **`removeStart`**: case-insensitive path was calling `nullIfEmpty()` on the trimmed match, returning `null` instead of the original string on non-match.
- **`last()`**: was using rune-based indexing, splitting multi-codepoint emoji. Now uses `characters` package grapheme clusters. Also optimised: replaces `toList()` + `sublist()` with `chars.skip()` to avoid full list allocation.
- **`toDateInYear`**: was crashing with `ArgumentError` for Feb 29 → non-leap year. Now returns `null`.
- **`cleanJsonResponse`**: was unescaping `\"` before detecting outer quotes, corrupting strings like `"hello \"world\""`. Now detects outer quotes first.

#### Medium
- **`betweenResult`**: `endOptional` parameter was declared but never consulted — end-not-found always returned `null`. Now correctly returns the tail when `endOptional: true` is passed. Default changed to `false` to preserve backward compatibility.
- **`isSameDateOrAfter` / `isSameDateOrBefore`**: replaced fragile cascaded year/month/day if-chains with clean `toDateOnly()` + `!isBefore` / `!isAfter`.
- **`isJson('[]')`**: empty array was returning `true` without `allowEmpty: true`, inconsistent with empty object `{}` behaviour. Now requires `allowEmpty: true` for both.
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
- **`num.length()`**: documented scientific notation behaviour for values ≥ 1e21.
- **`pluralize`**: removed `length == 1` guard that incorrectly skipped single-character strings.
- **`forceBetween`**: corrected misleading dartdoc ("NOT greater than" → correctly describes clamping).
- **`truncateWithEllipsisPreserveWords`**: fixed grapheme-unsafe fallback that could split multi-codepoint emoji; now uses `characters.take()` for the search window.
- **`toMapStringDynamic`**: documented silent key collision behaviour when `ensureUniqueKey: false`.
- **`timeToEmoji`**: boundary was `>` instead of `>=` — 7:00am showed moon emoji instead of sun.

### Tests
- 3,022 tests passing (added ~40 new tests covering all fixed bugs)
- Fixed 8 pre-existing tests with incorrect expectations or wrong test names
- Removed duplicate test cases in `date_time_range_utils_test.dart`

## [1.0.6] - 2026-01-21

### Changed
- Extracted magic numbers into named constants across codebase for improved code clarity and linting compliance
- Added 50+ descriptive constants with documentation to date/time, numeric, string, HTML, and UUID utilities
- Migrated date/time validation constants to public exports in `date_constants.dart` for cross-module reuse
- Files updated:
  - `datetime/date_constants.dart` - Added 15 date/time validation constants
  - `datetime/date_time_range_utils.dart` - Uses shared month constants
  - `datetime/date_time_utils.dart` - Uses shared date/time constants
  - `datetime/time_emoji_utils.dart` - Uses day/night hour constants
  - `double/double_extensions.dart` - Added percentage and base-10 constants
  - `hex/hex_utils.dart` - Added hex radix and max length constants
  - `html/html_utils.dart` - Added hex radix and Unicode limit constants
  - `int/int_extensions.dart` - Added base-10 constant
  - `int/int_string_extensions.dart` - Added ordinal number constants
  - `int/int_utils.dart` - Added recursion depth constant
  - `string/string_search_extensions.dart` - Added ASCII code constants
  - `string/string_utils.dart` - Added alphabet position constants
  - `uuid/uuid_utils.dart` - Added UUID format constants
- Resolved `no_magic_number` linting violations in production code

### Fixed
- `DateTimeUtils.tomorrow()`: Removed nullable type from `minute` and `second` parameters to fix `avoid_nullable_parameters_with_default_values` lint warnings

## [1.0.5] - 2026-01-08

### Changed

- Rewrote README with compelling production-proven messaging
- Added before/after code comparison table
- Added real-world use cases section
- Improved About section with library origin story

## [1.0.4] - 2026-01-08

### Fixed

- Fix flaky DateTime test race condition in CI

## [1.0.3] - 2026-01-07

### Changed

- Fix GitHub Actions publish workflow for OIDC authentication

## [1.0.2] - 2026-01-07

### Changed
- Added a banner to README.md

## [1.0.0] - 2026-01-07

### Changed
- Migrated from GPL v3 to MIT license for broader adoption
- Upgraded saropa_lints from `recommended` to `insanity` tier (all 500+ rules enabled)

### Added
- Pub points badge (dynamic from pub.dev)
- Methods count badge (480+ methods)
- Coverage badge (100%)
- Organized badge assets into `assets/badges/` folder

## [0.5.12] - 2026-01-05

### Changed
- Replaced manually flattened lint rules with `saropa_lints: ^1.1.12`
- Added `custom_lint: ^0.8.0` for custom lint rule support
- Configured `recommended` tier (~150 rules)
- Simplified `analysis_options.yaml` from 255 lines to 69 lines
- Removed manually flattened flutter_lints/recommended/core rules

## [0.5.11]

### Added
- `Base64Utils` - Text compression and decompression (`compressText`, `decompressText`)
- `UuidUtils` - UUID validation and manipulation (`isUUID`, `addHyphens`, `removeHyphens`)
- `HtmlUtils` - HTML text processing (`unescape`, `removeHtmlTags`, `toPlainText`)
- `DoubleExtensions` - Double formatting (`hasDecimals`, `toPercentage`, `formatDouble`, `forceBetween`, `toPrecision`, `formatPrecision`)
- 103 test cases covering all new utilities

## [0.5.10] - 2025-12-11

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

### Changed
- `publish_pub_dev.ps1`: Added idempotent handling for git tags
- `publish_pub_dev.ps1`: Added idempotent handling for GitHub releases
- Prevents script failures when re-running after partial completion

## [0.5.7] - 2025-11-25

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

### Added
- `UrlExtensions.isSecure` - Check if URI uses HTTPS scheme
- `UrlExtensions.addQueryParameter` - Add or update query parameters
- `UrlExtensions.hasQueryParameter` - Check if query parameter exists
- `UrlExtensions.getQueryParameter` - Get query parameter value
- `UrlExtensions.replaceHost` - Create URI with different host

## [0.5.5] - 2025-11-25

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

### Changed
- Enhanced `string_utils.dart` to optimize final regex usages
- Improved documentation for `CommonRandom` and list generation

## [0.5.2] - 2025-08-19

### Changed
- Renamed `StringFormattingAndWrappingExtensions` to `StringExtensions`

## [0.5.1] - 2025-08-19

### Changed
- Merged all string extension methods into `lib/string/string_extensions.dart`
- Updated imports across dependent files

### Removed
- Redundant string extension files and old test files

### Added
- Comprehensive test suite for `string_extensions.dart`

## [0.5.0] - 2025-08-19

### Added
- Extension methods for numbers, lists, and strings (`forceBetween`, order-agnostic list comparison, safer string number parsing)
- Test files for new extensions

### Changed
- Refactored extension names for consistency
- Updated test imports and structures

## [0.4.4] - 2025-08-18

### Changed
- Split large string file into smaller, specific files
- Updated tests and imports for new file structure
- Improved code analysis settings

### Added
- Unique lists and number ranges utilities

## [0.4.3] - 2025-02-24

### Added
- Framework extensions for primitives (num, string, etc.)

### Changed
- Line length to 100

### Removed
- VGV's spelling lists

## [0.4.2] - 2025-02-24

### Changed
- Minor improvements and fixes

## [0.4.1] - 2025-02-13

### Changed
- Minor improvements and fixes

## [0.4.0] - 2025-02-13

### Changed
- Major refactoring release

## [0.3.18] - 2025-01-07

### Added
- `DateTimeRange` utils
- `DateTime` utils
- Dependency to jiffy and intl for date processing

### Changed
- Unused flutter code detection script logs warnings to file

## [0.3.17] - 2025-01-07

### Changed
- Minor improvements

## [0.3.16] - 2025-01-07

### Changed
- Minor improvements

## [0.3.15] - 2025-01-03

### Changed
- Minor improvements

## [0.3.13]

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

### Added
- `CommonRandom` class as drop-in replacement for `math.Random()`
- Code of Conduct for Saropa contributors
- Development helper scripts

### Changed
- Updated changelog

## [0.2.1]

### Changed
- Migrated `List` extensions to `Iterable`

## [0.2.0]

### Added
- `Enum` methods: `byNameTry` and `sortedEnumValues`
- List extensions for smallest, biggest, most, and least occurrences

### Changed
- Bumped SDK requirements (sdk: ">=3.4.3 <4.0.0", flutter: ">=3.24.0")
- Added collections package dependency

## [0.1.0]

### Changed
- Renamed `string_nullable_utils.dart` to `string_nullable_extensions.dart`

### Deprecated
- Several functions in preparation for removal

## [0.0.11]

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

### Changed
- `removeStart` parameter changed to nullable

## [0.0.9]

### Added
- `trimFirst` parameter to `StringExtensions.removeStart`

## [0.0.8]

### Added
- `trimFirst` parameter to `StringExtensions.nullIfEmpty`

## [0.0.7]

### Changed
- Renamed strings folder to singular

### Deprecated
- Nullable string extensions

## [0.0.6]

### Added
- Swipe gesture properties

## [0.0.5]

### Added
- Documentation for all methods
- Code usage in Example App
- Code usage in README.md
- String extension methods

## [0.0.4]

### Added
- Example App
- GitHub Actions setup
- Pull request template
- Issue template
- Contributing guide

## [0.0.3]

### Added
- Random enum method

## [0.0.2]

### Added
- String to bool conversion methods

## [0.0.1] - 2024-06-27

### Added
- Initial release with bool list methods

---

``` plain

      Made by Saropa. All rights reserved.
```
