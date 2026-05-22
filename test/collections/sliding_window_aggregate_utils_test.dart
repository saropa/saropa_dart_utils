import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/sliding_window_aggregate_utils.dart';

void main() {
  group('slidingWindow', () {
    test('should compute min over each window', () {
      expect(slidingWindow([1, 3, 2, 5, 4], 3, WindowAggregate.min), [1.0, 2.0, 2.0]);
    });

    test('should compute max over each window', () {
      expect(slidingWindow([1, 3, 2, 5, 4], 3, WindowAggregate.max), [3.0, 5.0, 5.0]);
    });

    test('should compute sum over each window', () {
      expect(slidingWindow([1, 3, 2, 5, 4], 3, WindowAggregate.sum), [6.0, 10.0, 11.0]);
    });

    test('should compute avg over each window', () {
      final List<double> result = slidingWindow([1, 3, 2, 5, 4], 3, WindowAggregate.avg);
      expect(result[0], closeTo(2.0, 1e-12));
      expect(result[1], closeTo(10 / 3, 1e-12));
      expect(result[2], closeTo(11 / 3, 1e-12));
    });

    test('should produce length-size+1 windows', () {
      // 5 values, window 2 -> 4 windows.
      expect(slidingWindow([1, 2, 3, 4, 5], 2, WindowAggregate.sum), hasLength(4));
    });

    test('should return one window when size equals length', () {
      expect(slidingWindow([2, 4, 6], 3, WindowAggregate.sum), [12.0]);
    });

    test('should return empty list when size > length', () {
      expect(slidingWindow([1, 2], 5, WindowAggregate.sum), <double>[]);
    });

    test('should return empty list when size < 1', () {
      expect(slidingWindow([1, 2, 3], 0, WindowAggregate.sum), <double>[]);
    });

    test('should handle a window of size 1 as the values themselves', () {
      expect(slidingWindow([5, 9, 1], 1, WindowAggregate.max), [5.0, 9.0, 1.0]);
    });

    test('should handle negative values for min', () {
      expect(slidingWindow([-1, -5, -3], 2, WindowAggregate.min), [-5.0, -5.0]);
    });
  });
}
