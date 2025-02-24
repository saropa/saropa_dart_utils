import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_extensions.dart';

void main() {
  group('NumberExtensions', () {
    group('isNotZeroOrNegative', () {
      test('Positive number returns true', () {
        expect(1.isNotZeroOrNegative, true);
        expect(100.isNotZeroOrNegative, true);
        expect(0.001.isNotZeroOrNegative, true);
      });

      test('Zero returns false', () {
        expect(0.isNotZeroOrNegative, false);
        expect(0.0.isNotZeroOrNegative, false);
      });

      test('Negative number returns false', () {
        expect((-1).isNotZeroOrNegative, false);
        expect((-100).isNotZeroOrNegative, false);
        expect((-0.001).isNotZeroOrNegative, false);
      });
    });

    group('isZeroOrNegative', () {
      test('Positive number returns false', () {
        expect(1.isZeroOrNegative, false);
        expect(100.isZeroOrNegative, false);
        expect(0.001.isZeroOrNegative, false);
      });

      test('Zero returns true', () {
        expect(0.isZeroOrNegative, true);
        expect(0.0.isZeroOrNegative, true);
      });

      test('Negative number returns true', () {
        expect((-1).isZeroOrNegative, true);
        expect((-100).isZeroOrNegative, true);
        expect((-0.001).isZeroOrNegative, true);
      });
    });

    group('length', () {
      test('Positive integer length', () {
        expect(123.length(), 3);
        expect(0.length(), 1);
        expect(9999.length(), 4);
      });

      test('Negative integer length', () {
        expect((-123).length(), 4); // Includes the negative sign
        expect((-0).length(), 1); // Corrected expectation: Dart toString() for -0 is "0"
      });

      test('Decimal number length', () {
        expect(123.45.length(), 6); // Includes decimal point
        expect(0.123.length(), 5);
        expect((-123.45).length(), 7); // Includes negative sign and decimal point
      });
    });
  });

  group('NumberNullableFormats', () {
    group('isNotNullZeroOrNegative', () {
      test('Null number returns false', () {
        const num? n = null;
        expect(n.isNotNullZeroOrNegative, false);
      });

      test('Zero number returns false', () {
        const num n = 0;
        expect(n.isNotNullZeroOrNegative, false);
      });

      test('Negative number returns false', () {
        const num n = -1;
        expect(n.isNotNullZeroOrNegative, false);
      });

      test('Positive number returns true', () {
        const num n = 1;
        expect(n.isNotNullZeroOrNegative, true);
      });
    });

    group('isNullZeroOrNegative', () {
      test('Null number returns true', () {
        const num? n = null;
        expect(n.isNullZeroOrNegative, true);
      });

      test('Zero number returns true', () {
        const num n = 0;
        expect(n.isNullZeroOrNegative, true);
      });

      test('Negative number returns true', () {
        const num n = -1;
        expect(n.isNullZeroOrNegative, true);
      });

      test('Positive number returns false', () {
        const num n = 1;
        expect(n.isNullZeroOrNegative, false);
      });
    });

    group('isNullOrZero', () {
      test('Null number returns true', () {
        const num? n = null;
        expect(n.isNullOrZero, true);
      });

      test('Zero number returns true', () {
        const num n = 0;
        expect(n.isNullOrZero, true);
      });

      test('Positive number returns false', () {
        const num n = 1;
        expect(n.isNullOrZero, false);
      });

      test('Negative number returns false', () {
        const num n = -1;
        expect(n.isNullOrZero, false);
      });
    });

    group('isNotNullOrZero', () {
      test('Null number returns false', () {
        const num? n = null;
        expect(n.isNotNullOrZero, false);
      });

      test('Zero number returns false', () {
        const num n = 0;
        expect(n.isNotNullOrZero, false);
      });

      test('Positive number returns true', () {
        const num n = 1;
        expect(n.isNotNullOrZero, true);
      });

      test('Negative number returns true', () {
        const num n = -1;
        expect(n.isNotNullOrZero, true);
      });
    });

    group('isGreaterThanZero', () {
      test('Null number returns false', () {
        const num? n = null;
        expect(n.isGreaterThanZero, false);
      });

      test('Zero number returns false', () {
        const num n = 0;
        expect(n.isGreaterThanZero, false);
      });

      test('Positive number returns true', () {
        const num n = 1;
        expect(n.isGreaterThanZero, true);
      });

      test('Negative number returns false', () {
        const num n = -1;
        expect(n.isGreaterThanZero, false);
      });
    });

    group('isGreaterThanOne', () {
      test('Null number returns false', () {
        const num? n = null;
        expect(n.isGreaterThanOne, false);
      });

      test('Zero number returns false', () {
        const num n = 0;
        expect(n.isGreaterThanOne, false);
      });

      test('One number returns false', () {
        const num n = 1;
        expect(n.isGreaterThanOne, false);
      });

      test('Number greater than one returns true', () {
        const num n = 2;
        expect(n.isGreaterThanOne, true);
      });

      test('Negative number returns false', () {
        const num n = -1;
        expect(n.isGreaterThanOne, false);
      });
    });
  });
}
