import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/robust_stats_utils.dart';

void main() {
  group('median', () {
    test('odd length returns middle', () {
      expect(median(<num>[3, 1, 2]), 2.0);
    });

    test('even length averages the two middle values', () {
      expect(median(<num>[1, 2, 3, 4]), 2.5);
    });

    test('does not mutate the caller input', () {
      final List<num> input = <num>[3, 1, 2];
      median(input);
      expect(input, <num>[3, 1, 2]);
    });

    test('single element', () {
      expect(median(<num>[7]), 7.0);
    });

    test('empty returns NaN', () {
      expect(median(<num>[]), isNaN);
    });
  });

  group('medianAbsoluteDeviation', () {
    test('MAD of a symmetric list', () {
      // median=3; abs devs=[2,1,0,1,2]; median of those=1.
      expect(medianAbsoluteDeviation(<num>[1, 2, 3, 4, 5]), 1.0);
    });

    test('all-equal values have MAD 0', () {
      expect(medianAbsoluteDeviation(<num>[5, 5, 5]), 0.0);
    });

    test('empty returns NaN', () {
      expect(medianAbsoluteDeviation(<num>[]), isNaN);
    });
  });

  group('trimmedMean', () {
    test('trims one element from each tail', () {
      // 10 values, trim 0.1 -> k=1, average of [2..9] = 44/8 = 5.5.
      expect(
        trimmedMean(<num>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 0.1),
        closeTo(5.5, 1e-9),
      );
    });

    test('trim <= 0 is the plain mean', () {
      expect(trimmedMean(<num>[1, 2, 3, 4], 0), closeTo(2.5, 1e-9));
    });

    test('trim is capped at 0.5', () {
      // trim clamped to 0.5: k=round(4*0.5)=2 -> start(2) >= end(2) -> NaN.
      expect(trimmedMean(<num>[1, 2, 3, 4], 0.9), isNaN);
    });

    test('empty returns NaN', () {
      expect(trimmedMean(<num>[], 0.1), isNaN);
    });
  });
}
