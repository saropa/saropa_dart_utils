import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/linear_regression_utils.dart';

void main() {
  group('linearRegression', () {
    test('fits a perfect line y = 2x', () {
      final (double slope, double intercept) = linearRegression(
        <num>[1, 2, 3, 4, 5],
        <num>[2, 4, 6, 8, 10],
      );
      expect(slope, closeTo(2.0, 1e-9));
      expect(intercept, closeTo(0.0, 1e-9));
    });

    test('fits a line with non-zero intercept', () {
      // y = 3x + 1.
      final (double slope, double intercept) = linearRegression(
        <num>[0, 1, 2, 3],
        <num>[1, 4, 7, 10],
      );
      expect(slope, closeTo(3.0, 1e-9));
      expect(intercept, closeTo(1.0, 1e-9));
    });

    test('least-squares fit on noisy data', () {
      // x=[0,1,2,3], y=[1,3,2,5]; hand-computed slope=1.1, intercept=1.1.
      final (double slope, double intercept) = linearRegression(
        <num>[0, 1, 2, 3],
        <num>[1, 3, 2, 5],
      );
      expect(slope, closeTo(1.1, 1e-9));
      expect(intercept, closeTo(1.1, 1e-9));
    });

    test('constant x (zero denominator) returns NaN', () {
      final (double slope, double intercept) = linearRegression(
        <num>[2, 2, 2],
        <num>[1, 2, 3],
      );
      expect(slope, isNaN);
      expect(intercept, isNaN);
    });

    test('mismatched lengths return NaN', () {
      final (double slope, double intercept) = linearRegression(<num>[1, 2], <num>[1]);
      expect(slope, isNaN);
      expect(intercept, isNaN);
    });

    test('fewer than two points returns NaN', () {
      final (double slope, double intercept) = linearRegression(<num>[1], <num>[2]);
      expect(slope, isNaN);
      expect(intercept, isNaN);
    });
  });
}
