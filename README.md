![saropa_dart_utils banner](https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/assets/banner.png)

# Saropa Dart Utils

Boilerplate reduction tools and human-readable extension methods for Flutter/Dart.

[![pub.dev](https://img.shields.io/pub/v/saropa_dart_utils.svg)](https://pub.dev/packages/saropa_dart_utils)
[![pub points](https://img.shields.io/pub/points/saropa_dart_utils)](https://pub.dev/packages/saropa_dart_utils/score)
[![coverage](assets/badges/coverage_badge.svg)](https://github.com/saropa/saropa_dart_utils)
[![methods](https://img.shields.io/badge/methods-480%2B-blue)](https://pub.dev/documentation/saropa_dart_utils/latest/)
[![style: saropa lints](https://img.shields.io/badge/style-saropa__lints-4B0082.svg)](https://pub.dev/packages/saropa_lints)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Installation

```yaml
dependencies:
  saropa_dart_utils: ^0.5.11
```

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';
```

## Features

### String Extensions

```dart
// Null safety
String? text;
text.isNullOrEmpty;        // true
"hello".notNullOrEmpty;    // true

// Case manipulation
"hello world".titleCase();           // "Hello world"
"hello world".capitalizeWords();     // "Hello World"

// Formatting
"Saropa".wrapSingleQuotes();         // 'Saropa'
"Saropa".encloseInParentheses();     // (Saropa)

// Truncation
"Long text here".truncateWithEllipsis(10);  // "Long text…"

// Cleaning
"www.saropa.com".removeStart("www.");  // "saropa.com"
"  extra   spaces  ".compressSpaces(); // "extra spaces"
"abc123".removeNonNumbers();           // "123"

// Searching
"test@example.com".between("@", ".");  // "example"

// Grammar
"apple".pluralize(3);    // "apples"
"John".possess();        // "John's"
"apple".grammarArticle(); // "an"

// Diacritics
"cafe".removeDiacritics();  // "cafe"
```

### DateTime Extensions

```dart
DateTime date = DateTime(2024, 1, 15);

// Comparisons
date.isToday();
date.isBeforeNow();
date.isSameDateOnly(otherDate);
date.isBetween(start, end);

// Manipulation
date.addYears(1);
date.addMonths(2);
date.addDays(10);
date.nextDay();
date.prevDay();

// Age calculation
DateTime(1990, 5, 15).calculateAgeFromNow();
birthDate.isUnder13();

// List generation
DateTime.now().generateDayList(7);  // Next 7 days
```

### List Extensions

```dart
// Comparison
[1, 2, 3].equalsIgnoringOrder([3, 2, 1]);  // true
['a', 'a', 'b'].topOccurrence();           // 'a'

// Safe access
[1, 2, 3].itemAt(10);  // null (no exception)

// Null-safe operations
items.addIfNotNull(maybeNull);

// Deduplication
[1, 2, 2, 3].unique();  // [1, 2, 3]
```

### Number Extensions

```dart
// Ordinals
1.ordinal();   // "1st"
22.ordinal();  // "22nd"

// Range operations
15.forceBetween(1, 10);  // 10
5.isBetween(1, 10);      // true

// Digit counting
12345.countDigits();  // 5
```

### Iterable Extensions

```dart
[1, 2, 3, 4, 5].randomElement();
[1, 2, 3].containsAll([1, 2]);
[1, 2, 3, 4, 5].countWhere((n) => n > 3);  // 2
```

### Map Extensions

```dart
{'name': 'John', 'age': 30}.formatMap();  // Pretty print
data.removeKeys(['a', 'c']);
```

### Bool Extensions

```dart
"true".toBool();           // true
[true, true, true].allTrue; // true
[false, false].allFalse;    // true
```

### Enum Extensions

```dart
enum Status { active, inactive }

Status.values.byNameTry("active");   // Status.active
Status.values.byNameTry("invalid");  // null (safe)
Status.values.byNameTry("ACTIVE", caseSensitive: false);  // Status.active
```

### Utilities

```dart
// Hex
HexUtils.intToHex(255);   // "FF"
HexUtils.hexToInt("FF");  // 255

// Random
CommonRandom.randomInt(1, 10);
CommonRandom.randomDouble(0.0, 1.0);

// URL
Uri.parse("https://example.com?key=value").hasQueryParameter("key");  // true
```

## Documentation

- [API Reference](https://pub.dev/documentation/saropa_dart_utils/latest/)
- [GitHub](https://github.com/saropa/saropa_dart_utils)
- [Changelog](https://github.com/saropa/saropa_dart_utils/blob/main/CHANGELOG.md)

## Contributing

PRs and issues welcome!

- [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md)
- Email: [app.dev.utils@saropa.com](mailto:app.dev.utils@saropa.com)
- [Slack](https://saropa.slack.com)

## About Saropa

[Saropa](https://saropa.com) is a technology company focused on personal safety and emergency preparedness. Our flagship product, [Saropa Contacts](https://app.saropa.com), is a private cloud-connected address book for managing trusted emergency contacts.

[![Google Play](https://img.shields.io/badge/Google_Play-Saropa-green)](https://play.google.com/store/apps/details?id=com.saropamobile.app)
[![App Store](https://img.shields.io/badge/App_Store-Saropa-blue)](https://apps.apple.com/us/app/saropa-contacts/id6447379943)
