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

  group('forceBetween', () {
    // Test 1: Value is below the range.
    test('should return the lower bound when the number is less than the range', () {
      expect(5.forceBetween(10, 20), 10);
    });

    // Test 2: Value is above the range.
    test('should return the upper bound when the number is greater than the range', () {
      expect(25.forceBetween(10, 20), 20);
    });

    // Test 3: Value is within the range.
    test('should return the number itself when it is within the range', () {
      expect(15.forceBetween(10, 20), 15);
    });

    // Test 4: Value is equal to the lower bound.
    test('should return the number itself when it is equal to the lower bound', () {
      expect(10.forceBetween(10, 20), 10);
    });

    // Test 5: Value is equal to the upper bound.
    test('should return the number itself when it is equal to the upper bound', () {
      expect(20.forceBetween(10, 20), 20);
    });

    // Test 6: Invalid range where `from` is greater than `to`.
    test('should return the number itself when the range is invalid (from > to)', () {
      expect(5.forceBetween(20, 10), 5);
    });

    // Test 7: Negative number below a negative range.
    test('should work correctly with negative numbers (below range)', () {
      expect((-15).forceBetween(-10, -5), -10);
    });

    // Test 8: Negative number within a negative range.
    test('should work correctly with negative numbers (within range)', () {
      expect((-8).forceBetween(-10, -5), -8);
    });

    // Test 9: A range that includes zero.
    test('should work correctly when the range crosses zero', () {
      expect(5.forceBetween(-10, 10), 5);
      expect((-20).forceBetween(-10, 10), -10);
    });

    // Test 10: The value is zero and within the range.
    test('should return zero when it is within the range', () {
      expect(0.forceBetween(-5, 5), 0);
    });
  });

  test('forceBetween', () {
    expect(10.forceBetween(0, 10), equals(10));
    expect(10.forceBetween(0, 20), equals(10));

    expect(10.forceBetween(5, 10), equals(10));
    expect(10.forceBetween(5, 15), equals(10));
    expect(10.forceBetween(5, 20), equals(10));

    expect(10.forceBetween(10, 10), equals(10));
    expect(10.forceBetween(10, 15), equals(10));
  });

  test('forceBetween - invalid', () {
    expect(10.forceBetween(0, 0), equals(0));

    // from > to, so it should return the original value
    expect(10.forceBetween(10, -10), equals(10));

    // from > to, so it should return the original value
    expect(10.forceBetween(10, 0), equals(10));

    // from > to, so it should return the original value
    expect(10.forceBetween(10, 5), equals(10));

    // 10 is less than from, so it should return from
    expect(10.forceBetween(15, 20), equals(15));

    // from > to, so it should return the original value
    expect(10.forceBetween(15, 5), equals(10));

    // from > to, so it should return the original value
    expect(10.forceBetween(20, 0), equals(10));

    // 10 is less than from, so it should return from
    expect(10.forceBetween(20, 15), equals(10));

    // from > to, so it should return the original value
    expect(10.forceBetween(20, 5), equals(10));
  });

  test('forceBetween - negative', () {
    expect(10.forceBetween(-10, -5), equals(-5));
    expect(10.forceBetween(-10, 10), equals(10));
    expect(10.forceBetween(-10, 20), equals(10));
  });
  test('forceBetween - negative invalid', () {
    expect(10.forceBetween(-5, -10), equals(10));
  });
}
