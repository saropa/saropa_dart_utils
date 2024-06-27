import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_utils.dart';

void main() {
  group('getNthLatinLetterUpper', () {
    test('returns null when n is out of range', () {
      expect(StringUtils.getNthLatinLetterUpper(0), isNull);
      expect(StringUtils.getNthLatinLetterUpper(27), isNull);
    });

    test('returns "A" when n is 1', () {
      expect(StringUtils.getNthLatinLetterUpper(1), equals('A'));
    });

    test('returns "Z" when n is 26', () {
      expect(StringUtils.getNthLatinLetterUpper(26), equals('Z'));
    });
  });

  group('getNthLatinLetterLower', () {
    test('returns null when n is out of range', () {
      expect(StringUtils.getNthLatinLetterLower(0), isNull);
      expect(StringUtils.getNthLatinLetterLower(27), isNull);
    });

    test('returns "a" when n is 1', () {
      expect(StringUtils.getNthLatinLetterLower(1), equals('a'));
    });

    test('returns "z" when n is 26', () {
      expect(StringUtils.getNthLatinLetterLower(26), equals('z'));
    });
  });
}
