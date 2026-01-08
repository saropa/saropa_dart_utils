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
