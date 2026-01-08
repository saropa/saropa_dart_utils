![saropa_dart_utils banner](https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/assets/banner.png)

# Saropa Dart Utils

**Stop writing the same utility functions in every Flutter project.** This library contains **280+ production-hardened extension methods** extracted from a real-world Flutter app with thousands of active users.

[![pub.dev](https://img.shields.io/pub/v/saropa_dart_utils.svg)](https://pub.dev/packages/saropa_dart_utils)
[![pub points](https://img.shields.io/pub/points/saropa_dart_utils)](https://pub.dev/packages/saropa_dart_utils/score)
[![coverage](https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/assets/badges/coverage_badge.svg)](https://github.com/saropa/saropa_dart_utils)
[![methods](https://img.shields.io/badge/methods-280%2B-blue)](https://pub.dev/documentation/saropa_dart_utils/latest/)
[![style: saropa lints](https://img.shields.io/badge/style-saropa__lints-4B0082.svg)](https://pub.dev/packages/saropa_lints)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Production-Proven, Not Theoretical

These utilities aren't academic exercises—they're **dog-fooded daily** in [Saropa Contacts](https://app.saropa.com), a production Flutter app available on both Google Play and the App Store. Every method has been refined through real user feedback and edge cases you only discover in production.

**What this means for you:**
- Edge cases already handled (empty strings, nulls, Unicode, timezone issues)
- Performance optimized for mobile devices
- API design proven intuitive through actual usage
- Bugs already found and fixed by real users

## Why Developers Choose This Library

| Before | After |
|--------|-------|
| `text != null && text.isNotEmpty ? text : fallback` | `text.orDefault(fallback)` |
| `if (date != null && date.isAfter(start) && date.isBefore(end))` | `date.isBetween(start, end)` |
| `list.length > index ? list[index] : null` | `list.itemAt(index)` |
| `"${n}${n == 1 ? 'st' : n == 2 ? 'nd' : ...}"` | `n.ordinal()` |
| Writing regex for email extraction | `text.between("@", ".")` |

**One import. Zero boilerplate. Full null-safety.**

## What's Included

| Category | Methods | Highlights |
|----------|---------|------------|
| **String** | 110+ | Case conversion, truncation, wrapping, searching, grammar, diacritics, Unicode-safe operations |
| **DateTime** | 50+ | Age calculation, range checks, date arithmetic, leap years, week numbers |
| **List/Iterable** | 40+ | Safe access, deduplication, frequency analysis, order-independent comparison |
| **Number** | 25+ | Ordinals (1st, 2nd, 3rd), range clamping, digit operations |
| **Map** | 15+ | Nested access, pretty printing, null-safe operations |
| **Bool** | 8+ | Flexible string parsing ("yes"/"1"/"true"), iterable analysis |
| **URL/Uri** | 8+ | Query parameter manipulation, file info extraction |
| **Utilities** | 25+ | JSON validation, Base64, UUID, Hex, HTML entities, gesture types |

## Installation

```yaml
dependencies:
  saropa_dart_utils: ^1.0.5
```

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';
```

## Quick Start Examples

Drop-in solutions for common Flutter development tasks:

### String Extensions (110+ methods)

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

### DateTime Extensions (50+ methods)

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

### List Extensions (30+ methods)

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

### Number Extensions (25+ methods)

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

### Iterable Extensions (10+ methods)

```dart
[1, 2, 3, 4, 5].randomElement();
[1, 2, 3].containsAll([1, 2]);
[1, 2, 3, 4, 5].countWhere((n) => n > 3);  // 2
```

### Map Extensions (15+ methods)

```dart
{'name': 'John', 'age': 30}.formatMap();  // Pretty print
data.removeKeys(['a', 'c']);
```

### Bool Extensions (8+ methods)

```dart
"true".toBool();           // true
[true, true, true].allTrue; // true
[false, false].allFalse;    // true
```

### Enum Extensions (2+ methods)

```dart
enum Status { active, inactive }

Status.values.byNameTry("active");   // Status.active
Status.values.byNameTry("invalid");  // null (safe)
Status.values.byNameTry("ACTIVE", caseSensitive: false);  // Status.active
```

### Utility Classes (25+ methods)

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

## Real-World Use Cases

These aren't contrived examples—they're patterns we use constantly:

```dart
// User profile display
String displayName = user.firstName.capitalizeWords();
String initials = "${user.firstName.firstChar}${user.lastName.firstChar}";
String age = birthDate.calculateAgeFromNow().toString();

// Form validation
bool isValidInput = email.notNullOrEmpty && phone.removeNonNumbers().length >= 10;

// Date logic for subscriptions
bool isTrialActive = signupDate.addDays(14).isAfterNow();
bool isBirthdayThisMonth = birthDate.isSameMonth(DateTime.now());

// Safe API response handling
String? city = response['address']?.getChildString('city');
List<String> tags = (response['tags'] as List?)?.unique() ?? [];

// UI text formatting
String preview = longDescription.truncateWithEllipsis(100);
String itemCount = "item".pluralize(cart.length);  // "1 item" or "5 items"
```

## Documentation

- [API Reference](https://pub.dev/documentation/saropa_dart_utils/latest/) — Full method documentation with examples
- [GitHub](https://github.com/saropa/saropa_dart_utils) — Source code and issue tracking
- [Changelog](https://github.com/saropa/saropa_dart_utils/blob/main/CHANGELOG.md) — Version history

## Contributing

We welcome contributions! These utilities grew from solving real problems—if you've got a helper that's saved you time, it might help others too.

- [Code of Conduct](https://github.com/saropa/saropa_dart_utils/blob/main/code.of.conduct.md)
- Email: [app.dev.utils@saropa.com](mailto:app.dev.utils@saropa.com)
- [Slack](https://saropa.slack.com)

## About Saropa

[Saropa](https://saropa.com) builds technology for personal safety and emergency preparedness. This utility library was extracted from [Saropa Contacts](https://app.saropa.com)—our production Flutter app for managing trusted emergency contacts—because we believe good utilities should be shared, not rewritten.

[![Google Play](https://img.shields.io/badge/Google_Play-Saropa_Contacts-34A853)](https://play.google.com/store/apps/details?id=com.saropamobile.app)
[![App Store](https://img.shields.io/badge/App_Store-Saropa_Contacts-0D96F6)](https://apps.apple.com/us/app/saropa-contacts/id6447379943)
