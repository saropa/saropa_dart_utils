import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_number_extensions.dart';

void main() {
  group('isNumeric', () {
    test('1. Integer string', () => expect('123'.isNumeric(), isTrue));
    test('2. Double string', () => expect('123.45'.isNumeric(), isTrue));
    test('3. Negative number string', () => expect('-50'.isNumeric(), isTrue));
    test('4. String with letters', () => expect('123a'.isNumeric(), isFalse));
    test('5. Purely alphabetical string', () => expect('abc'.isNumeric(), isFalse));
    test('6. Empty string', () => expect(''.isNumeric(), isFalse));
    test('7. Whitespace string', () => expect('   '.isNumeric(), isFalse));
    test('8. String with symbols', () => expect('1,000'.isNumeric(), isFalse));
    test('9. Scientific notation', () => expect('1.2e3'.isNumeric(), isTrue));
    test('10. Hexadecimal string', () => expect('0xFF'.isNumeric(), isFalse));
  });

  group('toDoubleNullable', () {
    test('Result should be a double', () {
      // valid data
      expect('0.5'.toDoubleNullable(), 0.5);
      expect('0'.toDoubleNullable(), 0);
      expect('50'.toDoubleNullable(), 50);
      expect('-0.5'.toDoubleNullable(), -0.5);
    });

    test('Test invalid input', () {
      // empty data
      expect(''.toDoubleNullable(), null);
      // expect(null?.toDoubleNullable(), null);

      // invalid data
      expect('abc'.toDoubleNullable(), null);
      expect('#'.toDoubleNullable(), null);
    });
  });

  group('StringNumberExtensions - getTrailingInt', () {
    // Test 1: Standard case with a number at the end.
    test('should return the trailing integer from a standard string', () {
      expect('ItemID_123'.getTrailingInt(), 123);
    });

    // Test 2: A string with no numbers at all.
    test('should return null if the string contains no numbers', () {
      expect('NoNumberHere'.getTrailingInt(), isNull);
    });

    // Test 3: A string where the number is not at the end.
    test('should return null if the number is not at the end', () {
      expect('User_5_Profile'.getTrailingInt(), isNull);
    });

    // Test 4: An empty string input.
    test('should return null for an empty string', () {
      expect(''.getTrailingInt(), isNull);
    });

    // Test 5: A string that consists only of a number.
    test('should return the number if the entire string is a number', () {
      expect('98765'.getTrailingInt(), 98765);
    });

    // Test 6: A string ending with a number but followed by a space.
    test('should return null if there is a trailing space after the number', () {
      expect('Version 1 '.getTrailingInt(), isNull);
    });

    // Test 7: A string ending in zero.
    test('should correctly parse a number with leading zeros', () {
      expect('Agent007'.getTrailingInt(), 7);
    });

    // Test 8: A string that contains numbers but ends with a letter.
    test('should return null if the string ends with a non-digit character', () {
      expect('Product_v2a'.getTrailingInt(), isNull);
    });

    // Test 9: A string with a trailing number that is too large for a 64-bit int.
    test('should return null if the trailing number is out of range for an int', () {
      // This number is larger than the maximum value for a 64-bit integer.
      // int.tryParse() will correctly return null for it.
      expect('ID_98765432109876543210'.getTrailingInt(), isNull);
    });

    // Test 10: A string with the maximum valid 64-bit integer.
    test('should correctly parse the maximum 64-bit integer value', () {
      const int maxInt = 9223372036854775807;
      expect('Value_$maxInt'.getTrailingInt(), maxInt);
    });
  });

  group('IntStringExtensions - toIntNullable', () {
    // Test 1: A standard positive integer string.
    test('should return an integer for a valid positive number string', () {
      expect('123'.toIntNullable(), 123);
    });

    // Test 2: A standard negative integer string.
    test('should return an integer for a valid negative number string', () {
      expect('-45'.toIntNullable(), -45);
    });

    // Test 3: The string "0".
    test('should return 0 for the string "0"', () {
      expect('0'.toIntNullable(), 0);
    });

    // Test 4: An empty string.
    test('should return null for an empty string', () {
      expect(''.toIntNullable(), isNull);
    });

    // Test 5: A string containing non-numeric characters.
    test('should return null for a string with letters', () {
      expect('abc'.toIntNullable(), isNull);
      expect('1a2b'.toIntNullable(), isNull);
    });

    // Test 6: A string with leading and trailing whitespace.
    test('should correctly parse a number with surrounding whitespace', () {
      expect('  50  '.toIntNullable(), 50);
    });

    // Test 7: A string representing a floating-point number.
    test('should return null for a decimal number string', () {
      expect('12.34'.toIntNullable(), isNull);
    });

    // Test 8: A string that is just whitespace.
    test('should return null for a string containing only whitespace', () {
      expect('   '.toIntNullable(), isNull);
    });

    // Test 9: A string with a leading plus sign.
    test('should correctly parse a number with a leading plus sign', () {
      expect('+77'.toIntNullable(), 77);
    });

    // Test 10: A number string that is too large to fit in a standard int.
    test('should return null for an integer string that is out of range', () {
      expect('98765432109876543210'.toIntNullable(), isNull);
    });
  });
}
