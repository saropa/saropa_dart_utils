import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/bin_packing_utils.dart';

void main() {
  group('firstFitBinPacking', () {
    test('should return one bin index per item', () {
      final List<int> result = firstFitBinPacking([4, 8, 1, 4, 2, 1], 10);
      expect(result, hasLength(6));
      expect(result, [0, 1, 0, 0, 1, 0]);
    });

    test('should place items that fit in the first bin', () {
      // 3 + 3 + 3 = 9 <= 10, all in bin 0.
      expect(firstFitBinPacking([3, 3, 3], 10), [0, 0, 0]);
    });

    test('should open a new bin when capacity is exceeded', () {
      // 6 in bin 0; 6 again does not fit (12 > 10), opens bin 1.
      expect(firstFitBinPacking([6, 6], 10), [0, 1]);
    });

    test('should return empty list for empty items', () {
      expect(firstFitBinPacking(<num>[], 10), <int>[]);
    });

    test('should give each item its own bin when each equals capacity', () {
      expect(firstFitBinPacking([5, 5, 5], 5), [0, 1, 2]);
    });

    test('should handle a single item', () {
      expect(firstFitBinPacking([3], 10), [0]);
    });

    test('should backfill an earlier bin when a later small item fits', () {
      // bin0=7, item 8 -> bin1=8, item 2 fits bin0 (7+2=9<=10).
      expect(firstFitBinPacking([7, 8, 2], 10), [0, 1, 0]);
    });

    test('should respect capacity changes', () {
      // With capacity 20 the same items collapse into fewer bins.
      expect(firstFitBinPacking([6, 6], 20), [0, 0]);
    });
  });
}
