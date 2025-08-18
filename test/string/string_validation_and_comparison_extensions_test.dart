import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_validation_and_comparison_extensions.dart';

// cspell: disable
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

  group('isLatin', () {
    test('1. All lowercase latin', () => expect('hello'.isLatin(), isTrue));
    test('2. All uppercase latin', () => expect('WORLD'.isLatin(), isTrue));
    test('3. Mixed case latin', () => expect('HelloWorld'.isLatin(), isTrue));
    test('4. With numbers', () => expect('hello123'.isLatin(), isFalse));
    test('5. With spaces', () => expect('hello world'.isLatin(), isFalse));
    test('6. With punctuation', () => expect('hello!'.isLatin(), isFalse));
    test('7. Non-latin characters (Cyrillic)', () => expect('привет'.isLatin(), isFalse));
    test('8. Non-latin characters (Chinese)', () => expect('你好'.isLatin(), isFalse));
    test('9. Empty string', () => expect(''.isLatin(), isFalse));
    test('10. Accented latin characters', () => expect('héllo'.isLatin(), isFalse));
  });

  group('isBracketWrapped', () {
    test('1. Parentheses', () => expect('(hello)'.isBracketWrapped(), isTrue));
    test('2. Square brackets', () => expect('[hello]'.isBracketWrapped(), isTrue));
    test('3. Curly braces', () => expect('{hello}'.isBracketWrapped(), isTrue));
    test('4. Angle brackets', () => expect('<hello>'.isBracketWrapped(), isTrue));
    test('5. Mismatched brackets', () => expect('(hello]'.isBracketWrapped(), isFalse));
    test('6. No brackets', () => expect('hello'.isBracketWrapped(), isFalse));
    test('7. Only opening bracket', () => expect('(hello'.isBracketWrapped(), isFalse));
    test('8. Only closing bracket', () => expect('hello)'.isBracketWrapped(), isFalse));
    test('9. Empty string', () => expect(''.isBracketWrapped(), isFalse));
    test('10. Empty brackets', () => expect('()'.isBracketWrapped(), isTrue));
  });

  group('isEquals', () {
    test('1. Identical strings, default params', () => expect('hello'.isEquals('hello'), isTrue));
    test(
      '2. Different case, ignoreCase: true (default)',
      () => expect('hello'.isEquals('Hello'), isTrue),
    );
    test(
      '3. Different case, ignoreCase: false',
      () => expect('hello'.isEquals('Hello', ignoreCase: false), isFalse),
    );
    test(
      '4. Different apostrophes, normalizeApostrophe: true (default)',
      () => expect("it's".isEquals('it’s'), isTrue),
    );
    test(
      '5. Different apostrophes, normalizeApostrophe: false',
      () => expect("it's".isEquals('it’s', normalizeApostrophe: false), isFalse),
    );
    test('6. Completely different strings', () => expect('hello'.isEquals('world'), isFalse));
    test('7. One string is null', () => expect('hello'.isEquals(null), isFalse));
    test('8. Both strings are empty', () => expect(''.isEquals(''), isTrue));
    test(
      '9. Complex case with all options',
      () => expect("It's A Test".isEquals('it’s a test'), isTrue),
    );
    test(
      '10. Complex case with all options false',
      () => expect(
        "It's A Test".isEquals('it’s a test', ignoreCase: false, normalizeApostrophe: false),
        isFalse,
      ),
    );
  });

  group('containsIgnoreCase', () {
    test('1. Found in middle', () => expect('Hello World'.containsIgnoreCase('o w'), isTrue));
    test('2. Found at start', () => expect('Hello World'.containsIgnoreCase('he'), isTrue));
    test('3. Found at end', () => expect('Hello World'.containsIgnoreCase('ld'), isTrue));
    test('4. Not found', () => expect('Hello World'.containsIgnoreCase('xyz'), isFalse));
    test('5. Identical string', () => expect('Hello'.containsIgnoreCase('Hello'), isTrue));
    test('6. Case mismatch', () => expect('Hello'.containsIgnoreCase('hELLo'), isTrue));
    test('7. Empty `other` parameter', () => expect('Hello'.containsIgnoreCase(''), isFalse));
    test('8. Null `other` parameter', () => expect('Hello'.containsIgnoreCase(null), isFalse));
    test(
      '9. Empty string does not contain anything',
      () => expect(''.containsIgnoreCase('a'), isFalse),
    );
    test(
      '10. `other` is longer than the string',
      () => expect('Hi'.containsIgnoreCase('Hello'), isFalse),
    );
  });

  group('getFirstDiffChar', () {
    test('1. Identical strings', () => expect('abc'.getFirstDiffChar('abc'), ''));
    test('2. Difference in the middle', () => expect('apple'.getFirstDiffChar('apply'), 'y'));
    test('3. Difference at the start', () => expect('banana'.getFirstDiffChar('canana'), 'c'));
    test('4. Difference at the end', () => expect('world'.getFirstDiffChar('worle'), 'e'));
    test('5. `other` is a prefix', () => expect('testing'.getFirstDiffChar('test'), 'i'));
    test('6. `this` is a prefix', () => expect('test'.getFirstDiffChar('testing'), 'i'));
    test('7. One is empty', () => expect(''.getFirstDiffChar('a'), 'a'));
    test('8. Both are empty', () => expect(''.getFirstDiffChar(''), ''));
    test('9. Difference is a space', () => expect('a b'.getFirstDiffChar('a-b'), '-'));
    test('10. With Unicode characters', () => expect('你好世界'.getFirstDiffChar('你好世界！'), '！'));
  });
}
