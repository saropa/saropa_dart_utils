import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/weighted_interval_utils.dart';

void main() {
  group('WeightedIntervalUtils (interval)', () {
    test('should expose start, end, and weight', () {
      const WeightedIntervalUtils iv = WeightedIntervalUtils(1, 5, 10);
      expect(iv.start, 1);
      expect(iv.end, 5);
      expect(iv.weight, 10);
    });

    test('should format toString', () {
      expect(
        const WeightedIntervalUtils(1, 3, 7).toString(),
        'WeightedIntervalUtils(start: 1, end: 3, weight: 7)',
      );
    });
  });

  group('maxWeightIntervals', () {
    test('should pick the maximum total weight of non-overlapping intervals', () {
      final List<WeightedIntervalUtils> intervals = [
        const WeightedIntervalUtils(1, 3, 5),
        const WeightedIntervalUtils(2, 5, 6),
        const WeightedIntervalUtils(4, 6, 5),
        const WeightedIntervalUtils(6, 7, 4),
        const WeightedIntervalUtils(5, 8, 11),
        const WeightedIntervalUtils(7, 9, 2),
      ];
      // Best schedule: (1,3,5) + (4,6,5) + (6,...) path totals 17.
      expect(maxWeightIntervals(intervals), 17);
    });

    test('should return 0 for empty input', () {
      expect(maxWeightIntervals(<WeightedIntervalUtils>[]), 0);
    });

    test('should return the single interval weight', () {
      expect(maxWeightIntervals([const WeightedIntervalUtils(0, 10, 42)]), 42);
    });

    test('should pick the heavier of two fully-overlapping intervals', () {
      final List<WeightedIntervalUtils> intervals = [
        const WeightedIntervalUtils(0, 10, 5),
        const WeightedIntervalUtils(1, 9, 8),
      ];
      expect(maxWeightIntervals(intervals), 8);
    });

    test('should sum all weights when none overlap', () {
      final List<WeightedIntervalUtils> intervals = [
        const WeightedIntervalUtils(0, 1, 3),
        const WeightedIntervalUtils(1, 2, 4),
        const WeightedIntervalUtils(2, 3, 5),
      ];
      expect(maxWeightIntervals(intervals), 12);
    });

    test('should treat touching intervals as compatible', () {
      final List<WeightedIntervalUtils> intervals = [
        const WeightedIntervalUtils(0, 5, 10),
        const WeightedIntervalUtils(5, 10, 10),
      ];
      expect(maxWeightIntervals(intervals), 20);
    });
  });
}
