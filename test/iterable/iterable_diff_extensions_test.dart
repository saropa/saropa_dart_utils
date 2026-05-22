import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_diff_extensions.dart';

void main() {
  group('diff', () {
    test('reports added, removed, and unchanged', () {
      // this = {1,2,3}; other = {2,3,4} -> added 4, removed 1, unchanged 2 & 3
      final (List<int> added, List<int> removed, List<int> unchanged) result = <int>[
        1,
        2,
        3,
      ].diff(<int>[2, 3, 4]);
      expect(result.$1.toSet(), <int>{4});
      expect(result.$2.toSet(), <int>{1});
      expect(result.$3.toSet(), <int>{2, 3});
    });

    test('identical sets: all unchanged, nothing added or removed', () {
      final (List<int> added, List<int> removed, List<int> unchanged) result = <int>[
        1,
        2,
      ].diff(<int>[1, 2]);
      expect(result.$1, <int>[]);
      expect(result.$2, <int>[]);
      expect(result.$3.toSet(), <int>{1, 2});
    });

    test('empty other: everything removed, nothing added or unchanged', () {
      final (List<int> added, List<int> removed, List<int> unchanged) result = <int>[
        1,
        2,
      ].diff(<int>[]);
      expect(result.$1, <int>[]);
      expect(result.$2.toSet(), <int>{1, 2});
      expect(result.$3, <int>[]);
    });

    test('empty this: everything added, nothing removed or unchanged', () {
      final (List<int> added, List<int> removed, List<int> unchanged) result = <int>[].diff(<int>[
        1,
        2,
      ]);
      expect(result.$1.toSet(), <int>{1, 2});
      expect(result.$2, <int>[]);
      expect(result.$3, <int>[]);
    });

    test('both empty: all three lists empty', () {
      final (List<int> added, List<int> removed, List<int> unchanged) result = <int>[].diff(
        <int>[],
      );
      expect(result.$1, <int>[]);
      expect(result.$2, <int>[]);
      expect(result.$3, <int>[]);
    });

    test('duplicates are de-duplicated via set semantics', () {
      // this has duplicate 1s; diff works on sets so each value appears once
      final (List<int> added, List<int> removed, List<int> unchanged) result = <int>[
        1,
        1,
        2,
      ].diff(<int>[2, 2, 3]);
      expect(result.$1.toSet(), <int>{3});
      expect(result.$2.toSet(), <int>{1});
      expect(result.$3.toSet(), <int>{2});
    });

    test('disjoint sets: all added and all removed, none unchanged', () {
      final (List<int> added, List<int> removed, List<int> unchanged) result = <int>[
        1,
        2,
      ].diff(<int>[3, 4]);
      expect(result.$1.toSet(), <int>{3, 4});
      expect(result.$2.toSet(), <int>{1, 2});
      expect(result.$3, <int>[]);
    });
  });
}
