import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_from_entries_extensions.dart';
import 'package:saropa_dart_utils/map/map_invert_extensions.dart';
import 'package:saropa_dart_utils/map/map_merge_extensions.dart';
import 'package:saropa_dart_utils/map/map_transform_extensions.dart';

void main() {
  group('invert', () {
    test('inverts keys and values', () {
      final Map<String, int> m = <String, int>{'a': 1, 'b': 2};
      expect(m.invert(), <int, String>{1: 'a', 2: 'b'});
    });
  });
  group('toEntriesList', () {
    test('returns list of pairs', () {
      final Map<String, int> m = <String, int>{'a': 1};
      expect(m.toEntriesList(), <(String, int)>[('a', 1)]);
    });
  });
  group('mapFromEntries', () {
    test('builds map from entries', () {
      final Map<String, int> m = mapFromEntries(<(String, int)>[('a', 1), ('b', 2)]);
      expect(m, <String, int>{'a': 1, 'b': 2});
    });
  });
  group('mapValues', () {
    test('transforms values', () {
      final Map<String, int> m = <String, int>{'a': 1, 'b': 2};
      expect(m.mapValues((int v) => v * 2), <String, int>{'a': 2, 'b': 4});
    });
  });
  group('mapKeys', () {
    test('transforms keys', () {
      final Map<String, int> m = <String, int>{'a': 1, 'b': 2};
      expect(m.mapKeys((String k) => k.toUpperCase()), <String, int>{'A': 1, 'B': 2});
    });
  });
  group('filterKeys', () {
    test('keeps only matching keys', () {
      final Map<String, int> m = <String, int>{'a': 1, 'b': 2, 'c': 3};
      expect(m.filterKeys((String k) => k != 'b'), <String, int>{'a': 1, 'c': 3});
    });
  });
  group('filterValues', () {
    test('keeps only matching values', () {
      final Map<String, int> m = <String, int>{'a': 1, 'b': 2, 'c': 3};
      expect(m.filterValues((int v) => v > 1), <String, int>{'b': 2, 'c': 3});
    });
  });
  group('mergeAll', () {
    test('merges list of maps', () {
      final List<Map<String, int>> list = <Map<String, int>>[
        <String, int>{'a': 1},
        <String, int>{'b': 2},
        <String, int>{'a': 3},
      ];
      expect(list.mergeAll(), <String, int>{'a': 3, 'b': 2});
    });
  });
}
