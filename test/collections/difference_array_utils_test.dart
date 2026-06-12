import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/difference_array_utils.dart';

void main() {
  group('DifferenceArrayUtils', () {
    test('should produce all zeros with no updates', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(5);
      expect(diff.toArray(), [0, 0, 0, 0, 0]);
    });

    test('should apply a single range update', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(5)..addRange(1, 3, 2);
      expect(diff.toArray(), [0, 2, 2, 2, 0]);
    });

    test('should accumulate overlapping range updates', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(5)
        ..addRange(0, 2, 1)
        ..addRange(1, 4, 3);
      expect(diff.toArray(), [1, 4, 4, 3, 3]);
    });

    test('should support a full-length range including the last index', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(4)..addRange(0, 3, 5);
      expect(diff.toArray(), [5, 5, 5, 5]);
    });

    test('should update a single element range', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(3)..addRange(1, 1, 7);
      expect(diff.toArray(), [0, 7, 0]);
    });

    test('should ignore out-of-bounds ranges (negative left)', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(3)..addRange(-1, 2, 4);
      expect(diff.toArray(), [0, 0, 0]);
    });

    test('should ignore out-of-bounds ranges (right past end)', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(3)..addRange(0, 3, 4);
      expect(diff.toArray(), [0, 0, 0]);
    });

    test('should support negative deltas', () {
      final DifferenceArrayUtils diff = DifferenceArrayUtils(4)
        ..addRange(0, 3, 5)
        ..addRange(1, 2, -2);
      expect(diff.toArray(), [5, 3, 3, 5]);
    });

    test('should report length in toString', () {
      expect(DifferenceArrayUtils(5).toString(), 'DifferenceArrayUtils(length: 5)');
    });

    test('should ignore a reversed range (l > r) as a no-op', () {
      // A reversed range must not corrupt the array; it is silently ignored.
      final DifferenceArrayUtils diff = DifferenceArrayUtils(4)..addRange(3, 1, 5);
      expect(diff.toArray(), [0, 0, 0, 0]);
    });
  });
}
