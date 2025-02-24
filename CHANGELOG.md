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

Learn more at https://saropa.com, or email dev.tools@saropa.com
```

****

## 0.4.2+Bristol (Latest)

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
