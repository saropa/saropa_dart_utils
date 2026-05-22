import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/histogram_utils.dart';

void main() {
  group('histogramFixed', () {
    test('should count values per bin (last bin inclusive)', () {
      // Bins [0,2),[2,4),[4,6]. 1->bin0; 2,3->bin1; 4,5->bin2.
      expect(histogramFixed([1, 2, 3, 4, 5], [0, 2, 4, 6]), [1, 2, 2]);
    });

    test('should include the right edge of the final bin', () {
      // 6 falls in the last bin [2,6] because the final upper edge is inclusive.
      expect(histogramFixed([6], [0, 2, 6]), [0, 1]);
    });

    test('should return empty list for fewer than two edges', () {
      expect(histogramFixed([1, 2, 3], [0]), <int>[]);
      expect(histogramFixed([1, 2, 3], <num>[]), <int>[]);
    });

    test('should return all-zero counts for empty values', () {
      expect(histogramFixed(<num>[], [0, 5, 10]), [0, 0]);
    });

    test('should drop values outside all bins', () {
      // -1 below first edge, 100 above last edge: both ignored.
      expect(histogramFixed([-1, 1, 100], [0, 2]), [1]);
    });

    test('should place a value on a bin boundary into the upper bin', () {
      // 2 is the start of bin [2,4), counted there, not in [0,2).
      expect(histogramFixed([2], [0, 2, 4]), [0, 1]);
    });
  });

  group('histogramQuantile', () {
    test('should bin values by quantile-derived edges', () {
      // sorted [1,2,3,4]; idx = (n-1)*q floored. q=0->sorted[0]=1,
      // q=0.5->floor(1.5)=sorted[1]=2, q=1->sorted[3]=4. Edges [1,2,4].
      // Bins [1,2),[2,4]: 1->bin0; 2,3,4->bin1 (last bin inclusive).
      expect(histogramQuantile([1, 2, 3, 4], [0.0, 0.5, 1.0]), [1, 3]);
    });

    test('should return empty list for empty values', () {
      expect(histogramQuantile(<num>[], [0.0, 1.0]), <int>[]);
    });

    test('should return empty list for fewer than two quantiles', () {
      expect(histogramQuantile([1, 2, 3], [0.5]), <int>[]);
    });

    test('should handle a single value', () {
      // Edges all equal the one value; one bin [v,v] inclusive captures it.
      expect(histogramQuantile([5], [0.0, 1.0]), [1]);
    });
  });
}
