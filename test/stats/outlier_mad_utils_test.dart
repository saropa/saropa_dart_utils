import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/outlier_mad_utils.dart';

void main() {
  group('outlierIndicesByMAD', () {
    test('flags a single extreme value', () {
      // values=[1,2,3,4,100]; median=3; abs devs=[2,1,0,1,97];
      // MAD=median([0,1,1,2,97])=1; only |100-3|/1=97 exceeds 3.5.
      expect(outlierIndicesByMAD(<num>[1, 2, 3, 4, 100]), <int>{4});
    });

    test('no outliers in tight data', () {
      expect(outlierIndicesByMAD(<num>[10, 11, 12, 13, 14]), isEmpty);
    });

    test('custom low threshold flags every off-median point', () {
      // values=[1,2,3,4,100]; median=3, MAD=1. Deviations in MAD units:
      // idx0=2, idx1=1, idx2=0, idx3=1, idx4=97. With threshold 0.5 every
      // index except the median (idx2) exceeds 0.5.
      final Set<int> flagged = outlierIndicesByMAD(<num>[1, 2, 3, 4, 100], threshold: 0.5);
      expect(flagged, <int>{0, 1, 3, 4});
    });

    test('all-equal values give MAD 0 -> no outliers', () {
      expect(outlierIndicesByMAD(<num>[5, 5, 5, 5]), isEmpty);
    });

    test('empty input returns empty set', () {
      expect(outlierIndicesByMAD(<num>[]), isEmpty);
    });
  });
}
