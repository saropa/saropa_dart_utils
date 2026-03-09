![saropa_dart_utils banner](https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/assets/banner.png)

<!-- # Saropa Dart Utils -->

**Stop writing the same utility functions in every Flutter project.** This library contains **400+ production-hardened extension methods and utilities** extracted from a real-world Flutter app with thousands of active users.

[![pub.dev](https://img.shields.io/pub/v/saropa_dart_utils.svg)](https://pub.dev/packages/saropa_dart_utils)
[![pub points](https://img.shields.io/pub/points/saropa_dart_utils)](https://pub.dev/packages/saropa_dart_utils/score)
[![coverage](https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/assets/badges/coverage_badge.svg)](https://github.com/saropa/saropa_dart_utils)
[![methods](https://img.shields.io/badge/methods-400%2B-blue)](https://pub.dev/documentation/saropa_dart_utils/latest/)
[![style: saropa lints](https://img.shields.io/badge/style-saropa__lints-4B0082.svg)](https://pub.dev/packages/saropa_lints)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Production-Proven, Not Theoretical

These utilities aren't academic exercises—they're **dog-fooded daily** in [Saropa Contacts](https://app.saropa.com), a production Flutter app available on both Google Play and the App Store. Every method has been refined through real user feedback and edge cases you only discover in production.

**What this means for you:**

- Edge cases already handled (empty strings, nulls, Unicode, timezone issues)
- Performance optimized for mobile devices
- API design proven intuitive through actual usage
- Bugs already found and fixed by real users

## Why Choose This Library

| Before                                                           | After                        |
| ---------------------------------------------------------------- | ---------------------------- |
| `text != null && text.isNotEmpty ? text : fallback`              | `text.orDefault(fallback)`   |
| `if (date != null && date.isAfter(start) && date.isBefore(end))` | `date.isBetween(start, end)` |
| `list.length > index ? list[index] : null`                       | `list.itemAt(index)`         |
| `"${n}${n == 1 ? 'st' : n == 2 ? 'nd' : ...}"`                   | `n.ordinal()`                |
| Writing regex for email extraction                               | `text.between("@", ".")`     |

**One import. Zero boilerplate. Full null-safety.**

<!-- cspell:disable -->

## What's Included

| Category          | Scope                      | Highlights                                                                                                                                                                                                                                           |
| ----------------- | -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **String**        | 110+ extensions, 30+ utils | Case conversion, truncation, wrapping, searching, grammar, diacritics, Unicode-safe ops; Levenshtein, slug/mask/template, diff (Myers), fuzzy search, excerpt, markdown, HTML sanitizer, name parsing                                                |
| **DateTime**      | 50+ extensions, 10+ utils  | Age calculation, range checks, date arithmetic, leap years, week numbers; bounds, business days, duration format/parse, fiscal, relative, time rounding, injectable clock                                                                            |
| **List/Iterable** | 40+ extensions             | Safe access, deduplication, frequency analysis, order-independent comparison; chunks, partition, groupBy, run-length, binary search, rotate                                                                                                          |
| **Collections**   | 38 modules                 | LIS, LCS, sliding window, reservoir sampling, trie, disjoint set, Damerau–Levenshtein, knapsack, bloom filter, n-way merge, ring buffer, multiset, histogram, k-means, weighted interval, string pool, seeded shuffle, and more                      |
| **Graph**         | 15 modules                 | BFS/DFS, Dijkstra, A\*, connected components, topological sort, MST, critical path, bipartite, tree utils, DAG scheduler                                                                                                                             |
| **Stats**         | 16 modules                 | Robust stats, moving average, normalization, quantile summary, correlation, linear regression, confidence intervals, funnel, retention, sampling, outlier (MAD), feature encoding                                                                    |
| **Validation**    | 12 modules                 | Validation errors, path/input shaping, guards, cross-field validation, safe temp names, password strength, PII detection, data redaction, safe parse, typed positives, IP/CIDR, JWT structure                                                        |
| **Async**         | 22 modules                 | Debounce, throttle, delay, retry (with backoff/policy), memoize future, sequential/batch, cancel previous, semaphore, mutex, stream buffer/window, exponential backoff, circuit breaker, barrier, timeout policy, race/cancel, idempotent, heartbeat |
| **Number**        | 25+ extensions, 15+ utils  | Ordinals (1st, 2nd, 3rd), range clamping, digit ops; math (gcd, lcm), lerp, stats (variance, median, percentile), prime, factorial, locale format/parse, safe division                                                                               |
| **Map**           | 15+ extensions, 5+ utils   | Nested access, pretty printing, null-safe ops; deep merge/copy, flatten keys, diff, invert, pick/omit, transform                                                                                                                                     |
| **Parsing**       | 22 modules                 | CSV, email, phone (E.164), Luhn, ISBN, SemVer, version compare, hex color, bool, list-from-string; config precedence, CSV dialect, canonicalize JSON, changelog section, JSON diff/patch, nested query, varint                                       |
| **Caching**       | 4 modules                  | LRU cache, TTL cache, size-limited cache, memoize (sync)                                                                                                                                                                                             |
| **URL/Path**      | 8+ modules                 | Path join/extension/normalize, URL encode/query/build/absolute, path_more (directory, base name, bearer token)                                                                                                                                       |
| **Bool**          | 8+                         | Flexible string parsing ("yes"/"1"/"true"), iterable analysis                                                                                                                                                                                        |
| **Niche**         | 10+                        | Color (hex/rgb, luminance, contrast), name (abbreviate, initials), pad/format, random string, hash, string diff, checksum, natural sort, UUID v4                                                                                                     |
| **Object/Pipe**   | 12+                        | Pipe, compose, once; nullable (whenNonNull, mapNonNull, tryCast); assert, coalesce, require, shallow copy, copyWithDefaults                                                                                                                          |
| **Utilities**     | 25+                        | JSON validation/type/iterables, Base64, UUID, Hex, HTML entities, gesture types, regex common/match, debug (testing)                                                                                                                                 |

<!-- cspell:enable -->

## Installation

Run from your project directory:

```bash
flutter pub add saropa_dart_utils
```

Or for a pure Dart project:

```bash
dart pub add saropa_dart_utils
```

Then import it:

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';
```

For **minimal bundle size**, import only what you use (tree-shaking friendly):

```dart
import 'package:saropa_dart_utils/string/string_extensions.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';
import 'package:saropa_dart_utils/async/debounce_utils.dart';  // or throttle_utils, retry_utils, etc.
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

### Async (debounce, throttle, retry, circuit breaker, and more)

```dart
// Debounce a callback (no-arg)
final debouncedSearch = debounce(() => fetchSuggestions(), Duration(milliseconds: 300));
debouncedSearch();  // call when user types; runs after 300 ms of no further calls

// Retry with exponential backoff
final result = await retryWithBackoff(() => http.get(uri), maxAttempts: 3);

// Limit concurrency
final semaphore = AsyncSemaphore(2);
await semaphore.run(() => heavyWork());
```

### Collections, Graph, Stats, Validation

```dart
// Longest increasing subsequence (top-level function)
lisLength([3, 1, 4, 1, 5, 9, 2, 6]);  // 4

// Shortest distances from source (Dijkstra)
final distances = dijkstraDistances(weightedGraph, source);

// Safe parsing (no-throw, returns ParseOk/ParseErr)
final result = safeParse(int.parse, formValue);
final width = result.valueOrNull;  // int? (null if parse failed)
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

## Finding opportunities in your project

A CLI tool scans Dart files and suggests places where `saropa_dart_utils` can replace boilerplate (e.g. `x == null || x.isEmpty` → `x.isNullOrEmpty`, `s ?? ''` → `s.orEmpty()`). Run from this repo:

```bash
# With path: non-interactive, report to stdout (e.g. for CI)
dart run tool/suggest_saropa_utils.dart /path/to/your/flutter_app

# Without path: interactive — asks Y/N/? for directory, output format, and apply
dart run tool/suggest_saropa_utils.dart

dart run tool/suggest_saropa_utils.dart --help
```

Only `[path]`, `--help`, and `--version` are accepted. Interactive prompts ask for directory, report vs JSON, and whether to apply (apply not yet implemented). Type `?` on any prompt for help. No edits are made; use the report to refactor manually.

## Lint configuration

This package uses [saropa_lints](https://pub.dev/packages/saropa_lints). Some rules are disabled for a pure Dart utility library (e.g. barrel file for the main entry point, non-ASCII in source for Unicode handling, static state for shared RegExp/constants). Others are satisfied by code fixes or inline suppressions (e.g. collapsed ifs in json_utils, named booleans in html_utils, redundant else removed, long-parameter-list and similar-names suppressed where intentional). Rationale for each override or resolution is in `analysis_options_custom.yaml`.

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
