import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_stable_sort_extensions.dart';

void main() {
  group('stableSortBy', () {
    test('preserves input order for equal keys', () {
      // Three rows with key 1 must keep their a/b/c order.
      final List<(int, String)> rows = <(int, String)>[
        (1, 'a'),
        (2, 'x'),
        (1, 'b'),
        (2, 'y'),
        (1, 'c'),
      ];
      final List<(int, String)> sorted = rows.stableSortBy(((int, String) r) => r.$1);
      expect(sorted, <(int, String)>[(1, 'a'), (1, 'b'), (1, 'c'), (2, 'x'), (2, 'y')]);
    });

    test('does not mutate the source', () {
      final List<int> data = <int>[3, 1, 2];
      final List<int> sorted = data.stableSortBy((int x) => x);
      expect(sorted, <int>[1, 2, 3]);
      expect(data, <int>[3, 1, 2]);
    });

    test('empty iterable returns empty', () {
      expect(<int>[].stableSortBy((int x) => x), isEmpty);
    });
  });

  group('stableSort', () {
    test('uses the comparator and keeps equal elements in order', () {
      final List<String> words = <String>['bb', 'aa', 'cc', 'dd'];
      // Sort by length only; all length 2, so order is preserved.
      final List<String> sorted = words.stableSort(
        (String a, String b) => a.length.compareTo(b.length),
      );
      expect(sorted, <String>['bb', 'aa', 'cc', 'dd']);
    });

    test('sorts by the comparator when keys differ', () {
      final List<int> data = <int>[5, 3, 8, 1];
      expect(data.stableSort((int a, int b) => a.compareTo(b)), <int>[1, 3, 5, 8]);
    });
  });
}
