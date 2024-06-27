import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/int/int_string_extensions.dart';

void main() {
  group('ordinal', () {
    test('returns "1st" when the number is 1', () {
      expect(1.ordinal(), equals('1st'));
    });

    test('returns "2nd" when the number is 2', () {
      expect(2.ordinal(), equals('2nd'));
    });

    test('returns "3rd" when the number is 3', () {
      expect(3.ordinal(), equals('3rd'));
    });

    test('returns "4th" when the number is 4', () {
      expect(4.ordinal(), equals('4th'));
    });

    test('returns "11th" when the number is 11', () {
      expect(11.ordinal(), equals('11th'));
    });

    test('returns "12th" when the number is 12', () {
      expect(12.ordinal(), equals('12th'));
    });

    test('returns "13th" when the number is 13', () {
      expect(13.ordinal(), equals('13th'));
    });

    test('returns "21st" when the number is 21', () {
      expect(21.ordinal(), equals('21st'));
    });

    test('returns "22nd" when the number is 22', () {
      expect(22.ordinal(), equals('22nd'));
    });

    test('returns "23rd" when the number is 23', () {
      expect(23.ordinal(), equals('23rd'));
    });
  });
}
