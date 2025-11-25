# Saropa Dart Utils

<!-- markdownlint-disable MD033 - Disable No HTML -->
<img src="https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/SaropaLogo2019_contrast-1200.png" alt="saropa company logo" style="filter: drop-shadow(0.2em 0.2em 0.13em rgba(68, 68, 68, 0.35));" width="340" />

<br>

Boilerplate reduction tools and human readable extension methods by [Saropa][saropa_link]

<!-- More badges here: https://badgesgenerator.com/ -->
[![pub.dev](https://img.shields.io/pub/v/saropa_dart_utils.svg?label=Latest+Version)](https://pub.dev/packages/saropa_dart_utils) [![linter: very good analysis](https://img.shields.io/badge/license-GPL-purple.svg)](https://opensource.org/licenses/GPL) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

 [![slack: saropa](https://img.shields.io/badge/slack-saropa-4A154B)](https://saropa.slack.com) [![Google Play: saropa](https://img.shields.io/badge/Google%20Play-Saropa%20Android-green)](https://play.google.com/store/apps/details?id=com.saropamobile.app&pli=1) [![AppStore: saropa](https://img.shields.io/badge/AppStore-Saropa%20iOS-6174B2?labelColor=)](https://apps.apple.com/us/app/saropa-contacts/id6447379943?platform=iphone)

[![github home](https://img.shields.io/badge/GitHub-Saropa-333?labelColor=555555)](https://github.com/saropa/saropa_dart_utils)  [![stars](https://badgen.net/github/stars/saropa/saropa_dart_utils?label=stars&color=green&icon=github)](https://github.com/saropa/saropa_dart_utils/stargazers) [![likes](https://img.shields.io/pub/likes/saropa_dart_utils?logo=flutter)](https://pub.dev/packages/saropa_dart_utils/score) [![Open Issues](https://badgen.net/github/open-issues/saropa/saropa_dart_utils?label=Open+Issues&color=green)](https://GitHub.com/saropa/saropa_dart_utils/issues) [![Open PRs](https://badgen.net/github/open-prs/saropa/saropa_dart_utils?label=Open+PRs&color=green)](https://GitHub.com/saropa/saropa_dart_utils/pulls)

We encourage your to review our public [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md).

---

**34 extension classes** providing 200+ utility methods | **1,000+ test cases** ensuring reliability

---

## Table of Contents

- [Quick Start](#quick-start)
- [Extension Categories](#extension-categories)
  - [String Extensions](#string-extensions)
  - [DateTime Extensions](#datetime-extensions)
  - [List Extensions](#list-extensions)
  - [Int Extensions](#int-extensions)
  - [Num Extensions](#num-extensions)
  - [Iterable Extensions](#iterable-extensions)
  - [Map Extensions](#map-extensions)
  - [Bool Extensions](#bool-extensions)
  - [Enum Extensions](#enum-extensions)
  - [Other Utilities](#other-utilities)
- [Full API Documentation](#full-api-documentation)
- [Deployment Guide](#deployment-guide-for-developers)
- [About Saropa](#about-saropa)

## Quick Start

Add to your `pubspec.yaml`:

```yaml
dependencies:
  saropa_dart_utils: ^0.5.6
```

Import the package:

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';
```

## Extension Categories

### String Extensions

**Null Safety & Checking**

```dart
String? text;
text.isNullOrEmpty; // true
text.notNullOrEmpty; // false

text = "Hello";
text.isNullOrEmpty; // false
"".isNumeric(); // false
"123".isNumeric(); // true
```

**Case Manipulation**

```dart
"hello world".titleCase(); // "Hello world"
"hello world".capitalizeWords(); // "Hello World"
"hello".upperCaseFirstChar(); // "Hello"
"HELLO".lowerCaseFirstChar(); // "hELLO"
"helloWorld".insertSpaceBetweenCapitalized(); // "hello World"
```

**Wrapping & Formatting**

```dart
"Saropa".wrapSingleQuotes(); // 'Saropa'
"Saropa".wrapDoubleQuotes(); // "Saropa"
"Saropa".wrapWith(before: "(", after: ")"); // (Saropa)
"Saropa".encloseInParentheses(); // (Saropa)
```

**Truncation**

```dart
"Very long text here".truncateWithEllipsis(10); // "Very long …"
"This is a long sentence".truncateWithEllipsisPreserveWords(15); // "This is a long…"
```

**Cleaning & Removing**

```dart
"www.saropa.com".removeStart("www."); // "saropa.com"
"saropa.com/".removeEnd("/"); // "saropa.com"
"  multiple   spaces  ".compressSpaces(); // "multiple spaces"
"abc123def".removeNonNumbers(); // "123"
"Hello!?".removePunctuation(); // "Hello"
```

**Searching & Extracting**

```dart
"hello world".isContainsWord("world"); // true
"test@example.com".between("@", "."); // "example"
"path/to/file".betweenLast("/", "."); // "file"
"get-everything-after".getEverythingAfter("-"); // "everything-after"
```

**Pluralization & Grammar**

```dart
"apple".pluralize(3); // "apples"
"box".pluralize(2); // "boxes"
"John".possess(); // "John's"
"apple".grammarArticle(); // "an"
```

**Diacritics**

```dart
"café".removeDiacritics(); // "cafe"
"café".containsDiacritics(); // true
```

### DateTime Extensions

**Date Comparisons**

```dart
DateTime date = DateTime(2024, 1, 1);
date.isToday(); // false
date.isBeforeNow(); // true
date.isAfterNow(); // false
date.isSameDateOnly(DateTime(2024, 1, 1, 12, 0)); // true
date.isBetween(DateTime(2023, 1, 1), DateTime(2025, 1, 1)); // true
```

**Date Manipulation**

```dart
DateTime date = DateTime(2024, 1, 15);
date.addYears(1); // 2025-01-15
date.addMonths(2); // 2024-03-15
date.addDays(10); // 2024-01-25
date.nextDay(); // 2024-01-16
date.prevDay(); // 2024-01-14
```

**Age Calculation**

```dart
DateTime birthDate = DateTime(1990, 5, 15);
birthDate.calculateAgeFromNow(); // Current age
birthDate.isUnder13(); // false
```

**Date Ranges**

```dart
DateTime start = DateTime(2024, 1, 1);
DateTimeRange range = DateTimeRange(start: start, end: start.addDays(30));
range.inRange(DateTime(2024, 1, 15)); // true
```

**Date List Generation**

```dart
DateTime.now().generateDayList(7); // List of next 7 days
```

### List Extensions

**Comparison & Searching**

```dart
[1, 2, 3].equalsIgnoringOrder([3, 2, 1]); // true
['a', 'a', 'b'].topOccurrence(); // 'a'
[1, 2, 3].containsAny([3, 4, 5]); // true
[1, 2, 3].itemAt(1); // 2
[1, 2, 3].itemAt(10); // null (safe access)
```

**Null-Safe Operations**

```dart
List<String> items = [];
items.addIfNotNull(null); // List remains empty
items.addIfNotNull("value"); // ["value"]
```

**Unique Lists**

```dart
[1, 2, 2, 3, 3, 3].unique(); // [1, 2, 3]
```

### Int Extensions

**Number Formatting**

```dart
1.ordinal(); // "1st"
2.ordinal(); // "2nd"
3.ordinal(); // "3rd"
21.ordinal(); // "21st"
```

**Range Operations**

```dart
5.forceBetween(1, 10); // 5
15.forceBetween(1, 10); // 10
-5.forceBetween(1, 10); // 1
```

**Digit Counting**

```dart
12345.countDigits(); // 5
```

### Num Extensions

**Range Checks**

```dart
5.isBetween(1, 10); // true
15.isBetween(1, 10); // false
5.isInRange(1, 10); // true (inclusive)
```

### Iterable Extensions

**Random Selection**

```dart
[1, 2, 3, 4, 5].randomElement(); // Random element
```

**Set Operations**

```dart
[1, 2, 3].containsAll([1, 2]); // true
```

**Filtering & Counting**

```dart
[1, 2, 3, 4, 5].countWhere((n) => n > 3); // 2
```

**Min/Max on Comparables**

```dart
[3, 1, 4, 1, 5].smallestOccurrence(); // 1
[3, 1, 4, 1, 5].biggestOccurrence(); // 5
```

### Map Extensions

**Formatting**

```dart
Map<String, dynamic> data = {'name': 'John', 'age': 30};
data.formatMap(); // Pretty-printed map
```

**Key Removal**

```dart
Map<String, dynamic> data = {'a': 1, 'b': 2, 'c': 3};
data.removeKeys(['a', 'c']); // Removes specified keys
```

### Bool Extensions

**String Conversion**

```dart
"true".toBool(); // true
"false".toBool(); // false
"TRUE".toBool(); // true (case-insensitive)
```

**Iterable Operations**

```dart
[true, true, false].allTrue; // false
[true, true, true].allTrue; // true
[false, false, false].allFalse; // true
```

### Enum Extensions

**Safe Enum Parsing**

```dart
enum Status { active, inactive, pending }

Status.values.byNameTry("active"); // Status.active
Status.values.byNameTry("invalid"); // null (safe)
Status.values.byNameTry("ACTIVE", caseSensitive: false); // Status.active
```

### Other Utilities

**Hex Utilities**

```dart
HexUtils.intToHex(255); // "FF"
HexUtils.hexToInt("FF"); // 255
```

**Random Utilities**

```dart
CommonRandom.randomInt(1, 10); // Random int between 1 and 10
CommonRandom.randomDouble(0.0, 1.0); // Random double
```

**Gesture Utilities**

```dart
SwipeProperties.fromDelta(dx: 100, dy: 10); // Detects horizontal swipe
```

**URL Extensions**

```dart
Uri url = Uri.parse("https://example.com?key=value");
url.hasQueryParameter("key"); // true
```

## Full API Documentation

For complete documentation of all extensions and utilities, visit:
- **[API Documentation](https://pub.dev/documentation/saropa_dart_utils/latest/)**
- **[GitHub Repository](https://github.com/saropa/saropa_dart_utils)**

Browse documentation by category:
- [String Extensions](https://pub.dev/documentation/saropa_dart_utils/latest/string_string_extensions/StringExtensions.html)
- [DateTime Extensions](https://pub.dev/documentation/saropa_dart_utils/latest/datetime_date_time_extensions/DateTimeExtensions.html)
- [List Extensions](https://pub.dev/documentation/saropa_dart_utils/latest/list_list_extensions/ListExtensions.html)
- [Int Extensions](https://pub.dev/documentation/saropa_dart_utils/latest/int_int_extensions/IntExtensions.html)

## Deployment Guide For Developers

1. Update [CHANGELOG.md](CHANGELOG.md)

2. Format `dart format .`
   _(note the trailing period ".")_

3. Test `flutter test`

4. Execute `dart doc`

5. Deploy `flutter pub publish`

<br>
<p align="center">🌐 📖 👥 🏢 🚨 🔒 🤝 🎯 🛡️  📉 🆘 ⏱️ 🚑 📞 🌍 🔄 📲 💼</p>

## About Saropa

Saropa®️ is a technology company established in 2010. We have a strong background in financial services, online security and secure web communications.

Our team has extensive experience in top-tier financial technology and we are passionate believers in personal risk management. We are engaged and excited about our vision for family security and this encourages our culture of innovation.

Saropa Contacts is a private, cloud-connected address book that links real people, companies, and emergency groups. It is primarily focused on your trusted emergency groups. Our mission is to reduce the impact of crises everywhere.

In an emergency, get real-time access to all the important people, companies, and services you need - even if you don't know them personally, or if they're not where you expect them to be.

Visit the Saropa Contacts project here: [app.saropa.com](https://app.saropa.com)

PRs, ideas and issues are always welcome! Email for any questions [app.dev.utils@saropa.com](mailto:app.dev.utils@saropa.com) or find us on [Slack Saropa](https://saropa.slack.com)

💙 Saropa

[saropa_link]: https://saropa.com
