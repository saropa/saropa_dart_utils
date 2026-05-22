// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/multi_criteria_sort_utils.dart';

void main() {
  group('sortByCriteria', () {
    test('should sort by the supplied comparator', () {
      expect(sortByCriteria([3, 1, 2], (int a, int b) => a.compareTo(b)), [1, 2, 3]);
    });

    test('should sort descending with a reversed comparator', () {
      expect(sortByCriteria([1, 3, 2], (int a, int b) => b.compareTo(a)), [3, 2, 1]);
    });

    test('should not mutate the original list', () {
      final List<int> original = [3, 1, 2];
      sortByCriteria(original, (int a, int b) => a.compareTo(b));
      expect(original, [3, 1, 2]);
    });

    test('should return empty list for empty input', () {
      expect(sortByCriteria(<int>[], (int a, int b) => a.compareTo(b)), <int>[]);
    });

    test('should return single element unchanged', () {
      expect(sortByCriteria([7], (int a, int b) => a.compareTo(b)), [7]);
    });

    test('should sort strings by length', () {
      expect(
        sortByCriteria(['ccc', 'a', 'bb'], (String a, String b) => a.length.compareTo(b.length)),
        ['a', 'bb', 'ccc'],
      );
    });
  });

  group('thenBy', () {
    int byFirst(List<int> a, List<int> b) => a[0].compareTo(b[0]);
    int bySecond(List<int> a, List<int> b) => a[1].compareTo(b[1]);

    test('should use the primary comparator when it is decisive', () {
      final int Function(List<int>, List<int>) cmp = thenBy<List<int>>(byFirst, bySecond);
      expect(cmp([1, 9], [2, 0]) < 0, isTrue);
    });

    test('should fall back to the secondary comparator on a tie', () {
      final int Function(List<int>, List<int>) cmp = thenBy<List<int>>(byFirst, bySecond);
      // Primary keys tie (both 1); secondary breaks it (1 < 2).
      expect(cmp([1, 1], [1, 2]) < 0, isTrue);
      expect(cmp([1, 2], [1, 1]) > 0, isTrue);
    });

    test('should return 0 when both comparators tie', () {
      final int Function(List<int>, List<int>) cmp = thenBy<List<int>>(byFirst, bySecond);
      expect(cmp([1, 1], [1, 1]), 0);
    });

    test('should drive a full sort with primary then secondary order', () {
      final List<List<int>> data = [
        [2, 1],
        [1, 2],
        [1, 1],
        [2, 0],
      ];
      final List<List<int>> sorted = sortByCriteria(data, thenBy<List<int>>(byFirst, bySecond));
      expect(sorted, [
        [1, 1],
        [1, 2],
        [2, 0],
        [2, 1],
      ]);
    });
  });
}
