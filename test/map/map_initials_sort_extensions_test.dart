import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_initials_sort_extensions.dart';

void main() {
  group('InitialsSortingUtils.sortMap', () {
    group('spec sample cases', () {
      test('sorts letters before numbers', () {
        final Map<String, int> map = <String, int>{
          '1abc': 1,
          'abc': 2,
          '2def': 3,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // 'abc' starts with a letter, so it must come first.
        expect(sortedMap.keys.firstOrNull, 'abc');
        expect(sortedMap.keys, hasLength(3));
      });

      test('sorts letters alphabetically', () {
        final Map<String, int> map = <String, int>{
          'charlie': 3,
          'alpha': 1,
          'bravo': 2,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(
          sortedMap.keys.toList(),
          <String>['alpha', 'bravo', 'charlie'],
        );
      });

      test('sorts numbers numerically', () {
        final Map<String, int> map = <String, int>{'10': 10, '2': 2, '1': 1};
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap.keys.toList(), <String>['1', '2', '10']);
      });

      test('handles mixed letter and number starts correctly', () {
        final Map<String, int> map = <String, int>{
          '2nd': 2,
          'alpha': 1,
          '1st': 3,
          'beta': 4,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap.keys, hasLength(4));
        expect(sortedMap.keys.toList()[0], 'alpha');
        expect(sortedMap.keys.toList()[1], 'beta');
        expect(
          sortedMap.keys.skip(2).toSet(),
          containsAll(<String>['1st', '2nd']),
        );
      });

      test('sorts empty map', () {
        final Map<String, int> map = <String, int>{};
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap.keys.toList(), <String>[]);
      });

      test('single element map remains unchanged', () {
        final Map<String, int> map = <String, int>{'only': 1};
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap.keys.toList(), <String>['only']);
      });

      test('preserves values during sort', () {
        final Map<String, int> map = <String, int>{'b': 2, 'a': 1, 'c': 3};
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap['a'], 1);
        expect(sortedMap['b'], 2);
        expect(sortedMap['c'], 3);
      });
    });

    group('empty and whitespace initials', () {
      test('empty key does not throw and collates first', () {
        final Map<String, int> map = <String, int>{'b': 2, '': 0, 'a': 1};
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // '' is neither letter- nor number-initial, so it lands in the
        // lexicographic fallback where the empty string is the smallest value.
        expect(sortedMap.keys.firstOrNull, '');
        expect(sortedMap.keys, hasLength(3));
      });

      test('leading space and non-breaking space do not throw', () {
        final Map<String, int> map = <String, int>{
          ' leading': 1,
          ' nbsp': 2,
          'after': 3,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap.keys, hasLength(3));
        // None is a letter/digit initial, so all use the lexicographic
        // fallback by first code unit: ASCII space (0x20) < 'a' (0x61) < nbsp
        // (0xA0). So ' leading' is first and the nbsp key sorts after 'after'.
        expect(sortedMap.keys.firstOrNull, ' leading');
      });
    });

    group('symbol and punctuation initials', () {
      test('symbol initials collate lexicographically among themselves', () {
        final Map<String, int> map = <String, int>{
          '#tag': 1,
          '_x': 2,
          '@me': 3,
          '.dotfile': 4,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // Pure code-unit order: '#'(0x23) '.'(0x2E) '@'(0x40) '_'(0x5F).
        expect(
          sortedMap.keys.toList(),
          <String>['#tag', '.dotfile', '@me', '_x'],
        );
      });

      test('symbols sort deterministically relative to letters', () {
        final Map<String, int> map = <String, int>{'apple': 1, '#tag': 2};
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // '#'(0x23) < 'a'(0x61): the symbol-initial key falls to lexicographic
        // order and precedes the letter key. (No special "letter first" rule
        // fires because '#tag' is neither letter- nor number-initial.)
        expect(sortedMap.keys.firstOrNull, '#tag');
      });
    });

    group('Unicode and emoji initials (ASCII-only letter detection)', () {
      test('accented Latin initials fall to lexicographic, not alpha branch', () {
        final Map<String, int> map = <String, int>{
          'Angstrom': 1,
          'Ångstrom': 2, // Å U+00C5
          'é': 3, // é U+00E9
          'Ü': 4, // Ü U+00DC
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // [a-zA-Z] excludes Å/é/Ü, so they use code-unit order. ASCII
        // 'Angstrom' (A=0x41) precedes Ü(0xDC), Å(0xC5), é(0xE9).
        expect(sortedMap.keys, hasLength(4));
        expect(sortedMap.keys.firstOrNull, 'Angstrom');
      });

      test('emoji initial does not throw and uses lexicographic fallback', () {
        final Map<String, int> map = <String, int>{
          '\u{1F600}key': 1, // grinning face, non-BMP
          'a': 2,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap.keys, hasLength(2));
        // 'a'(0x61) < the high surrogate of U+1F600, so 'a' comes first.
        expect(sortedMap.keys.firstOrNull, 'a');
      });
    });

    group('numeric edge cases', () {
      test('signed numerics are not numeric and do not beat 10', () {
        final Map<String, int> map = <String, int>{
          '-5': 1,
          '+3': 2,
          '10': 3,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // '-'/'+' are not \d, so '-5' and '+3' are lexicographic; '10' is the
        // only number-initial pure int. '-5' must NOT numerically precede '10'.
        final List<String> keys = sortedMap.keys.toList();
        // '+'(0x2B) < '-'(0x2D) < '1'(0x31): lexicographic places signs first.
        expect(keys, <String>['+3', '-5', '10']);
      });

      test('huge numeric beyond int range falls to lexicographic, no throw', () {
        final Map<String, int> map = <String, int>{
          '99999999999999999999': 1,
          '2': 2,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // int.tryParse('99999999999999999999') overflows 2^63-1 and returns
        // null (and is null on the web too), so the pair compares
        // lexicographically. '2'(0x32) < '9'(0x39) by first code unit, so '2'
        // sorts first and the huge string sorts last.
        expect(sortedMap.keys, hasLength(2));
        expect(sortedMap.keys.firstOrNull, '2');
        expect(sortedMap.keys.lastOrNull, '99999999999999999999');
      });

      test('leading-zero numerics keep all entries and order stably', () {
        final Map<String, int> map = <String, int>{
          '007': 1,
          '7': 2,
          '70': 3,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // '007' == 7 numerically: without the lexicographic tie-break,
        // SplayTreeMap would DROP one of '007'/'7'. All three must survive,
        // and '70' (numerically 70) sorts last.
        expect(sortedMap.keys, hasLength(3));
        expect(sortedMap.keys.last, '70');
        // '007'(0x30...) < '7'(0x37) lexicographically breaks the 0-tie.
        expect(sortedMap.keys.toList(), <String>['007', '7', '70']);
        expect(sortedMap['007'], 1);
        expect(sortedMap['7'], 2);
        expect(sortedMap['70'], 3);
      });

      test('number-initial-but-not-pure-int falls through against pure ints', () {
        final Map<String, int> map = <String, int>{
          '1abc': 1,
          '1': 2,
          '10': 3,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        // '1abc' is number-initial but int.tryParse('1abc') is null, so the
        // numeric branch does not apply to it; it collates lexicographically.
        expect(sortedMap.keys, hasLength(3));
        // '1'(len1) < '10' < '1abc' by code-unit order.
        expect(sortedMap.keys.toList(), <String>['1', '10', '1abc']);
      });
    });

    group('correctness: no entries dropped by zero-returning comparator', () {
      test('distinct pure-int keys of equal value both retained', () {
        // '07', '7', '007' all equal 7 numerically. A comparator returning 0
        // for any two distinct keys would collapse them in the SplayTreeMap.
        final Map<String, int> map = <String, int>{
          '07': 1,
          '7': 2,
          '007': 3,
        };
        final SplayTreeMap<String, int> sortedMap = map.sortMap();
        expect(sortedMap.keys, hasLength(3));
        expect(sortedMap.values.toSet(), <int>{1, 2, 3});
      });
    });

    group('generic value type passthrough', () {
      test('V = List<int> values pass through unchanged', () {
        final Map<String, List<int>> map = <String, List<int>>{
          'b': <int>[2, 2],
          'a': <int>[1],
        };
        final SplayTreeMap<String, List<int>> sortedMap = map.sortMap();
        expect(sortedMap['a'], <int>[1]);
        expect(sortedMap['b'], <int>[2, 2]);
        expect(sortedMap.keys.toList(), <String>['a', 'b']);
      });

      test('V = Object? values pass through unchanged', () {
        final Map<String, Object?> map = <String, Object?>{
          'a': 1,
          'b': 'two',
          'c': null,
        };
        final SplayTreeMap<String, Object?> sortedMap = map.sortMap();
        expect(sortedMap['a'], 1);
        expect(sortedMap['b'], 'two');
        expect(sortedMap['c'], isNull);
        expect(sortedMap.keys, hasLength(3));
      });

      test('V = Null values pass through unchanged', () {
        final Map<String, Null> map = <String, Null>{'b': null, 'a': null};
        final SplayTreeMap<String, Null> sortedMap = map.sortMap();
        expect(sortedMap.keys.toList(), <String>['a', 'b']);
        expect(sortedMap['a'], isNull);
        expect(sortedMap['b'], isNull);
      });
    });
  });
}
