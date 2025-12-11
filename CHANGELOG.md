# Change History for Saropa Dart Utils

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

****
## 0.5.9+Barcelona (Latest)

### API Improvements

✨ **JsonUtils**
- `isJson`: Added `allowEmpty` parameter (default `false`) to optionally treat `{}` as valid JSON while maintaining backwards compatibility

✨ **String Extensions - Grapheme-Aware Substring**
- `substringSafe`: Now uses `characters.getRange()` instead of `substring()` for proper UTF-16/emoji support
- `truncateWithEllipsis`: Updated to use grapheme cluster length for accurate emoji handling
- `truncateWithEllipsisPreserveWords`: Updated to use grapheme cluster length for accurate emoji handling
- `lastChars`: Updated to use grapheme cluster length for accurate emoji handling
- **Breaking behavior change**: Indices now refer to grapheme clusters (user-perceived characters), not code units. For example, `'👨‍👩‍👧‍👦'` counts as 1 grapheme, not 7 code units.

🐛 **Fixes**
- `MakeListExtensions`: Changed extension from `T` to `T?` to properly support nullable types
- `getUtcTimeFromLocal`: Fixed documentation (was incorrectly stating "returns null if offset is 0" when it returns the original instance)
- `getNthWeekdayOfMonthInYear`: Removed stale `month` and `year` parameter references from documentation

🧹 **Cleanup**
- `UniqueListExtensionsUniqueBy`: Removed unused `propertyComparer` generic parameter
- `betweenResult`: Added documentation clarifying the `lastIndexOf` behavior for nested delimiters

🧪 **Tests**
- Added 16 test cases for `JsonUtils.isJson` including `allowEmpty` parameter coverage
- Total test count: **2907 tests** (all passing)

****
## 0.5.8+Madrid

### Script Improvements

🔧 **Publish Script**
- `publish_pub_dev.ps1`: Added idempotent handling for git tags (skips if tag already exists locally or on remote)
- `publish_pub_dev.ps1`: Added idempotent handling for GitHub releases (skips if release already exists)
- Prevents script failures when re-running after partial completion

****
## 0.5.7+Lisbon

### String Fixes & Improvements

🐛 **Fixes**
- `extractCurlyBraces`: switched to non-greedy matching to correctly extract multiple adjacent groups in order.
- `removeSingleCharacterWords`: made Unicode-aware to properly remove standalone single-letter words beyond ASCII.
- `replaceLineBreaks`: improved deduplication to collapse any run of replacements (robust for arbitrary replacement strings).
- `grammarArticle`: enhanced heuristics for silent 'h' (e.g., "hour"), "you"-sound words ("user", "university"), and `one-` prefixes.
- `possess`: trims input before applying trailing 's' rules (US vs. non-US style maintained).

⚙️ **Performance/Behavior**
- `repeat`: optimized concatenation with `StringBuffer` for better performance.
- `lettersOnly`/`lowerCaseLettersOnly`: simplified to efficient regex-based ASCII filters.
- Doc updates: clarified `count` counts non-overlapping matches (noting potential `allowOverlap`), and `obscureText` output length may vary due to jitter.

🧪 **Tests**
- Added tests for newline replacement dedupe with special replacement strings, Unicode single-letter removal, non-greedy curly brace extraction order, improved `grammarArticle` heuristics, and trimmed `possess` behavior.

****
## 0.5.6+Wellington (Latest)

### New URI/URL Extensions

✨ **New UrlExtensions Methods**
- `isSecure` - Check if URI uses HTTPS scheme
- `addQueryParameter` - Add or update query parameters (removes if value is null/empty)
- `hasQueryParameter` - Check if a specific query parameter exists
- `getQueryParameter` - Get the value of a query parameter
- `replaceHost` - Create a new URI with a different host

****
## 0.5.5+Brisbane

### New Utility Classes & Methods

✨ **New Utility Classes**
- `JsonUtils` - JSON parsing, type conversion, and validation (jsonDecodeToMap, jsonDecodeSafe, isJson, cleanJsonResponse, tryJsonDecode, toDateTimeJson, toDateTimeEpochJson, toBoolJson, toIntJson, toDoubleJson, toStringJson, and more)
- `MapExtensions` - Map manipulation (nullIfEmpty, getRandomListExcept, getChildString, getGrandchild, formatReadableString)
- `UrlExtensions` - URI manipulation (removeQuery, fileName, isValidUrl, isValidHttpUrl, tryParse)
- `StringBetweenExtensions` - Content extraction (between, betweenLast, betweenBracketsResult, removeBetween, removeBetweenAll, betweenSplit)
- `StringCharacterExtensions` - Character operations (splitByCharacterCount, charAtOrNull)
- `StringSearchExtensions` - Search utilities (containsAnyIgnoreCase, indexOfAll, lastIndexOfPattern)
- `MonthUtils`, `WeekdayUtils`, `SerialDateUtils` - Date constant lookups and parsing

✨ **New DateTime Extensions**
- `mostRecentSunday`, `mostRecentWeekday` - Find previous occurrence of a weekday
- `dayOfYear`, `weekOfYear`, `numOfWeeks`, `weekNumber` - ISO week/day calculations
- `toSerialString`, `toSerialStringDay` - Serial date formatting

✨ **New String Extensions**
- `removeSingleCharacterWords`, `removeLeadingAndTrailing` - Content cleanup
- `firstWord`, `secondWord` - Word extraction
- `endsWithAny`, `endsWithPunctuation`, `isAny` - Pattern matching
- `extractCurlyBraces`, `obscureText` - Content extraction/masking
- `hasInvalidUnicode`, `isVowel`, `hasAnyDigits` - Character validation

✨ **New Iterable/Num Extensions**
- `randomElement`, `containsAll` - Collection utilities
- `toDoubleOrNull`, `toIntOrNull` - Safe numeric conversions

✨ **Enhanced DateTimeUtils**
- `isValidDateParts` - Comprehensive date part validation
- `convertDaysToYearsAndMonths` - Now with `includeRemainingDays` option

### Extended Test Coverage

🧪 **Comprehensive Test Suite**
- Added 10-20 test cases for each new utility method
- Total test count: **2850 tests** (all passing)

****
## 0.5.4+Auckland

### Algorithm Fixes & Improvements

🐛 **DateTime Extensions**
- Fixed `isBetweenRange` to properly forward the `inclusive` parameter (was being ignored)
- Fixed `isAnnualDateInRange` to correctly handle date ranges spanning year boundaries (e.g., Dec-Feb ranges)
- Fixed `isNthDayOfMonthInRange` cross-year range validation that incorrectly rejected valid months
- Fixed `inRange` and `isNowInRange` to default to inclusive boundary semantics (more intuitive behavior)

🐛 **List Extensions**
- Fixed `equalsIgnoringOrder` to correctly compare duplicate counts (previously `[1,1,2]` incorrectly equaled `[1,2,2]`)

🐛 **String Extensions**
- Fixed `hexToInt` case-sensitive overflow check (lowercase `7fffffffffffffff` was incorrectly flagged as overflow)
- Fixed `toUpperLatinOnly` O(n²) string concatenation - now uses StringBuffer for O(n) performance
- Fixed `upperCaseLettersOnly` O(n²) string concatenation - now uses StringBuffer for O(n) performance
- Fixed `truncateWithEllipsisPreserveWords` to return truncated content when first word exceeds cutoff (instead of just ellipsis)
- Fixed `containsIgnoreCase` to follow standard string semantics (empty string is contained in any string)

🐛 **DateTime Utils**
- Improved `convertDaysToYearsAndMonths` precision using average days per year (365.25) and month (30.4375) to account for leap years
- Added optional `includeRemainingDays` parameter for more detailed output

🧪 **Testing**
- Added 110 new test cases covering all algorithm fixes across respective test files

## 0.5.3+Christchurch
🔄 Enhanced `string_utils.dart` to optimize final regex usages.
📚 Improved documentation and usage for `CommonRandom` and list generation.

## 0.5.2+Düsseldorf
🧹 Rename StringFormattingAndWrappingExtensions to StringExtensions

## 0.5.1+Essen
🧩 All string extension methods for formatting, manipulation, parsing, and validation were merged into a single file: `lib/string/string_extensions.dart`.
🔗 Imports across dependent files were updated to point to the unified extension file.
🗑️ Redundant string extension files and their old test files were removed.
🧪 A comprehensive test suite was added for `string_extensions.dart`, ensuring full coverage of the consolidated functionality.

## 0.5.0+Rotterdam
➕ New extension methods were added for numbers, lists, and strings (like forceBetween, order‑agnostic list comparison, and safer string number parsing).
🧪 Fresh test files were created to cover the new extensions, and overall test coverage has been improved.
🔄 Some extension names were refactored for consistency across the codebase.
🧹 Test imports and structures were updated to align with the refactored code.

<!-- cspell: ignore Utrech -->
## 0.4.4+Utrech

✂️ The big file for string code was split into smaller, more specific files.
➕ New code was added for things like unique lists and number ranges.
🧹 The existing code was cleaned up, making it safer and more efficient.
🔄 The tests and imports were updated to match the new file structure.
⚙️ The code analysis settings were improved to help keep things organized.

## 0.4.3+Bristol

* ✂️ Removed VGV's spelling lists as they are not inherently wrong or needed
* 📦 Many more framework extensions added for primitives (num, string, etc. )
* 📚 Changed line length to 100 [foresightmobile.com](https://foresightmobile.com/blog/flutter-3-29-and-dart-3-7-making-our-dev-lives-even-easier)
* 📚 Added then Removed dependency to intl v0.20.2 [intl](https://pub.dev/packages/intl/changelog) -- too many conflicting dependencies

## 0.3.18+Kyoto

* ⏰ Added boilerplate [DateTimeRange] utils
* ⏰ Added many useful boilerplate [DateTime] utils
* 📚 Added dependency to [jiffy](https://pub.dev/packages/jiffy/changelog) and [intl](https://pub.dev/packages/intl/changelog) for date processing
* ✅ Updated unused flutter code detection script to log warnings to a file

## 0.3.13+Jakarta (Latest)

* ✅ Added an unused flutter code detection script [Dead Code Die Hard: A Practical Guide to Identifying Orphan Flutter Methods](https://saropa-contacts.medium.com/dead-code-die-hard-a-practical-guide-to-identifying-orphan-flutter-methods-b112a1a07320)
* 🤝 Added a video library of TED talks to the [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md)
* 🚀 Removed [Codecov](https://community.codecov.com/) for being annoying
* 🤝 Keep H.O.N.E.S.T.I. the acronym with new wording on Work from Home and Impossible Problems to the [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md)
* 🤝 Updated [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md) with the [Saropa logo](https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/SaropaLogo2019_contrast-1200.png), examples, a survey and an exercise
* 🤝 Include a link to the [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md) into [README.md](https://github.com/saropa/saropa_dart_utils/blob/main/README.md)
* 🧹 Rename `doc` output folder to `docs`

## 0.2.3+Pittsburgh

* 🧹 Update this change log [CHANGELOG.md](https://github.com/saropa/saropa_dart_utils/blob/main/CHANGELOG.md)
* 🔢 Add CommonRandom class as a drop-in replacement for math.Random() with a reliable random seed
* 🤝 Added [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md) for the Saropa contributors
* 📜 Added development helper scripts - including doc generation and publishing

## 0.2.1+Adelaide

* 🧹 Migrated `List` extensions to `Iterable`

## 0.2.0+Melbourne

* 🚀 New `Enum` Methods: Introduced byNameTry and sortedEnumValues methods for enums to enhance searching and sorting capabilities.
* 📈 Added of list extensions for common operations such as finding the smallest, biggest, most, and least occurrences in a list.
* 🧹 Bumped medium version due to addition of collections package and sdk bumps (sdk: ">=3.4.3 <4.0.0", flutter: ">=3.24.0")

## 0.1.0+Tuscany

* 🧹 Bumped medium version due to deprecations and rename of "string_nullable_utils.dart" to "string_nullable_extensions.dart"

## 0.0.11+Rome

* 🗑️ Removed deprecated functions in ```StringNullableExtensions```

* 🐛 Fixed ```StringExtensions.removeStart``` to return the input string when the search param is empty
 ```'Hello, World!'.removeStart(''); // 'Hello, World!'```

* ⚙️ Added constant ```DateConstants.unixEpochDate```
 ```DateConstants.unixEpochDate; // January 1st, 1970```

* ✨ Added function ```DateConstantExtensions.isUnixEpochDate```
 ```DateTime.utc(1970).isUnixEpochDate; // true```

* ✨ Added function ```DateConstantExtensions.isUnixEpochDateTime```
 ```DateTime.utc(1970, 1, 1, 0, 0, 1).isUnixEpochDateTime; // false```

* ✨ Added function ```IntStringExtensions.ordinal```
 ```101.ordinal(); // 101st```

* ✨ Added function ```StringUtils.getNthLatinLetterLower```
 ```String? StringUtils.getNthLatinLetterLower(3) // "c"```

* ✨ Added function ```StringUtils.getNthLatinLetterUpper```
 ```String? StringUtils.getNthLatinLetterUpper(4) // "D"```

* ✨ Added function ```IntUtils.findGreatestCommonDenominator```
 ```String? IntUtils.findGreatestCommonDenominator(15, 45) // 15```

* ✨ Added function ```IntExtensions.countDigits```
 ```(-12345).countDigits() // 5```

## 0.0.10+Paris

* Change start to be nullable
```String? removeStart(String? start)```

## 0.0.9+Geneva

* Review of meta data
* Add trimFirst param to
```StringExtensions.removeStart({bool trimFirst = false,}){...}```

## 0.0.8+Nepal

* Review of meta data
* Add trimFirst param to
```StringExtensions.nullIfEmpty({bool trimFirst = true,}){...}```

## 0.0.7+Jamaica

* Renamed strings folder to singular
* Deprecated nullable string extensions

## 0.0.6

* Added Swipe gesture properties

## 0.0.5

* Added Documentation for all methods
* Added Code Usage in Example App
* Added Code Usage in README.md
* Added String Extension Methods

## 0.0.4

* Added Example App
* Setup Github Actions
* Create Pull request template
* Create Issue template
* Create Contributing guide

## 0.0.3

* Random enum method

## 0.0.2

* String to bool conversion methods.

## 0.0.1

* Initial release with bool list methods.

****

``` plain

      Made by Saropa. All rights reserved.
```
