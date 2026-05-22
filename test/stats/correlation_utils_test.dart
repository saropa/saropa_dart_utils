import 'dart:math' show sqrt;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/correlation_utils.dart';

void main() {
  group('pearsonCorrelation', () {
    test('perfect positive correlation is 1.0', () {
      // y = 2x is perfectly linear and increasing.
      expect(pearsonCorrelation(<num>[1, 2, 3], <num>[2, 4, 6]), closeTo(1.0, 1e-9));
    });

    test('perfect negative correlation is -1.0', () {
      expect(pearsonCorrelation(<num>[1, 2, 3], <num>[6, 4, 2]), closeTo(-1.0, 1e-9));
    });

    test('hand-computed partial correlation', () {
      // x = [1,2,3,4,5], y = [2,4,5,4,5].
      // numerator = sumXY - sumX*sumY/n = 66 - 15*20/5 = 6.
      // denominator = (55 - 45)*(86 - 80) = 60.
      // r = 6 / sqrt(60).
      final double expected = 6 / sqrt(60);
      expect(
        pearsonCorrelation(<num>[1, 2, 3, 4, 5], <num>[2, 4, 5, 4, 5]),
        closeTo(expected, 1e-9),
      );
    });

    test('constant x series returns NaN (zero variance)', () {
      expect(pearsonCorrelation(<num>[3, 3, 3], <num>[1, 2, 3]), isNaN);
    });

    test('mismatched lengths return NaN', () {
      expect(pearsonCorrelation(<num>[1, 2, 3], <num>[1, 2]), isNaN);
    });

    test('fewer than two points returns NaN', () {
      expect(pearsonCorrelation(<num>[1], <num>[2]), isNaN);
      expect(pearsonCorrelation(<num>[], <num>[]), isNaN);
    });

    test('result clamped to valid range', () {
      final double r = pearsonCorrelation(<num>[10, 20, 30, 40], <num>[10, 20, 30, 40]);
      expect(r, lessThanOrEqualTo(1.0));
      expect(r, closeTo(1.0, 1e-9));
    });
  });
}
