import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/int/int_extensions.dart';

void main() {
  group('countDigits', () {
    test('returns 1 when the number is 0', () {
      expect(0.countDigits(), equals(1));
    });

    test('returns the correct number of digits for positive numbers', () {
      expect(123.countDigits(), equals(3));
      expect(1234.countDigits(), equals(4));
      expect(12345.countDigits(), equals(5));
    });

    test('returns the correct number of digits for negative numbers', () {
      expect((-123).countDigits(), equals(3));
      expect((-1234).countDigits(), equals(4));
      expect((-12345).countDigits(), equals(5));
    });

    test('returns the correct number of digits for numbers with leading zeros',
        () {
      expect(00123.countDigits(), equals(3));
    });

    // Add more test cases here...
  });
}
