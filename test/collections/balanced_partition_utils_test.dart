import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/balanced_partition_utils.dart';

void main() {
  group('balancedPartitionIndices', () {
    test('should return one index per element', () {
      final List<int> result = balancedPartitionIndices([3, 1, 4, 1, 5, 9, 2, 6], 3);
      expect(result, hasLength(8));
      expect(result, [0, 1, 2, 1, 1, 0, 2, 2]);
    });

    test('should assign each element to current smallest partition', () {
      // All equal weights spread round-robin across k partitions.
      expect(balancedPartitionIndices([1, 1, 1, 1], 2), [0, 1, 0, 1]);
    });

    test('should place everything in one partition when k is 1', () {
      expect(balancedPartitionIndices([5, 2, 8], 1), [0, 0, 0]);
    });

    test('should return empty list for empty values', () {
      expect(balancedPartitionIndices(<num>[], 3), <int>[]);
    });

    test('should return empty list when k is less than 1', () {
      expect(balancedPartitionIndices([1, 2, 3], 0), <int>[]);
      expect(balancedPartitionIndices([1, 2, 3], -2), <int>[]);
    });

    test('should handle single element', () {
      expect(balancedPartitionIndices([42], 3), [0]);
    });

    test('should keep all indices within range 0..k-1', () {
      final List<int> result = balancedPartitionIndices([7, 3, 9, 1, 6], 3);
      expect(result.every((int i) => i >= 0 && i < 3), isTrue);
    });

    test('should send a large value to its own partition after small ones', () {
      // 10 goes to partition 0; then 1,2 fill the two empty partitions.
      expect(balancedPartitionIndices([10, 1, 2], 3), [0, 1, 2]);
    });
  });
}
