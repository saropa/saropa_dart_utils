import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/gini_utils.dart';

void main() {
  group('giniCoefficient', () {
    test('perfectly equal distribution is 0', () {
      expect(giniCoefficient(<num>[1, 1, 1, 1]), closeTo(0.0, 1e-9));
    });

    test('single element is 0', () {
      expect(giniCoefficient(<num>[5]), closeTo(0.0, 1e-9));
    });

    test('maximally unequal distribution approaches (n-1)/n', () {
      // One holder has everything; for n = 4 the exact value is 3/4.
      expect(giniCoefficient(<num>[0, 0, 0, 10]), closeTo(0.75, 1e-9));
    });

    test('known small example', () {
      // [1,2,3,4] sorted has rank weights [-3,-1,1,3]; G = 0.25.
      expect(giniCoefficient(<num>[1, 2, 3, 4]), closeTo(0.25, 1e-9));
    });

    test('all zeros is 0 (no inequality, no divide by zero)', () {
      expect(giniCoefficient(<num>[0, 0, 0]), closeTo(0.0, 1e-9));
    });

    test('empty list is NaN', () {
      expect(giniCoefficient(<num>[]), isNaN);
    });

    test('order does not matter', () {
      expect(
        giniCoefficient(<num>[4, 1, 3, 2]),
        closeTo(giniCoefficient(<num>[1, 2, 3, 4]), 1e-12),
      );
    });

    test('negative values are rejected', () {
      expect(
        () => giniCoefficient(<num>[1, -2, 3]),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
