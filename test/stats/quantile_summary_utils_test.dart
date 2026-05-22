import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/quantile_summary_utils.dart';

void main() {
  group('QuantileSummaryUtils', () {
    test('sorts the input and reports min/max', () {
      final QuantileSummaryUtils s = QuantileSummaryUtils(<num>[3, 1, 4, 2]);
      expect(s.min, 1.0);
      expect(s.max, 4.0);
    });

    test('quantile uses floor index on sorted data', () {
      // sorted=[1,2,3,4]; idx=(4-1)*0.5=1.5 floor 1 -> 2.
      final QuantileSummaryUtils s = QuantileSummaryUtils(<num>[1, 2, 3, 4]);
      expect(s.quantile(0.5), 2.0);
      expect(s.median, 2.0);
    });

    test('q1 and q3', () {
      // sorted=[1,2,3,4]; q1 idx=0.75 floor 0 -> 1; q3 idx=2.25 floor 2 -> 3.
      final QuantileSummaryUtils s = QuantileSummaryUtils(<num>[1, 2, 3, 4]);
      expect(s.q1, 1.0);
      expect(s.q3, 3.0);
    });

    test('p <= 0 clamps to min, p >= 1 clamps to max', () {
      final QuantileSummaryUtils s = QuantileSummaryUtils(<num>[5, 10, 15]);
      expect(s.quantile(-1), 5.0);
      expect(s.quantile(0), 5.0);
      expect(s.quantile(1), 15.0);
      expect(s.quantile(2), 15.0);
    });

    test('single element', () {
      final QuantileSummaryUtils s = QuantileSummaryUtils(<num>[42]);
      expect(s.min, 42.0);
      expect(s.max, 42.0);
      expect(s.median, 42.0);
    });

    test('empty gives NaN everywhere', () {
      final QuantileSummaryUtils s = QuantileSummaryUtils(<num>[]);
      expect(s.min, isNaN);
      expect(s.max, isNaN);
      expect(s.median, isNaN);
      expect(s.quantile(0.5), isNaN);
    });

    test('toString reports count, min and max', () {
      final QuantileSummaryUtils s = QuantileSummaryUtils(<num>[1, 2, 3]);
      expect(s.toString(), 'QuantileSummaryUtils(count: 3, min: 1.0, max: 3.0)');
    });
  });
}
