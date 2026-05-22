import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/percentile_rank_utils.dart';

void main() {
  group('percentileRank', () {
    test('fraction of values strictly below', () {
      // [10,20,30,40]; two values (10,20) are < 30 -> 2/4.
      expect(percentileRank(<num>[10, 20, 30, 40], 30), 0.5);
    });

    test('value below all -> 0', () {
      expect(percentileRank(<num>[10, 20, 30], 5), 0.0);
    });

    test('value above all -> 1', () {
      expect(percentileRank(<num>[10, 20, 30], 100), 1.0);
    });

    test('value equal to first element counts nothing below it', () {
      expect(percentileRank(<num>[10, 20, 30], 10), 0.0);
    });

    test('empty returns NaN', () {
      expect(percentileRank(<num>[], 5), isNaN);
    });
  });

  group('percentile (nearest-rank)', () {
    test('median of odd-length list', () {
      // i = round(0.5 * 4) = 2 -> sorted[2] = 3.
      expect(percentile(<num>[1, 2, 3, 4, 5], 0.5), 3.0);
    });

    test('p = 0 returns first', () {
      expect(percentile(<num>[10, 20, 30, 40], 0), 10.0);
    });

    test('p = 1 returns last (clamped index)', () {
      expect(percentile(<num>[10, 20, 30, 40], 1), 40.0);
    });

    test('single element returns that element', () {
      expect(percentile(<num>[7], 0.5), 7.0);
    });

    test('empty returns NaN', () {
      expect(percentile(<num>[], 0.5), isNaN);
    });
  });
}
