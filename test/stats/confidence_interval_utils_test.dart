import 'dart:math' show sqrt;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/confidence_interval_utils.dart';

void main() {
  group('confidenceInterval95', () {
    test('symmetric interval around the mean', () {
      // values = [2,4,6,8]; mean = 5.
      // sample variance = (9+1+1+9)/(4-1) = 20/3.
      // se = sqrt((20/3)/4) = sqrt(5/3).
      const double mean = 5.0;
      final double se = sqrt((20.0 / 3.0) / 4.0);
      final (double lower, double upper) = confidenceInterval95(<num>[2, 4, 6, 8]);
      expect(lower, closeTo(mean - 1.96 * se, 1e-9));
      expect(upper, closeTo(mean + 1.96 * se, 1e-9));
    });

    test('custom z widens the interval', () {
      final (double lower, double upper) = confidenceInterval95(
        <num>[2, 4, 6, 8],
        z: 2.58,
      );
      final double se = sqrt((20.0 / 3.0) / 4.0);
      expect(lower, closeTo(5.0 - 2.58 * se, 1e-9));
      expect(upper, closeTo(5.0 + 2.58 * se, 1e-9));
    });

    test('two identical values give zero-width interval', () {
      // variance is 0, so se is 0 and both bounds equal the mean.
      final (double lower, double upper) = confidenceInterval95(<num>[5, 5]);
      expect(lower, closeTo(5.0, 1e-12));
      expect(upper, closeTo(5.0, 1e-12));
    });

    test('single element returns NaN bounds', () {
      final (double lower, double upper) = confidenceInterval95(<num>[5]);
      expect(lower, isNaN);
      expect(upper, isNaN);
    });

    test('empty returns NaN bounds', () {
      final (double lower, double upper) = confidenceInterval95(<num>[]);
      expect(lower, isNaN);
      expect(upper, isNaN);
    });
  });
}
