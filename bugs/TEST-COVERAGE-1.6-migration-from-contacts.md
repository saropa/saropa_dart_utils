# TEST COVERAGE — 1.6.x migrated-util test cases harvested from Saropa Contacts

**Type:** Test-coverage offering (not a bug)
**Status:** Open — for maintainer review

---

## Why this exists

saropa_dart_utils 1.6.x absorbed these utilities (from the inclusion specs filed
by Saropa Contacts). The app removed its local copies, so the tests below were
testing **external** (now-library) code and were deleted from the consumer. They
are reproduced verbatim so the maintainer can diff them against the library's own
suite and fill any gap — the goal is BULLETPROOF methods with massive coverage.
Adopt only the deltas; some may already be covered.

NBSP is written as the escape ` ` and ellipsis as `…` on purpose — do not
paste raw U+00A0/U+2026, they flatten in transit.

---

## `String.preventOrphans({int minWrapChars})`

```dart
group('preventOrphans', () {
  test('ellipsis is glued to the preceding word', () {
    final String input = 'Importing Demo Companions …';
    expect(input.preventOrphans(), 'Importing Demo Companions …');
  });
  test('any short token in the middle is also glued', () {
    expect('Hello I am here'.preventOrphans(), 'Hello I am here');
  });
  test('long tokens on both sides keep a breakable space', () {
    expect('Importing Demo Companions'.preventOrphans(), 'Importing Demo Companions');
  });
  test('single-letter sequence is fully fused', () {
    expect('A B C D'.preventOrphans(), 'A B C D');
  });
  test('trailing 1-char punctuation is always caught', () {
    expect('End of sentence .'.preventOrphans(), 'End of sentence .');
  });
  test('short parenthesized count fuses with preceding word', () {
    expect('Results (5)'.preventOrphans(), 'Results (5)');
  });
  test('three-dot ellipsis is short enough to fuse', () {
    expect('Loading ...'.preventOrphans(), 'Loading ...');
  });
  test('string with no spaces is returned unchanged', () {
    expect('Singleword'.preventOrphans(), 'Singleword');
  });
  test('empty string is returned unchanged', () {
    expect(''.preventOrphans(), '');
  });
  test('custom minimum lets caller tune aggressiveness', () {
    expect('fit the box'.preventOrphans(), 'fit the box');
    expect('fit the box'.preventOrphans(minWrapChars: 3), 'fit the box');
    expect('a of b content'.preventOrphans(minWrapChars: 2), 'a of b content');
  });
});
```

---

## `String.splitCapitalizedUnicode({minLength, splitNumbers, splitBySpace})`

Non-ASCII test inputs use literal letters (`straße`, `Österreich`, Arabic, CJK) —
verify they survive intact in your editor before committing.

```dart
group('splitCapitalizedUnicode', () {
  test('splits helloWorld -> [hello, World]', () {
    expect('helloWorld'.splitCapitalizedUnicode(), <String>['hello', 'World']);
  });
  test('minLength merges short parts: aB (minLength:2) -> [aB]', () {
    expect('aB'.splitCapitalizedUnicode(minLength: 2), <String>['aB']);
  });
  test('unicode letters with capitals (straße / Mit / Osterreich, minLength 4 merges)', () {
    final List<String> parts =
        'straßeMitÖsterreich'.splitCapitalizedUnicode(minLength: 4);
    expect(parts, <String>['straßeMit', 'Österreich']);
  });
  test('splitNumbers true: Area51TestSite -> [Area, 51Test, Site]', () {
    expect('Area51TestSite'.splitCapitalizedUnicode(splitNumbers: true, minLength: 1),
        <String>['Area', '51Test', 'Site']);
  });
  test('splitBySpace true: "160 / 4A" -> [160, /, 4A]', () {
    expect('160 / 4A'.splitCapitalizedUnicode(splitBySpace: true, minLength: 2),
        <String>['160', '/', '4A']);
  });
  test('splitBySpace single chars: "A B C D" -> [A, B, C, D]', () {
    expect('A B C D'.splitCapitalizedUnicode(splitBySpace: true, minLength: 3),
        <String>['A', 'B', 'C', 'D']);
  });
});
```

---

## `List<String>.anyContains(needle, {caseSensitive})`

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
```

---

## `List<String?>.removeNullsAndTrimmedEmpty()`

```dart
group('removeNullsAndTrimmedEmpty', () {
  test('List should be empty', () {
    expect(<String?>[null, null, null].removeNullsAndTrimmedEmpty(), isNull);
    expect(<String?>['', null, ''].removeNullsAndTrimmedEmpty(), isNull);
    expect(<String?>[' ', null, ' '].removeNullsAndTrimmedEmpty(), isNull);
    expect(<String?>[' ', '     ', ' '].removeNullsAndTrimmedEmpty(), isNull);
  });
  test('List nulls should be removed', () {
    expect(<String?>[null, '', 'abc'].removeNullsAndTrimmedEmpty(), <String>['abc']);
    expect(<String?>[null, ' ', 'abc'].removeNullsAndTrimmedEmpty(), <String>['abc']);
  });
  test('List nulls should be unchanged', () {
    expect(<String?>['123', 'test word', 'abc'].removeNullsAndTrimmedEmpty(),
        <String>['123', 'test word', 'abc']);
  });
  test('List nulls should be trimmed', () {
    expect(<String?>['123 ', 'test word', 'abc'].removeNullsAndTrimmedEmpty()?.toList(),
        <String>['123', 'test word', 'abc']);
    expect(<String?>['123', 'test word', ' abc '].removeNullsAndTrimmedEmpty()?.toList(),
        <String>['123', 'test word', 'abc']);
    expect(<String?>['   123   ', '   test    word', '   abc   ']
            .removeNullsAndTrimmedEmpty()?.toList(),
        <String>['123', 'test    word', 'abc']);
    expect(<String?>['      ', '       ', '      ']
            .removeNullsAndTrimmedEmpty()?.toList(), isNull);
  });
});
```

---

## `Map<String, V>.sortMap()` (letters-before-numbers initial sort)

```dart
group('sortMap', () {
  test('sorts letters before numbers', () {
    final sorted = <String, int>{'1abc': 1, 'abc': 2, '2def': 3}.sortMap();
    expect(sorted.keys.firstOrNull, 'abc');
    expect(sorted.keys, hasLength(3));
  });
  test('sorts letters alphabetically', () {
    final sorted = <String, int>{'charlie': 3, 'alpha': 1, 'bravo': 2}.sortMap();
    expect(sorted.keys.toList(), <String>['alpha', 'bravo', 'charlie']);
  });
  test('sorts numbers numerically', () {
    final sorted = <String, int>{'10': 10, '2': 2, '1': 1}.sortMap();
    expect(sorted.keys.toList(), <String>['1', '2', '10']);
  });
  test('handles mixed letter and number starts', () {
    final sorted = <String, int>{'2nd': 2, 'alpha': 1, '1st': 3, 'beta': 4}.sortMap();
    expect(sorted.keys, hasLength(4));
    expect(sorted.keys.toList()[0], 'alpha');
    expect(sorted.keys.toList()[1], 'beta');
    expect(sorted.keys.skip(2).toSet(), containsAll(<String>['1st', '2nd']));
  });
  test('sorts empty map', () {
    expect(<String, int>{}.sortMap().keys.toList(), <String>[]);
  });
  test('single element map remains unchanged', () {
    expect(<String, int>{'only': 1}.sortMap().keys.toList(), <String>['only']);
  });
  test('preserves values during sort', () {
    final sorted = <String, int>{'b': 2, 'a': 1, 'c': 3}.sortMap();
    expect(sorted['a'], 1); expect(sorted['b'], 2); expect(sorted['c'], 3);
  });
});
```

---

## `sortNullableStringListInPlace(List<String?>)` (null-first in-place sort)

```dart
group('sortNullableStringListInPlace', () {
  test('empty', () {
    final list = <String?>[];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>[]));
  });
  test('single null', () {
    final list = <String?>[null];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<void>[null]));
  });
  test('multiple distinct', () {
    final list = <String?>['test2', 'test1', 'test3'];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>['test1', 'test2', 'test3']));
  });
  test('null sorts first', () {
    final list = <String?>['test2', null, 'test1'];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String?>[null, 'test1', 'test2']));
  });
  test('empty string sorts before non-empty', () {
    final list = <String?>['test', ''];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>['', 'test']));
  });
  test('10k identical / distinct / null (perf + stability)', () {
    final identical = List<String?>.filled(10000, 'test');
    expect(sortNullableStringListInPlace(identical), isTrue);
    expect(identical, equals(List<String?>.filled(10000, 'test')));
    final distinct = List<String?>.generate(10000, (int i) => 'test\$i');
    final expected = List<String?>.of(distinct)..sort();
    expect(sortNullableStringListInPlace(distinct), isTrue);
    expect(distinct, equals(expected));
    final nulls = List<String?>.filled(10000, null);
    expect(sortNullableStringListInPlace(nulls), isTrue);
    expect(nulls, equals(List<String?>.filled(10000, null)));
  });
});
```

---

## `DateTime` relative-time extension (isTomorrow / isYesterday / isOlderThanToday / relativeTime)

```dart
group('RelativeTime', () {
  test('isYesterday true for yesterday, false for today', () {
    final now = DateTime(2024, 6, 15);
    expect(DateTime(2024, 6, 14).isYesterday(now: now), isTrue);
    expect(now.isYesterday(now: now), isFalse);
  });
  test('isTomorrow true for tomorrow', () {
    final now = DateTime(2024, 6, 15);
    expect(DateTime(2024, 6, 16).isTomorrow(now: now), isTrue);
  });
  test('isOlderThanToday true for past, false for earlier-today', () {
    final now = DateTime(2024, 6, 15, 12, 0);
    expect(DateTime(2024, 6, 14).isOlderThanToday(now: now), isTrue);
    expect(DateTime(2024, 6, 15, 8, 0).isOlderThanToday(now: now), isFalse);
  });
  test('relativeTime buckets: moment/minute/hour/day/year/future', () {
    final now = DateTime(2024, 6, 15, 12, 0, 0);
    expect(DateTime(2024, 6, 15, 11, 59, 30).relativeTime(now: now), contains('moment'));
    expect(DateTime(2024, 6, 15, 11, 55, 0).relativeTime(now: now), contains('minute'));
    expect(DateTime(2024, 6, 15, 9, 0, 0).relativeTime(now: now), contains('hour'));
    expect(DateTime(2024, 6, 10).relativeTime(now: DateTime(2024, 6, 15)), contains('day'));
    expect(DateTime(2020, 6, 15).relativeTime(now: DateTime(2024, 6, 15)), contains('year'));
    expect(DateTime(2024, 6, 20).relativeTime(now: DateTime(2024, 6, 15)), contains('from now'));
  });
});
```

---

## Environment

- saropa_dart_utils: 1.6.1
- Source: Saropa Contacts test suite (removed 2026-06-13).
