import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/int/int_nullable_extensions.dart';

void main() {
  group('IntNullableExtensions - compareToIntNullable', () {
    // Test 1: Both values are null.
    test('should return 0 when both numbers are null', () {
      int? a;
      int? b;
      expect(a.compareToIntNullable(b), 0);
    });

    // Test 2: First value is null, second is not (null is smaller).
    test('should return -1 when the first number is null and the second is not', () {
      int? a;
      expect(a.compareToIntNullable(5), -1);
    });

    // Test 3: First value is not null, second is (null is smaller).
    test('should return 1 when the first number is not null and the second is', () {
      expect(5.compareToIntNullable(null), 1);
    });

    // Test 4: Both values are identical.
    test('should return 0 when both numbers are equal', () {
      expect(10.compareToIntNullable(10), 0);
    });

    // Test 5: First value is smaller than the second.
    test('should return -1 when the first number is smaller than the second', () {
      expect(5.compareToIntNullable(10), -1);
    });

    // Test 6: First value is larger than the second.
    test('should return 1 when the first number is larger than the second', () {
      expect(10.compareToIntNullable(5), 1);
    });

    // Test 7: Both values are negative, first is smaller.
    test('should return -1 for negative numbers where the first is smaller', () {
      expect((-10).compareToIntNullable(-5), -1);
    });

    // Test 8: Both values are negative, first is larger.
    test('should return 1 for negative numbers where the first is larger', () {
      expect((-5).compareToIntNullable(-10), 1);
    });

    // Test 9: First value is zero, second is positive.
    test('should return -1 when comparing 0 to a positive number', () {
      expect(0.compareToIntNullable(1), -1);
    });

    // Test 10: First value is negative, second is positive.
    test('should return -1 when comparing a negative number to a positive one', () {
      expect((-1).compareToIntNullable(1), -1);
    });
  });
}
