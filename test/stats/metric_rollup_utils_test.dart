import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/metric_rollup_utils.dart';

void main() {
  group('rollupSum', () {
    test('sums the list', () {
      expect(rollupSum(<double>[1, 2, 3, 4]), 10.0);
    });

    test('empty sums to 0', () {
      expect(rollupSum(<double>[]), 0.0);
    });

    test('negatives', () {
      expect(rollupSum(<double>[-1, -2, 3]), 0.0);
    });
  });

  group('rollupAvg', () {
    test('averages the list', () {
      expect(rollupAvg(<double>[2, 4, 6]), 4.0);
    });

    test('empty returns NaN', () {
      expect(rollupAvg(<double>[]), isNaN);
    });

    test('single element', () {
      expect(rollupAvg(<double>[9]), 9.0);
    });
  });

  group('rollupDailyToPeriod', () {
    test('applies the provided op (sum)', () {
      expect(rollupDailyToPeriod(<double>[1, 2, 3], rollupSum), 6.0);
    });

    test('applies the provided op (avg)', () {
      expect(rollupDailyToPeriod(<double>[2, 4, 6], rollupAvg), 4.0);
    });

    test('empty returns NaN regardless of op', () {
      expect(rollupDailyToPeriod(<double>[], rollupSum), isNaN);
    });
  });
}
