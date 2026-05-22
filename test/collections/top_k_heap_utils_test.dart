import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/top_k_heap_utils.dart';

void main() {
  group('topKIndices', () {
    test('should return indices of the top-k by key', () {
      // values [5,1,8,3,9,2]; top 3 by value: 9(idx4),8(idx2),5(idx0).
      final List<int> result = topKIndices([5, 1, 8, 3, 9, 2], 3, (int x) => x);
      expect(result.toSet(), {0, 2, 4});
    });

    test('should return all indices when k >= length', () {
      expect(topKIndices([10, 20], 5, (int x) => x), [0, 1]);
    });

    test('should return empty list for empty values', () {
      expect(topKIndices(<int>[], 3, (int x) => x), <int>[]);
    });

    test('should return empty list when k < 1', () {
      expect(topKIndices([1, 2, 3], 0, (int x) => x), <int>[]);
    });

    test('should select top-1 (the maximum index)', () {
      final List<int> result = topKIndices([3, 7, 1, 9, 4], 1, (int x) => x);
      expect(result, [3]);
    });

    test('should use the keyOf projection', () {
      // Sort by string length: 'ccc'(idx2),'bb'(idx1) are the two longest.
      final List<int> result =
          topKIndices(['a', 'bb', 'ccc', 'd'], 2, (String s) => s.length);
      expect(result.toSet(), {1, 2});
    });

    test('should map keys from objects', () {
      final List<(String, int)> data = [('a', 5), ('b', 1), ('c', 9)];
      final List<int> result = topKIndices(data, 2, ((String, int) e) => e.$2);
      expect(result.toSet(), {0, 2}); // values 5 and 9 are top two
    });

    test('should handle negative keys', () {
      final List<int> result = topKIndices([-5, -1, -3], 1, (int x) => x);
      expect(result, [1]); // -1 is the largest
    });
  });
}
