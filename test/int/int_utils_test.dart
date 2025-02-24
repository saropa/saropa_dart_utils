import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/int/int_extensions.dart';

void main() {
  test('countDigits', () {
    expect(0.countDigits(), equals(1));
    expect(1.countDigits(), equals(1));
    expect(9.countDigits(), equals(1));
    expect(10.countDigits(), equals(2));
    expect(11.countDigits(), equals(2));
    expect(99.countDigits(), equals(2));
    expect(100.countDigits(), equals(3));
    expect(101.countDigits(), equals(3));
    expect(999.countDigits(), equals(3));
    expect(1000.countDigits(), equals(4));
    expect(1001.countDigits(), equals(4));
    expect(9999.countDigits(), equals(4));
    expect(10000.countDigits(), equals(5));
    expect(10001.countDigits(), equals(5));
    expect(99999.countDigits(), equals(5));
    expect(100000.countDigits(), equals(6));
    expect(100001.countDigits(), equals(6));
    expect(999999.countDigits(), equals(6));
    expect(1000000.countDigits(), equals(7));
    expect(1000001.countDigits(), equals(7));
    expect(9999999.countDigits(), equals(7));
    expect(10000000.countDigits(), equals(8));
    expect(10000001.countDigits(), equals(8));
    expect(99999999.countDigits(), equals(8));
    expect(100000000.countDigits(), equals(9));
  });

  test('countDigits - Negative', () {
    expect((-0).countDigits(), equals(1));
    expect((-1).countDigits(), equals(1));
    expect((-9).countDigits(), equals(1));
    expect((-10).countDigits(), equals(2));
    expect((-11).countDigits(), equals(2));
    expect((-99).countDigits(), equals(2));
    expect((-100).countDigits(), equals(3));
    expect((-101).countDigits(), equals(3));
    expect((-999).countDigits(), equals(3));
    expect((-1000).countDigits(), equals(4));
    expect((-1001).countDigits(), equals(4));
    expect((-9999).countDigits(), equals(4));
    expect((-10000).countDigits(), equals(5));
    expect((-10001).countDigits(), equals(5));
    expect((-99999).countDigits(), equals(5));
    expect((-100000).countDigits(), equals(6));
    expect((-100001).countDigits(), equals(6));
    expect((-999999).countDigits(), equals(6));
    expect((-1000000).countDigits(), equals(7));
    expect((-1000001).countDigits(), equals(7));
    expect((-9999999).countDigits(), equals(7));
    expect((-10000000).countDigits(), equals(8));
    expect((-10000001).countDigits(), equals(8));
    expect((-99999999).countDigits(), equals(8));
    expect((-100000000).countDigits(), equals(9));
  });

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

    test('returns the correct number of digits for numbers with leading zeros', () {
      expect(00123.countDigits(), equals(3));
    });

    // Add more test cases here...
  });
}
