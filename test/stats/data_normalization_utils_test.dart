import 'dart:math' show sqrt;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/data_normalization_utils.dart';

void main() {
  group('zScoreNormalize', () {
    test('centers and scales by population std', () {
      // mean = 3, population variance = 10/5 = 2, std = sqrt(2).
      final List<double> result = zScoreNormalize(<num>[1, 2, 3, 4, 5]);
      final double std = sqrt(2);
      expect(result[0], closeTo(-2 / std, 1e-9));
      expect(result[1], closeTo(-1 / std, 1e-9));
      expect(result[2], closeTo(0.0, 1e-9));
      expect(result[3], closeTo(1 / std, 1e-9));
      expect(result[4], closeTo(2 / std, 1e-9));
    });

    test('all-equal values map to zero (std fallback to 1)', () {
      // variance is 0, so std defaults to 1 and every (x-mean) is 0.
      expect(zScoreNormalize(<num>[7, 7, 7]), <double>[0.0, 0.0, 0.0]);
    });

    test('empty returns empty list', () {
      expect(zScoreNormalize(<num>[]), isEmpty);
    });

    test('single element maps to 0', () {
      // mean equals the value; std fallback to 1 -> 0.
      expect(zScoreNormalize(<num>[42]), <double>[0.0]);
    });
  });

  group('minMaxScale', () {
    test('scales to default [0, 1]', () {
      expect(minMaxScale(<num>[0, 5, 10]), <double>[0.0, 0.5, 1.0]);
    });

    test('scales to custom range', () {
      // low=10, high=20: 0->10, 5->15, 10->20.
      expect(minMaxScale(<num>[0, 5, 10], low: 10, high: 20), <double>[10.0, 15.0, 20.0]);
    });

    test('negative values', () {
      // min=-10, max=10, range=20: -10->0, 0->0.5, 10->1.
      expect(minMaxScale(<num>[-10, 0, 10]), <double>[0.0, 0.5, 1.0]);
    });

    test('all-equal values map to midpoint of target range', () {
      // max == min: every element maps to (low+high)/2.
      expect(minMaxScale(<num>[5, 5, 5]), <double>[0.5, 0.5, 0.5]);
      expect(minMaxScale(<num>[5, 5], low: 0, high: 10), <double>[5.0, 5.0]);
    });

    test('empty returns empty list', () {
      expect(minMaxScale(<num>[]), isEmpty);
    });
  });
}
