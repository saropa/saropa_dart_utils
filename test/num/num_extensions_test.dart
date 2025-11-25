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

    group('toDoubleOrNull', () {
      test('1. Null returns null', () {
        const num? n = null;
        expect(n.toDoubleOrNull(), isNull);
      });
      test('2. Integer converts to double', () {
        const num n = 42;
        expect(n.toDoubleOrNull(), 42.0);
      });
      test('3. Double returns double', () {
        const num n = 3.14;
        expect(n.toDoubleOrNull(), 3.14);
      });
      test('4. Zero converts to 0.0', () {
        const num n = 0;
        expect(n.toDoubleOrNull(), 0.0);
      });
      test('5. Negative integer', () {
        const num n = -5;
        expect(n.toDoubleOrNull(), -5.0);
      });
      test('6. Negative double', () {
        const num n = -3.14;
        expect(n.toDoubleOrNull(), -3.14);
      });
      test('7. Large integer', () {
        const num n = 1000000;
        expect(n.toDoubleOrNull(), 1000000.0);
      });
      test('8. Small decimal', () {
        const num n = 0.001;
        expect(n.toDoubleOrNull(), 0.001);
      });
      test('9. Result is double type', () {
        const num n = 10;
        expect(n.toDoubleOrNull(), isA<double>());
      });
      test('10. Integer one', () {
        const num n = 1;
        expect(n.toDoubleOrNull(), 1.0);
      });
    });

    group('toIntOrNull', () {
      test('1. Null returns null', () {
        const num? n = null;
        expect(n.toIntOrNull(), isNull);
      });
      test('2. Integer returns int', () {
        const num n = 42;
        expect(n.toIntOrNull(), 42);
      });
      test('3. Double truncates to int', () {
        const num n = 3.14;
        expect(n.toIntOrNull(), 3);
      });
      test('4. Zero returns 0', () {
        const num n = 0;
        expect(n.toIntOrNull(), 0);
      });
      test('5. Negative integer', () {
        const num n = -5;
        expect(n.toIntOrNull(), -5);
      });
      test('6. Negative double truncates', () {
        const num n = -3.14;
        expect(n.toIntOrNull(), -3);
      });
      test('7. Large integer', () {
        const num n = 1000000;
        expect(n.toIntOrNull(), 1000000);
      });
      test('8. Double 0.999 truncates to 0', () {
        const num n = 0.999;
        expect(n.toIntOrNull(), 0);
      });
      test('9. Result is int type', () {
        const num n = 10.5;
        expect(n.toIntOrNull(), isA<int>());
      });
      test('10. Double 9.9 truncates to 9', () {
        const num n = 9.9;
        expect(n.toIntOrNull(), 9);
      });
    });
  });
}
