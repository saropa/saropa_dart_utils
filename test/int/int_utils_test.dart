import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/int/int_utils.dart';

void main() {
  group('findGreatestCommonDenominator', () {
    test('returns null when a or b is negative', () {
      expect(IntUtils.findGreatestCommonDenominator(-1, 1), isNull);
      expect(IntUtils.findGreatestCommonDenominator(1, -1), isNull);
    });

    test('returns null when a and b are both zero', () {
      expect(IntUtils.findGreatestCommonDenominator(0, 0), isNull);
    });

    test('returns the non-zero number when one of the numbers is zero', () {
      expect(IntUtils.findGreatestCommonDenominator(0, 5), equals(5));
      expect(IntUtils.findGreatestCommonDenominator(7, 0), equals(7));
    });

    test('returns 1 when a and b are co-prime', () {
      expect(IntUtils.findGreatestCommonDenominator(13, 7), equals(1));
    });

    test('returns the common factor when a and b are multiples of '
        'a common number', () {
      expect(IntUtils.findGreatestCommonDenominator(15, 45), equals(15));
    });

    test('returns a when a equals b', () {
      expect(IntUtils.findGreatestCommonDenominator(9, 9), equals(9));
    });

    // Add more test cases here...
  });
}
