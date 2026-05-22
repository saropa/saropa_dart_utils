import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_group_by_extensions.dart';

void main() {
  group('groupByTransform', () {
    test('groups by key and transforms values', () {
      // Group words by first letter, store their lengths.
      final Map<String, List<int>> result = <String>[
        'apple',
        'avocado',
        'banana',
      ].groupByTransform((String s) => s[0], (String s) => s.length);
      expect(result, <String, List<int>>{
        'a': <int>[5, 7],
        'b': <int>[6],
      });
    });

    test('preserves encounter order within each group', () {
      final Map<int, List<String>> result = <String>[
        'a',
        'bb',
        'c',
        'dd',
      ].groupByTransform((String s) => s.length, (String s) => s.toUpperCase());
      expect(result[1], <String>['A', 'C']);
      expect(result[2], <String>['BB', 'DD']);
    });

    test('empty iterable yields empty map', () {
      expect(
        <int>[].groupByTransform((int x) => x, (int x) => x),
        <int, List<int>>{},
      );
    });

    test('single element yields single-key map', () {
      expect(
        <int>[5].groupByTransform((int x) => x.isEven, (int x) => x * 2),
        <bool, List<int>>{false: <int>[10]},
      );
    });

    test('all elements share one key', () {
      final Map<String, List<int>> result = <int>[
        1,
        2,
        3,
      ].groupByTransform((int _) => 'k', (int x) => x);
      expect(result, <String, List<int>>{'k': <int>[1, 2, 3]});
    });
  });
}
