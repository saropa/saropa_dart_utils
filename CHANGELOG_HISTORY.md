# Changelog History

<!-- cspell:disable -->

Archived changelog entries for **saropa_dart_utils** versions **0.5.9 and earlier**.
For current releases, see [CHANGELOG.md](./CHANGELOG.md).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**pub.dev** - [saropa_dart_utils](https://pub.dev/packages/saropa_dart_utils)

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

## [1.0.4] - 2026-01-08

We fixed a flaky date/time test that sometimes failed in CI. Your test runs should be more reliable now.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.4/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Tests**

- Fix flaky DateTime test race condition in CI

</details>

## [1.0.3] - 2026-01-07

We updated the GitHub Actions publish workflow to use OIDC authentication. Publishing to pub.dev works with the current GitHub setup again.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.3/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Build/tooling**

- Fix GitHub Actions publish workflow for OIDC authentication

</details>

## [1.0.2] - 2026-01-07

We added a banner to the README so the project is easier to spot at a glance.
[log](https://github.com/saropa/saropa_dart_utils/blob/v1.0.2/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Documentation**

- Added a banner to README.md

</details>

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

## [0.5.8] - 2025-11-25

We made the publish script handle git tags and GitHub releases idempotently. You can re-run it after a partial run without it failing.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.8/CHANGELOG.md)

<details><summary>Maintenance</summary>

**Build/tooling**

- `publish_pub_dev.ps1`: Added idempotent handling for git tags
- `publish_pub_dev.ps1`: Added idempotent handling for GitHub releases
- Prevents script failures when re-running after partial completion

</details>

## [0.5.7] - 2025-11-25

We fixed string extraction (curly braces, line breaks), made word removal Unicode-aware, and improved the grammar and article rules. Text handling should be more accurate now.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.7/CHANGELOG.md)

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
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.6/CHANGELOG.md)

### Added

- `UrlExtensions.isSecure` - Check if URI uses HTTPS scheme
- `UrlExtensions.addQueryParameter` - Add or update query parameters
- `UrlExtensions.hasQueryParameter` - Check if query parameter exists
- `UrlExtensions.getQueryParameter` - Get query parameter value
- `UrlExtensions.replaceHost` - Create URI with different host

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

## [0.5.3] - 2025-11-12

We tuned regex usage in string utils and improved the docs for the random and list helpers. A small polish release.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.3/CHANGELOG.md)

### Changed

- Enhanced `string_utils.dart` to optimize final regex usages

<details><summary>Maintenance</summary>

**Documentation**

- Improved documentation for `CommonRandom` and list generation

</details>

## [0.5.2] - 2025-08-19

We renamed the string extension type to `StringExtensions` for consistency. Behavior is unchanged; only the type name is different.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.5.2/CHANGELOG.md)

### Changed

- Renamed `StringFormattingAndWrappingExtensions` to `StringExtensions`

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

## [0.4.2] - 2025-02-24

A small maintenance release: minor improvements and fixes.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.2/CHANGELOG.md)

### Changed

- Minor improvements and fixes

## [0.4.1] - 2025-02-13

Another small maintenance release: minor improvements and fixes.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.1/CHANGELOG.md)

### Changed

- Minor improvements and fixes

## [0.4.0] - 2025-02-13

We did a major refactor of the library structure and APIs to set things up for the extensions and utilities that followed.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.4.0/CHANGELOG.md)

### Changed

- Major refactoring release

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

## [0.3.17] - 2025-01-07

A small maintenance release: minor improvements.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.17/CHANGELOG.md)

### Changed

- Minor improvements

## [0.3.16] - 2025-01-07

Another small maintenance release: minor improvements.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.16/CHANGELOG.md)

### Changed

- Minor improvements

## [0.3.15] - 2025-01-03

Another small maintenance release: minor improvements.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.3.15/CHANGELOG.md)

### Changed

- Minor improvements

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

## [0.2.1]

We moved the list extensions onto Iterable so they work with any iterable, not just lists. The API is more flexible.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.2.1/CHANGELOG.md)

### Changed

- Migrated `List` extensions to `Iterable`

## [0.2.0]

We added enum helpers (byNameTry, sortedEnumValues) and list extensions (smallest, biggest, most/least occurrences), and bumped the SDK and collections dependency.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.2.0/CHANGELOG.md)

### Added

- `Enum` methods: `byNameTry` and `sortedEnumValues`
- List extensions for smallest, biggest, most, and least occurrences

### Changed

- Bumped SDK requirements (sdk: ">=3.4.3 <4.0.0", flutter: ">=3.24.0")
- Added collections package dependency

## [0.1.0]

We renamed nullable string utils to extensions and deprecated a few functions we plan to remove. Cleanup to make the API clearer.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.1.0/CHANGELOG.md)

### Deprecated

- Several functions in preparation for removal

<details><summary>Maintenance</summary>

**Refactoring**

- Renamed `string_nullable_utils.dart` to `string_nullable_extensions.dart`

</details>

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

## [0.0.10]

We made removeStart accept a nullable search parameter so it’s easier to use in nullable contexts.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.10/CHANGELOG.md)

### Changed

- `removeStart` parameter changed to nullable

## [0.0.9]

We added an optional trimFirst parameter to removeStart so you can trim the result. A small string API improvement.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.9/CHANGELOG.md)

### Added

- `trimFirst` parameter to `StringExtensions.removeStart`

## [0.0.8]

We added an optional trimFirst parameter to nullIfEmpty so you have finer control over empty and whitespace handling.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.8/CHANGELOG.md)

### Added

- `trimFirst` parameter to `StringExtensions.nullIfEmpty`

## [0.0.7]

We renamed the strings folder to singular and deprecated the nullable string extensions. Naming and API cleanup.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.7/CHANGELOG.md)

### Deprecated

- Nullable string extensions

<details><summary>Maintenance</summary>

**Refactoring**

- Renamed strings folder to singular

</details>

## [0.0.6]

We added swipe gesture properties for use in gesture-aware UIs. The groundwork for swipe handling.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.6/CHANGELOG.md)

### Added

- Swipe gesture properties

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

## [0.0.3]

We added a random enum selection helper for when you need a random value from an enum.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.3/CHANGELOG.md)

### Added

- Random enum method

## [0.0.2]

We added string-to-bool conversion methods so you can parse "true"/"false" and similar strings safely.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.2/CHANGELOG.md)

### Added

- String to bool conversion methods

## [0.0.1] - 2024-06-27

First release. We included bool list methods to get started.
[log](https://github.com/saropa/saropa_dart_utils/blob/v0.0.1/CHANGELOG.md)

### Added

- Initial release with bool list methods

---

```plain

      Made by Saropa. All rights reserved.
```
