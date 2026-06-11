# SPEC: List&lt;String&gt; helpers (joinWithFinal / removeTrimmedEmpty / anyContains / removeNullsAndTrimmedEmpty / toLowerCase / toUpperCase / firstNotEqualTo) — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** `lib/list/list_string_extensions.dart` (extend the existing `ListStringExtensions` + add a `NullableListStringExtensions on List<String?>`)
**Portability:** Pure Dart. No Flutter. One external dependency already used by the library: `package:collection` (for `firstWhereOrNull` / `firstOrNull` / `nonNulls`) — actually `firstOrNull`, `firstWhereOrNull` come from `package:collection`; `nonNulls` is core Dart (Iterable). The source also calls `String.nullIfEmpty(trimFirst:)`, which is the library's own `string_*` extension (`nullIfEmpty` exists in `string_extensions.dart`), and `Iterable.nullIfEmpty()` (list-empty → null) which the library already provides on lists. No `intl`/`quiver`.

## Purpose — what it does + why it is general-purpose (not proprietary)

A set of transforms/predicates over `List<String>` and `List<String?>`:

- **`joinWithFinal({separator, finalSeparator})`** — joins a list into a sentence with a distinct final connector: `['a','b','c'].joinWithFinal()` → `'a, b and c'`. Returns `null` for empty, the single item for length 1. (Distinct from `joinDisplayList`: it does **not** add a comma before the final connector — no Oxford comma — and does not trim/dedupe. It is the "British-style" `a, b and c`, vs `joinDisplayList`'s Oxford `a, b, and c`.)
- **`anyContains(check, {caseSensitive})`** — true if any element contains `check` as a substring, with optional case-insensitive matching. Null/empty `check` → false; empty list → false.
- **`removeTrimmedEmpty({trim})`** — drops entries that are empty after trimming; with `trim: true` (default) also trims survivors. Returns `null` (not `[]`) when nothing remains, so a caller distinguishes "no items" from a real result.
- **`removeNullsAndTrimmedEmpty({trim})`** (on `List<String?>`) — `nonNulls` then `removeTrimmedEmpty`.
- **`toLowerCase()` / `toUpperCase()`** — element-wise case mapping (on both `List<String>` and `List<String?>`, the nullable variant dropping nulls first).
- **`firstNotEqualTo(value)`** — first element not equal to `value` (or first element when `value` is null), else null.

All are domain-neutral string/collection plumbing: trimming, casing, substring search, sentence-joining. Nothing here references contacts, Saropa formats, icons, l10n, or search-query syntax.

### Excluded members (proprietary / app-specific / already in library) and why

| Member | Reason excluded |
|---|---|
| `joinDisplayList` (both `List<String>` and `List<String?>` overloads) | **Already in library** (`list_string_extensions.dart` — Oxford-comma natural-language join, `joiner`/`doubleJoiner`/`lastJoiner`/`isUnique`). Do not duplicate. |
| `StringListUtils.joinerDefault` / `doubleJoinerDefault` / `lastJoinerDefault` | Default constants that only feed `joinDisplayList`; the library version carries its own defaults. |
| `joinPairs()` | Proprietary search-term pairing (builds consecutive-term bigrams for the app's search index). Out of scope per instructions. |
| `toFirstInitialGroup` / `toFirstInitialGroupSorted` | App avatar/grouping logic (first-initial buckets with `'?'` fallback) — depends on `String.firstCharacter()`; contact-list-section specific, not general. |
| `firstNotNullOrEmpty` / `joinNotNullOrEmpty` | Candidates, but tightly coupled to the app's `removeEnd` / `nullIfEmpty` chain and overlap conceptually with `removeNullsAndTrimmedEmpty` + a join. Left out of this first cut to keep the surface minimal; can be a follow-up. |
| commented-out `prefixNotEmptyList` / `appendNotEmptyList` / `toStringList` / `unique()` | Dead code (marked `UNUSED`), not shipped. |
| `debug()` / `debugException()` calls | App Crashlytics/log reporting — stripped from quoted source below (try/catch retained as a bare guard or removed where the body cannot throw). |

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging stripped)

```dart
import 'package:collection/collection.dart';

extension ListStringExtensions on List<String> {
  /// First element not equal to [value]; when [value] is null, the first
  /// element (or null when the list is empty).
  String? firstNotEqualTo(String? value) =>
      value == null ? firstOrNull : firstWhereOrNull((String item) => item != value);

  /// Joins into a sentence with a distinct final connector, e.g.
  /// `['a', 'b', 'c'].joinWithFinal()` -> `'a, b and c'`. No Oxford comma
  /// (use `joinDisplayList` for that). Returns null for an empty list, and the
  /// sole element for a single-item list.
  String? joinWithFinal({String separator = ', ', String finalSeparator = 'and'}) {
    if (isEmpty) {
      return null;
    }

    if (length == 1) {
      return firstOrNull;
    }

    return '${sublist(0, length - 1).join(separator)} '
        '$finalSeparator $last';
  }

  /// True if any element contains [check] as a substring. Null/empty [check]
  /// or empty list -> false. [caseSensitive] false lowercases both sides.
  bool anyContains(String? check, {bool caseSensitive = true}) {
    if (isEmpty) {
      return false;
    }

    if (check == null || check.isEmpty) {
      // failed null or empty check
      return false;
    }

    if (caseSensitive) {
      return any((String e) => e.contains(check));
    }

    // Case-insensitive: lowercase both sides
    final String checkLower = check.toLowerCase();
    return any((String e) => e.toLowerCase().contains(checkLower));
  }

  /// Drops entries that are empty after trimming. With [trim] (default true)
  /// survivors are also trimmed. Returns null (not []) when nothing remains.
  List<String>? removeTrimmedEmpty({bool trim = true}) =>
      map((String e) => e.nullIfEmpty(trimFirst: trim)).nonNulls.toList().nullIfEmpty();

  /// Element-wise lowercase.
  List<String>? toLowerCase() => map((String e) => e.toLowerCase()).toList();

  /// Element-wise uppercase.
  List<String>? toUpperCase() => map((String e) => e.toUpperCase()).toList();
}

extension NullableListStringExtensions on List<String?> {
  /// `nonNulls` then [ListStringExtensions.toLowerCase].
  List<String>? toLowerCase() => nonNulls.toList().toLowerCase();

  /// `nonNulls` then [ListStringExtensions.toUpperCase].
  List<String>? toUpperCase() => nonNulls.toList().toUpperCase();

  /// `nonNulls` then [ListStringExtensions.removeTrimmedEmpty].
  List<String>? removeNullsAndTrimmedEmpty({bool trim = true}) =>
      nonNulls.toList().removeTrimmedEmpty(trim: trim);
}
```

> Note on the existing `ListStringExtensions` name collision: the library already declares `extension ListStringExtensions on List<String>` in `list_string_extensions.dart`. Add these methods to that **same** extension rather than declaring a second one with the same name, and put the nullable methods in a new `extension NullableListStringExtensions on List<String?>`.

> `removeTrimmedEmpty`/`removeNullsAndTrimmedEmpty` depend on the library's own `String.nullIfEmpty({trimFirst})` and `Iterable<String>.nullIfEmpty()`. Confirm both signatures match before porting (the contacts version of `nullIfEmpty(trimFirst:)` trims then returns null when empty). If the library's `nullIfEmpty` lacks a `trimFirst` parameter, implement the trim inline: `map((e) { final t = trim ? e.trim() : e; return t.isEmpty ? null : t; }).nonNulls.toList()` and return null when empty.

## Test cases — existing tests verbatim (from `test/lib/utils/primative/primative_utils_test.dart`, group `'String List Utils'`)

Existing coverage exists for `anyContains` and `removeNullsAndTrimmedEmpty`. `joinWithFinal`, `firstNotEqualTo`, `toLowerCase`, `toUpperCase`, and the `List<String>` `removeTrimmedEmpty` have **no** existing tests (proposed below).

```dart
group('anyContains', () {
  test('case sensitive finds exact match', () {
    expect(<String>['Hello', 'World'].anyContains('Hello', caseSensitive: true), isTrue);
  });

  test('case sensitive does not find different case', () {
    expect(<String>['Hello', 'World'].anyContains('hello', caseSensitive: true), isFalse);
  });

  test('case insensitive finds different case', () {
    expect(<String>['Hello', 'World'].anyContains('hello', caseSensitive: false), isTrue);
  });

  test('case insensitive finds substring', () {
    expect(<String>['HelloWorld', 'Test'].anyContains('world', caseSensitive: false), isTrue);
  });

  test('case sensitive finds substring with exact case', () {
    expect(<String>['HelloWorld', 'Test'].anyContains('World', caseSensitive: true), isTrue);
  });

  test('case sensitive does not find substring with different case', () {
    expect(<String>['HelloWorld', 'Test'].anyContains('world', caseSensitive: true), isFalse);
  });

  test('empty list returns false', () {
    expect(<String>[].anyContains('test'), isFalse);
  });

  test('null check returns false', () {
    expect(<String>['Hello'].anyContains(null), isFalse);
  });

  test('empty check returns false', () {
    expect(<String>['Hello'].anyContains(''), isFalse);
  });
});

group('removeNullsAndTrimmedEmpty', () {
  test('List should be empty', () {
    expect(<String?>[null, null, null].removeNullsAndTrimmedEmpty(), isNull);
    expect(<String?>['', null, ''].removeNullsAndTrimmedEmpty(), isNull);
    expect(<String?>[' ', null, ' '].removeNullsAndTrimmedEmpty(), isNull);
    expect(<String?>[' ', '     ', ' '].removeNullsAndTrimmedEmpty(), isNull);
  });

  test('List nulls should be removed', () {
    expect(<String?>[null, '', 'abc'].removeNullsAndTrimmedEmpty(), <String>['abc']);

    // space is OK
    expect(<String?>[null, ' ', 'abc'].removeNullsAndTrimmedEmpty(), <String>['abc']);
  });

  test('List nulls should be unchanged', () {
    expect(<String?>['123', 'test word', 'abc'].removeNullsAndTrimmedEmpty(), <String>[
      '123',
      'test word',
      'abc',
    ]);
  });

  test('List nulls should be trimmed', () {
    expect(
      <String?>['123 ', 'test word', 'abc'].removeNullsAndTrimmedEmpty()?.toList(),
      <String>[
        '123',
        'test word',
        'abc',
      ],
    );

    expect(
      <String?>['123', 'test word ', 'abc'].removeNullsAndTrimmedEmpty()?.toList(),
      <String>[
        '123',
        'test word',
        'abc',
      ],
    );

    expect(
      <String?>['123', 'test word', ' abc '].removeNullsAndTrimmedEmpty()?.toList(),
      <String>['123', 'test word', 'abc'],
    );

    expect(
      <String?>[
        '   123   ',
        '   test    word',
        '   abc   ',
      ].removeNullsAndTrimmedEmpty()?.toList(),
      <String>['123', 'test    word', 'abc'],
    );

    expect(
      <String?>['      ', '       ', '      '].removeNullsAndTrimmedEmpty()?.toList(),
      isNull,
    );
  });
});
```

### Proposed tests for the untested members

```dart
group('joinWithFinal', () {
  test('empty list returns null', () {
    expect(<String>[].joinWithFinal(), isNull);
  });
  test('single item returns that item, no connector', () {
    expect(<String>['Alice'].joinWithFinal(), 'Alice');
  });
  test('two items use the final connector only', () {
    expect(<String>['Alice', 'Bob'].joinWithFinal(), 'Alice and Bob');
  });
  test('three items: no Oxford comma before "and"', () {
    expect(<String>['Alice', 'Bob', 'Carol'].joinWithFinal(), 'Alice, Bob and Carol');
  });
  test('custom separators', () {
    expect(
      <String>['a', 'b', 'c'].joinWithFinal(separator: '; ', finalSeparator: 'or'),
      'a; b or c',
    );
  });
});

group('firstNotEqualTo', () {
  test('null value returns first element', () {
    expect(<String>['a', 'b'].firstNotEqualTo(null), 'a');
  });
  test('null value on empty list returns null', () {
    expect(<String>[].firstNotEqualTo(null), isNull);
  });
  test('returns first element differing from value', () {
    expect(<String>['a', 'a', 'b'].firstNotEqualTo('a'), 'b');
  });
  test('all-equal returns null', () {
    expect(<String>['a', 'a'].firstNotEqualTo('a'), isNull);
  });
});

group('toLowerCase / toUpperCase', () {
  test('lowercases each element', () {
    expect(<String>['Ab', 'CD'].toLowerCase(), <String>['ab', 'cd']);
  });
  test('uppercases each element', () {
    expect(<String>['Ab', 'cd'].toUpperCase(), <String>['AB', 'CD']);
  });
  test('nullable variant drops nulls first (lower)', () {
    expect(<String?>['Ab', null, 'CD'].toLowerCase(), <String>['ab', 'cd']);
  });
  test('nullable variant drops nulls first (upper)', () {
    expect(<String?>['Ab', null, 'cd'].toUpperCase(), <String>['AB', 'CD']);
  });
});

group('removeTrimmedEmpty (List<String>)', () {
  test('all-blank returns null', () {
    expect(<String>['', '  ', '\t'].removeTrimmedEmpty(), isNull);
  });
  test('trims survivors when trim true', () {
    expect(<String>[' a ', 'b'].removeTrimmedEmpty(), <String>['a', 'b']);
  });
  test('preserves surrounding space when trim false but still drops empties', () {
    expect(<String>[' a ', '   '].removeTrimmedEmpty(trim: false), <String>[' a ']);
  });
});
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

- **Empty / single-element**: `[]`, `['']`, `[' ']` for every member; confirm null-vs-empty-string return discipline (`removeTrimmedEmpty` returns `null`, never `[]`).
- **All-null / mixed-null** (`List<String?>`): `[null]`, `[null, null]`, `[null, 'x', null]` for `toLowerCase`/`toUpperCase`/`removeNullsAndTrimmedEmpty`.
- **Whitespace variety**: tab `\t`, newline `\n`, carriage return `\r`, vertical tab, form feed, and the **non-breaking space** ` ` and **zero-width space** `​` — Dart's `String.trim()` strips ` ` and most Unicode whitespace but **not** `​`; add `[' ', '​']` and assert which survive `removeTrimmedEmpty` (expect ` ` dropped, `​` kept as a non-empty element).
- **Unicode / emoji casing**: `'ß'` (German eszett — `toUpperCase()` yields `'SS'`, length change), `'İ'`/`'ı'` (Turkish dotted/dotless I — Dart uses invariant culture, not Turkish), accented `'é'` -> `'É'`, emoji `'😀'` (grinning face — case-invariant, must round-trip unchanged), combining marks. Assert `toLowerCase`/`toUpperCase` do not corrupt surrogate pairs.
- **`joinWithFinal`**: separators that are empty (`separator: ''`, `finalSeparator: ''`), multi-char, or contain the elements themselves; elements containing the separator substring (must not be re-split); very long list (e.g. 10_000 items) for performance/no-stack issues; element that is itself `''` (it is NOT dropped — `joinWithFinal` does no trimming, so `['a', '', 'c']` -> `'a,  and c'` — document this divergence from `joinDisplayList`).
- **`anyContains`**: `check` equal to the whole element; `check` longer than every element; case-insensitive with Unicode (`'É'` matches `'café'` lowercased? — `'É'.toLowerCase()` is `'é'`, so yes); empty-string element in the list with non-empty `check`; `check` containing `​`; performance with a 10_000-element list.
- **`firstNotEqualTo`**: list containing `''` and `value: ''`; case sensitivity (`firstNotEqualTo('a')` does NOT match `'A'`); list with one element equal to value (returns null).
- **`removeTrimmedEmpty` `trim:false` path**: `[' a ', '']` -> `[' a ']` (empty dropped, space-padded survivor untouched); a string that is non-empty but whitespace-only with `trim:false` (`['   ']` -> kept, since not literally empty). Verify the `nullIfEmpty(trimFirst:)` contract: with `trim:false`, a `'   '` entry is NOT dropped (only literal `''` is).
- **Immutability**: confirm none of these mutate the receiver (`removeTrimmedEmpty`/`toLowerCase`/`toUpperCase` return new lists; assert the original list is unchanged after the call).
- **Large input**: 1_000_000-element lists for the `map`-based members to confirm no quadratic behavior.
- **Locale independence**: explicitly assert casing is invariant-culture (Turkish `'i'.toUpperCase()` stays `'I'`, not `'İ'`) so behavior is deterministic across runtime locales.
```
