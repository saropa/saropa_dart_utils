import 'dart:math' show e, log;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/log_transform_utils.dart';

void main() {
  group('log1pSafe', () {
    test('log(1+0) is 0', () {
      expect(log1pSafe(0), closeTo(0.0, 1e-12));
    });

    test('log(1+x) for positive x', () {
      // log1pSafe(e-1) = log(e) = 1.
      expect(log1pSafe(e - 1), closeTo(1.0, 1e-9));
      // log1pSafe(9) = log(10).
      expect(log1pSafe(9), closeTo(log(10), 1e-9));
    });

    test('x = -1 returns negative infinity', () {
      expect(log1pSafe(-1), double.negativeInfinity);
    });

    test('x < -1 returns negative infinity (guard)', () {
      expect(log1pSafe(-5), double.negativeInfinity);
    });

    test('x just above -1 is finite and very negative', () {
      expect(log1pSafe(-0.5), closeTo(log(0.5), 1e-9));
    });
  });

  group('expSafe', () {
    test('exp(0) is 1', () {
      expect(expSafe(0), closeTo(1.0, 1e-12));
    });

    test('exp(1) is e', () {
      expect(expSafe(1), closeTo(e, 1e-9));
    });

    test('exp of negative', () {
      expect(expSafe(-1), closeTo(1 / e, 1e-9));
    });
  });

  group('logScale', () {
    test('maps each element via log1pSafe', () {
      // [0, 9] -> [log(1), log(10)].
      final List<double> result = logScale(<num>[0, 9]);
      expect(result[0], closeTo(0.0, 1e-12));
      expect(result[1], closeTo(log(10), 1e-9));
    });

    test('empty returns empty', () {
      expect(logScale(<num>[]), isEmpty);
    });
  });
}
