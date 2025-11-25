import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/hex/hex_utils.dart';

void main() {
  group('HexExtensions', () {
    group('hexToInt', () {
      test('Valid lowercase hex string', () {
        expect('ff'.hexToInt(), 255);
      });

      test('Valid uppercase hex string', () {
        expect('FF'.hexToInt(), 255);
      });

      test('Valid mixed case hex string', () {
        expect('aBcDeF'.hexToInt(), 11259375);
      });

      test('Invalid hex string with non-hex characters', () {
        expect('invalid-hex'.hexToInt(), null);
      });

      test('Empty hex string', () {
        expect(''.hexToInt(), null);
      });

      test('Hex string representing zero', () {
        expect('0'.hexToInt(), 0);
      });

      test('Hex string representing a large int (within int range)', () {
        expect('7FFFFFFFFFFFFFFF'.hexToInt(), 9223372036854775807); // Max int64
      });

      test('Hex string too large to be represented as int (17 chars)', () {
        expect('80000000000000000'.hexToInt(), null);
      });

      test('Hex string too large to be represented as int (16 chars, exceeds max int)', () {
        expect('FFFFFFFFFFFFFFFF'.hexToInt(), null);
      });

      test('Hex string with leading zeros', () {
        expect('00FF'.hexToInt(), 255);
      });

      // Fix 6: Case-insensitive overflow check tests (algorithm fix)
      test('lowercase max int64 hex is valid (7fffffffffffffff)', () {
        expect('7fffffffffffffff'.hexToInt(), 9223372036854775807);
      });

      test('mixed case max int64 hex is valid', () {
        expect('7FfFfFfFfFfFfFfF'.hexToInt(), 9223372036854775807);
      });

      test('lowercase overflow hex returns null (8000000000000000)', () {
        expect('8000000000000000'.hexToInt(), isNull);
      });

      test('uppercase overflow hex returns null', () {
        expect('8000000000000000'.hexToInt(), isNull);
      });

      test('mixed case hex aAbBcCdDeEfF is valid', () {
        expect('aAbBcCdDeEfF'.hexToInt(), 187723572702975);
      });

      test('invalid hex characters (gg) returns null', () {
        expect('gg'.hexToInt(), isNull);
      });
    });
  });

  group('HexIntExtensions', () {
    group('intToHex', () {
      test('Positive integer to hex', () {
        expect(255.intToHex(), 'ff');
      });

      test('Zero integer to hex', () {
        expect(0.intToHex(), '0');
      });

      test('Large positive integer to hex', () {
        expect(9223372036854775807.intToHex(), '7fffffffffffffff'); // Max int64
      });

      test('Negative integer to hex', () {
        expect((-255).intToHex(), '-ff'); // Dart's toRadixString includes sign for negative numbers
      });

      test('Small positive integer to hex', () {
        expect(10.intToHex(), 'a');
      });

      test('Integer one to hex', () {
        expect(1.intToHex(), '1');
      });

      test('Another positive integer to hex', () {
        expect(4096.intToHex(), '1000');
      });

      test('Maximum 32-bit integer', () {
        expect(4294967295.intToHex(), 'ffffffff');
      });

      test('Minimum 32-bit integer', () {
        expect((-2147483648).intToHex(), '-80000000');
      });

      test('Integer close to max int64', () {
        // The current test is valid and verifies the intended functionality within the Dart ecosystem.
        // ignore: avoid_js_rounded_ints
        expect(9223372036854775000.intToHex(), '7ffffffffffffcd8');
      });
    });
  });
}
