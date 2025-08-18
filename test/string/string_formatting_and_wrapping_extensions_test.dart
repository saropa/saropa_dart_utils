import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_formatting_and_wrapping_extensions.dart';

// cspell: disable
void main() {
  group('wrap / wrapWith', () {
    test('1. wrap with before and after', () => expect('a'.wrap(before: '<', after: '>'), '<a>'));
    test('2. wrap with only before', () => expect('a'.wrap(before: '<'), '<a'));
    test('3. wrap with only after', () => expect('a'.wrap(after: '>'), 'a>'));
    test('4. wrap with nulls', () => expect('a'.wrap(), 'a'));
    test('5. wrap empty string', () => expect(''.wrap(before: '<', after: '>'), '<>'));
    test(
      '6. wrapWith returns null for empty string',
      () => expect(''.wrapWith(before: '<', after: '>'), null),
    );
    test('7. wrapWith basic', () => expect('a'.wrapWith(before: '<', after: '>'), '<a>'));
    test('8. wrapWith with only before', () => expect('a'.wrapWith(before: '<'), '<a'));
    test('9. wrapWith with only after', () => expect('a'.wrapWith(after: '>'), 'a>'));
    test('10. wrapWith with nulls', () => expect('a'.wrapWith(), 'a'));
  });

  group('wrapQuotes / encloseInParentheses', () {
    test('1. wrapSingleQuotes', () => expect('a'.wrapSingleQuotes(), "'a'"));
    test('2. wrapDoubleQuotes', () => expect('a'.wrapDoubleQuotes(), '"a"'));
    test('3. encloseInParentheses', () => expect('a'.encloseInParentheses(), '(a)'));
    test(
      '4. encloseInParentheses on empty with wrapEmpty: true',
      () => expect(''.encloseInParentheses(wrapEmpty: true), '()'),
    );
    test(
      '5. encloseInParentheses on empty with wrapEmpty: false (default)',
      () => expect(''.encloseInParentheses(), null),
    );
    test('6. wrapSingleQuotes on empty', () => expect(''.wrapSingleQuotes(), "''"));
    test('7. wrapDoubleQuotes on empty', () => expect(''.wrapDoubleQuotes(), '""'));
    test(
      '8. wrapSingleQuotes with existing quotes',
      () => expect("'a'".wrapSingleQuotes(), "''a''"),
    );
    test(
      '9. encloseInParentheses with existing parens',
      () => expect('(a)'.encloseInParentheses(), '((a))'),
    );
    test(
      '10. wrapDoubleQuotes with content',
      () => expect('hello world'.wrapDoubleQuotes(), '"hello world"'),
    );
  });

  group('insertNewLineBeforeBrackets', () {
    test('1. Single bracket', () => expect('a(b)c'.insertNewLineBeforeBrackets(), 'a\n(b)c'));
    test(
      '2. Multiple brackets',
      () => expect('a(b)c(d)'.insertNewLineBeforeBrackets(), 'a\n(b)c\n(d)'),
    );
    test('3. No brackets', () => expect('abc'.insertNewLineBeforeBrackets(), 'abc'));
    test('4. Bracket at start', () => expect('(abc)'.insertNewLineBeforeBrackets(), '\n(abc)'));
    test('5. Bracket at end', () => expect('abc('.insertNewLineBeforeBrackets(), 'abc\n('));
    test('6. Empty string', () => expect(''.insertNewLineBeforeBrackets(), ''));
    test('7. Only a bracket', () => expect('('.insertNewLineBeforeBrackets(), '\n('));
    test(
      '8. Nested brackets',
      () => expect('a(b(c))'.insertNewLineBeforeBrackets(), 'a\n(b\n(c))'),
    );
    test('9. String with numbers', () => expect('1(2)3'.insertNewLineBeforeBrackets(), '1\n(2)3'));
    test(
      '10. String with spaces',
      () => expect('a b (c)'.insertNewLineBeforeBrackets(), 'a b \n(c)'),
    );
  });

  group('truncateWithEllipsis', () {
    test(
      '1. String is shorter than length',
      () => expect('hello'.truncateWithEllipsis(10), 'hello'),
    );
    test(
      '2. String is longer than length',
      () => expect('hello world'.truncateWithEllipsis(5), 'hello…'),
    );
    test('3. String is equal to length', () => expect('hello'.truncateWithEllipsis(5), 'hello'));
    test('4. Length is 0', () => expect('hello'.truncateWithEllipsis(0), 'hello'));
    test('5. Length is negative', () => expect('hello'.truncateWithEllipsis(-1), 'hello'));
    test('6. Empty string', () => expect(''.truncateWithEllipsis(5), ''));
    test('7. Truncate to 1 char', () => expect('abc'.truncateWithEllipsis(1), 'a…'));
    test(
      '8. Resulting length is length + 1',
      () => expect('hello world'.truncateWithEllipsis(5).length, 6),
    );
    test('9. With Unicode', () => expect('你好世界'.truncateWithEllipsis(2), '你好…'));
    test('10. Truncate exactly at end', () => expect('abcdef'.truncateWithEllipsis(5), 'abcde…'));
  });
}
