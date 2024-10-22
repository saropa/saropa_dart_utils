# Change History for Saropa Dart Utils

## 0.3.0 Jakarta (Latest)

* 🧹 Updated code.of.conduct.md with examples, a survey and an exercise

## 0.2.3+Pittsburgh

* 🧹 Update this change log

## 0.2.2+Pittsburgh

* 🔢 Add CommonRandom class as a drop-in replacement for math.Random() with a reliable random seed
* 🤝 Added code.of.conduct.md for the Saropa contributors
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
