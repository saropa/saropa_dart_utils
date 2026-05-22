import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/interval_scheduling_utils.dart';

void main() {
  group('IntervalSchedulingUtils', () {
    test('should expose start and end', () {
      const IntervalSchedulingUtils iv = IntervalSchedulingUtils(2, 5);
      expect(iv.start, 2);
      expect(iv.end, 5);
    });

    test('should format toString with start and end', () {
      expect(
        const IntervalSchedulingUtils(1, 3).toString(),
        'IntervalSchedulingUtils(start: 1, end: 3)',
      );
    });
  });

  group('maxNonOverlappingIntervals', () {
    test('should pick a maximal set by earliest end time', () {
      final List<IntervalSchedulingUtils> intervals = [
        const IntervalSchedulingUtils(1, 3),
        const IntervalSchedulingUtils(2, 5),
        const IntervalSchedulingUtils(4, 7),
        const IntervalSchedulingUtils(6, 8),
      ];
      final List<IntervalSchedulingUtils> result = maxNonOverlappingIntervals(intervals);
      expect(result.map((IntervalSchedulingUtils e) => (e.start, e.end)).toList(), [
        (1, 3),
        (4, 7),
      ]);
    });

    test('should return empty list for empty input', () {
      expect(maxNonOverlappingIntervals(<IntervalSchedulingUtils>[]), <IntervalSchedulingUtils>[]);
    });

    test('should return the single interval unchanged', () {
      final List<IntervalSchedulingUtils> result = maxNonOverlappingIntervals([
        const IntervalSchedulingUtils(0, 10),
      ]);
      expect(result, hasLength(1));
      expect(result.first.start, 0);
      expect(result.first.end, 10);
    });

    test('should keep all intervals when none overlap', () {
      final List<IntervalSchedulingUtils> intervals = [
        const IntervalSchedulingUtils(0, 1),
        const IntervalSchedulingUtils(1, 2),
        const IntervalSchedulingUtils(2, 3),
      ];
      expect(maxNonOverlappingIntervals(intervals), hasLength(3));
    });

    test('should keep only one of fully-overlapping intervals', () {
      final List<IntervalSchedulingUtils> intervals = [
        const IntervalSchedulingUtils(0, 10),
        const IntervalSchedulingUtils(1, 9),
        const IntervalSchedulingUtils(2, 8),
      ];
      // Earliest end is 8; the others all overlap it.
      final List<IntervalSchedulingUtils> result = maxNonOverlappingIntervals(intervals);
      expect(result, hasLength(1));
      expect(result.first.end, 8);
    });

    test('should treat touching intervals as non-overlapping (start >= end)', () {
      final List<IntervalSchedulingUtils> intervals = [
        const IntervalSchedulingUtils(0, 5),
        const IntervalSchedulingUtils(5, 10),
      ];
      expect(maxNonOverlappingIntervals(intervals), hasLength(2));
    });
  });
}
