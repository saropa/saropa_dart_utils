import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/cdf_utils.dart';

void main() {
  group('empiricalCdf', () {
    test('collapses duplicates and accumulates probability to 1.0', () {
      expect(empiricalCdf(<num>[1, 2, 2, 3]), <CdfPoint>[
        const CdfPoint(1, 0.25),
        const CdfPoint(2, 0.75),
        const CdfPoint(3, 1.0),
      ]);
    });

    test('handles unsorted input without mutating it', () {
      final List<num> input = <num>[3, 1, 2];
      final List<CdfPoint> cdf = empiricalCdf(input);
      expect(cdf.map((CdfPoint p) => p.value).toList(), <num>[1, 2, 3]);
      expect(cdf.last.p, 1.0);
      expect(input, <num>[3, 1, 2]); // unchanged
    });

    test('empty samples yield no points', () {
      expect(empiricalCdf(<num>[]), isEmpty);
    });
  });

  group('cdfAt', () {
    test('returns the fraction of samples at or below x', () {
      expect(cdfAt(<num>[1, 2, 3], 2), closeTo(2 / 3, 1e-9));
      expect(cdfAt(<num>[1, 2, 3], 0), 0);
      expect(cdfAt(<num>[1, 2, 3], 5), 1.0);
    });

    test('empty samples return 0', () {
      expect(cdfAt(<num>[], 1), 0);
    });
  });

  group('cumulativeHistogram', () {
    test('is the running total of the fixed histogram', () {
      expect(cumulativeHistogram(<num>[1, 2, 3, 4], <num>[0, 2, 4, 6]), <int>[1, 3, 4]);
    });

    test('too few edges yields empty', () {
      expect(cumulativeHistogram(<num>[1, 2], <num>[0]), isEmpty);
    });
  });
}
