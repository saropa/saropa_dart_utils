import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/lis_utils.dart';

void main() {
  group('lisLength', () {
    test('should compute classic LIS length', () {
      expect(lisLength<num>([10, 9, 2, 5, 3, 7, 101, 18]), 4); // e.g. 2,5,7,101
    });

    test('should return 0 for empty list', () {
      expect(lisLength<num>(<num>[]), 0);
    });

    test('should return 1 for a single element', () {
      expect(lisLength<num>([5]), 1);
    });

    test('should return full length for a strictly increasing list', () {
      expect(lisLength<num>([1, 2, 3, 4, 5]), 5);
    });

    test('should return 1 for a strictly decreasing list', () {
      expect(lisLength<num>([5, 4, 3, 2, 1]), 1);
    });

    test('should not count equal values as increasing', () {
      // Strict comparison: a run of equal values has LIS length 1.
      expect(lisLength<num>([7, 7, 7]), 1);
    });

    test('should work for strings (lexicographic order)', () {
      expect(lisLength<String>(['b', 'a', 'c', 'd']), 3); // a,c,d
    });
  });

  group('lisIndices', () {
    test('should return indices of one LIS', () {
      expect(lisIndices<num>([10, 9, 2, 5, 3, 7, 101, 18]), [2, 3, 5, 6]);
    });

    test('should return empty list for empty input', () {
      expect(lisIndices<num>(<num>[]), <int>[]);
    });

    test('should return single index for a single element', () {
      expect(lisIndices<num>([42]), [0]);
    });

    test('should return all indices for a strictly increasing list', () {
      expect(lisIndices<num>([1, 2, 3]), [0, 1, 2]);
    });

    test('should yield a length matching lisLength', () {
      final List<num> input = [3, 1, 4, 1, 5, 9, 2, 6];
      expect(lisIndices<num>(input).length, lisLength<num>(input));
    });

    test('should produce indices in increasing order with increasing values', () {
      final List<num> input = [2, 5, 3, 7];
      final List<int> idx = lisIndices<num>(input);
      for (int i = 1; i < idx.length; i++) {
        expect(idx[i] > idx[i - 1], isTrue);
        expect(input[idx[i]] > input[idx[i - 1]], isTrue);
      }
    });
  });
}
