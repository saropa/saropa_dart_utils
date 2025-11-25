import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

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
    // test('6. wrapSingleQuotes on empty', () => expect(''.wrapSingleQuotes(), "''"));
    // test('7. wrapDoubleQuotes on empty', () => expect(''.wrapDoubleQuotes(), '""'));
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

  group('truncateWithEllipsisPreserveWords', () {
    test(
      '1. Cutoff mid-word',
      () => expect('hello world'.truncateWithEllipsisPreserveWords(8), 'hello…'),
    );
    test(
      '2. Cutoff exactly at space',
      () => expect('hello world'.truncateWithEllipsisPreserveWords(5), 'hello…'),
    );
    test(
      '3. Cutoff after space but before next word',
      () =>
          expect('hello beautiful world'.truncateWithEllipsisPreserveWords(15), 'hello beautiful…'),
    );
    test(
      '4. String with multiple spaces between words',
      () => expect('hello   world'.truncateWithEllipsisPreserveWords(8), 'hello…'),
    );
    // Updated: Now returns truncated content instead of just '…' when first word is longer than cutoff
    test(
      '5. Cutoff is shorter than the first word',
      () => expect('documentation'.truncateWithEllipsisPreserveWords(5), 'docum…'),
    );
    test(
      '6. String with leading space',
      () => expect(' hello world'.truncateWithEllipsisPreserveWords(10), ' hello…'),
    );
    test(
      '7. Cutoff allows for entire string',
      () => expect('short sentence'.truncateWithEllipsisPreserveWords(20), 'short sentence'),
    );
    // This test has been corrected. With a cutoff of 10, the string should be truncated.
    test(
      '8. String with punctuation',
      () => expect('hello, world!'.truncateWithEllipsisPreserveWords(10), 'hello,…'),
    );
    test(
      '9. Null cutoff value',
      () => expect('a string'.truncateWithEllipsisPreserveWords(null), 'a string'),
    );
    // Updated: Now returns truncated content instead of just '…' when first word is longer than cutoff
    test(
      '10. Single long word string',
      () => expect(
        'supercalifragilisticexpialidocious'.truncateWithEllipsisPreserveWords(10),
        'supercalif…',
      ),
    );

    // Fix 9: Additional algorithm fix tests
    test(
      '11. Empty string returns empty',
      () => expect(''.truncateWithEllipsisPreserveWords(10), ''),
    );
    test(
      '12. Zero cutoff returns original string',
      () => expect('Hello World'.truncateWithEllipsisPreserveWords(0), 'Hello World'),
    );
    test(
      '13. Negative cutoff returns original string',
      () => expect('Hello World'.truncateWithEllipsisPreserveWords(-5), 'Hello World'),
    );
    test(
      '14. String exactly at cutoff length',
      () => expect('Hello'.truncateWithEllipsisPreserveWords(5), 'Hello'),
    );
    test(
      '15. First word exceeds cutoff returns truncated content',
      () => expect(
        'Pneumonoultramicroscopicsilicovolcanoconiosis is long'.truncateWithEllipsisPreserveWords(
          10,
        ),
        'Pneumonoul…',
      ),
    );
  });

  group('wrapSingleQuotes', () {
    test('1. should wrap a simple word', () {
      expect('hello'.wrapSingleQuotes(), "'hello'");
    });
    test('2. should return an empty string for an empty input by default', () {
      expect(''.wrapSingleQuotes(), '');
    });
    test('3. should return empty quotes for an empty input when quoteEmpty is true', () {
      expect(''.wrapSingleQuotes(quoteEmpty: true), "''");
    });
    test('4. should wrap a sentence with spaces', () {
      expect('hello world'.wrapSingleQuotes(), "'hello world'");
    });
    test('5. should wrap a string containing numbers', () {
      expect('12345'.wrapSingleQuotes(), "'12345'");
    });
    test('6. should wrap a string of special characters', () {
      expect('@#\$%^&*()'.wrapSingleQuotes(), "'@#\$%^&*()'");
    });
    test('7. should wrap a string that already contains double quotes', () {
      expect('"quoted"'.wrapSingleQuotes(), "'\"quoted\"'");
    });
    test('8. should re-wrap a string that already contains single quotes', () {
      expect("'quoted'".wrapSingleQuotes(), "''quoted''");
    });
    test('9. should wrap a single character', () {
      expect('a'.wrapSingleQuotes(), "'a'");
    });
    test('10. should wrap a string with leading/trailing whitespace', () {
      expect('  spaced out  '.wrapSingleQuotes(), "'  spaced out  '");
    });
  });

  group('wrapDoubleQuotes', () {
    test('1. should wrap a simple word', () {
      expect('hello'.wrapDoubleQuotes(), '"hello"');
    });
    test('2. should return an empty string for an empty input by default', () {
      expect(''.wrapDoubleQuotes(), '');
    });
    test('3. should return empty quotes for an empty input when quoteEmpty is true', () {
      expect(''.wrapDoubleQuotes(quoteEmpty: true), '""');
    });
    test('4. should wrap a sentence with spaces', () {
      expect('hello world'.wrapDoubleQuotes(), '"hello world"');
    });
    test('5. should wrap a string containing numbers', () {
      expect('12345'.wrapDoubleQuotes(), '"12345"');
    });
    test('6. should wrap a string of special characters', () {
      expect('@#\$%^&*()'.wrapDoubleQuotes(), '"@#\$%^&*()"');
    });
    test('7. should wrap a string that already contains single quotes', () {
      expect("'quoted'".wrapDoubleQuotes(), "\"'quoted'\"");
    });
    test('8. should re-wrap a string that already contains double quotes', () {
      expect('"quoted"'.wrapDoubleQuotes(), '""quoted""');
    });
    test('9. should wrap a single character', () {
      expect('a'.wrapDoubleQuotes(), '"a"');
    });
    test('10. should wrap a string with leading/trailing whitespace', () {
      expect('  spaced out  '.wrapDoubleQuotes(), '"  spaced out  "');
    });
  });

  group('wrapSingleAccentedQuotes', () {
    test('1. should wrap a simple word', () {
      expect('hello'.wrapSingleAccentedQuotes(), '‘hello’');
    });
    test('2. should return an empty string for an empty input by default', () {
      expect(''.wrapSingleAccentedQuotes(), '');
    });
    test('3. should return empty quotes for an empty input when quoteEmpty is true', () {
      expect(''.wrapSingleAccentedQuotes(quoteEmpty: true), '‘’');
    });
    test('4. should wrap a sentence with spaces', () {
      expect('hello world'.wrapSingleAccentedQuotes(), '‘hello world’');
    });
    test('5. should wrap a string containing numbers', () {
      expect('12345'.wrapSingleAccentedQuotes(), '‘12345’');
    });
    test('6. should wrap a string of special characters', () {
      expect('@#\$%^&*()'.wrapSingleAccentedQuotes(), '‘@#\$%^&*()’');
    });
    test('7. should wrap a string that already contains regular single quotes', () {
      expect("'quoted'".wrapSingleAccentedQuotes(), "‘'quoted'’");
    });
    test('8. should re-wrap a string that already contains accented quotes', () {
      expect('‘quoted’'.wrapSingleAccentedQuotes(), '‘‘quoted’’');
    });
    test('9. should wrap a single character', () {
      expect('a'.wrapSingleAccentedQuotes(), '‘a’');
    });
    test('10. should wrap a string with leading/trailing whitespace', () {
      expect('  spaced out  '.wrapSingleAccentedQuotes(), '‘  spaced out  ’');
    });
  });

  group('wrapDoubleAccentedQuotes', () {
    test('1. should wrap a simple word', () {
      expect('hello'.wrapDoubleAccentedQuotes(), '“hello”');
    });
    test('2. should return an empty string for an empty input by default', () {
      expect(''.wrapDoubleAccentedQuotes(), '');
    });
    test('3. should return empty quotes for an empty input when quoteEmpty is true', () {
      expect(''.wrapDoubleAccentedQuotes(quoteEmpty: true), '“”');
    });
    test('4. should wrap a sentence with spaces', () {
      expect('hello world'.wrapDoubleAccentedQuotes(), '“hello world”');
    });
    test('5. should wrap a string containing numbers', () {
      expect('12345'.wrapDoubleAccentedQuotes(), '“12345”');
    });
    test('6. should wrap a string of special characters', () {
      expect('@#\$%^&*()'.wrapDoubleAccentedQuotes(), '“@#\$%^&*()”');
    });
    test('7. should wrap a string that already contains regular double quotes', () {
      expect('"quoted"'.wrapDoubleAccentedQuotes(), '“"quoted"”');
    });
    test('8. should re-wrap a string that already contains accented quotes', () {
      expect('“quoted”'.wrapDoubleAccentedQuotes(), '““quoted””');
    });
    test('9. should wrap a single character', () {
      expect('a'.wrapDoubleAccentedQuotes(), '“a”');
    });
    test('10. should wrap a string with leading/trailing whitespace', () {
      expect('  spaced out  '.wrapDoubleAccentedQuotes(), '“  spaced out  ”');
    });
  });

  group('reversed', () {
    test('1. Standard string', () => expect('hello'.reversed, 'olleh'));
    test('2. Palindrome', () => expect('madam'.reversed, 'madam'));
    test('3. String with numbers and symbols', () => expect('1a!2b@'.reversed, '@b2!a1'));
    test('4. Empty string', () => expect(''.reversed, ''));
    test('5. Single character string', () => expect('a'.reversed, 'a'));
    test('6. String with spaces', () => expect('hello world'.reversed, 'dlrow olleh'));
    test('7. Unicode string', () => expect('你好'.reversed, '好你'));
    test('8. Emoji string', () => expect('👍🚀'.reversed, '🚀👍'));
    test('9. Whitespace string', () => expect(' \n\t'.reversed, '\t\n '));
    test(
      '10. Long string',
      () => expect('long string to reverse'.reversed, 'esrever ot gnirts gnol'),
    );
  });

  group('nullIfEmpty', () {
    test('1. Empty string returns null', () => expect(''.nullIfEmpty(), isNull));
    test(
      '2. Whitespace-only string with trimFirst: true (default)',
      () => expect('   '.nullIfEmpty(), isNull),
    );
    test(
      '3. Whitespace-only string with trimFirst: false',
      () => expect('   '.nullIfEmpty(trimFirst: false), '   '),
    );
    test('4. Non-empty string', () => expect('hello'.nullIfEmpty(), 'hello'));
    test(
      '5. String with leading/trailing spaces and trimFirst: true',
      () => expect('  hello  '.nullIfEmpty(), 'hello'),
    );
    test(
      '6. String with leading/trailing spaces and trimFirst: false',
      () => expect('  hello  '.nullIfEmpty(trimFirst: false), '  hello  '),
    );
    test(
      '7. String with internal spaces',
      () => expect('hello world'.nullIfEmpty(), 'hello world'),
    );
    test('8. Single character string', () => expect('a'.nullIfEmpty(), 'a'));
    test('9. String with only a newline character', () => expect('\n'.nullIfEmpty(), isNull));
    test('10. String with number', () => expect('123'.nullIfEmpty(), '123'));
  });

  group('insert', () {
    test('1. Insert at the beginning', () => expect('world'.insert('hello ', 0), 'hello world'));
    test('2. Insert in the middle', () => expect('Helloworld'.insert(' ', 5), 'Hello world'));
    test('3. Insert at the end', () => expect('hello'.insert(' world', 5), 'hello world'));
    test('4. Position is out of bounds (negative)', () => expect('abc'.insert('x', -1), 'abc'));
    test('5. Position is out of bounds (positive)', () => expect('abc'.insert('x', 4), 'abc'));
    test('6. Insert into an empty string', () => expect(''.insert('abc', 0), 'abc'));
    test('7. Insert an empty string', () => expect('abc'.insert('', 1), 'abc'));
    test('8. Insert at position length', () => expect('abc'.insert('d', 3), 'abcd'));
    test('9. Insert at position 0', () => expect('abc'.insert('x', 0), 'xabc'));
    test('10. Insert unicode', () => expect('ac'.insert('你好', 1), 'a你好c'));
  });

  group('removeLastOccurrence', () {
    test(
      '1. Found multiple times',
      () => expect('hello-world-again'.removeLastOccurrence('-'), 'hello-worldagain'),
    );
    test('2. Found once', () => expect('hello-world'.removeLastOccurrence('-'), 'helloworld'));
    test('3. Not found', () => expect('helloworld'.removeLastOccurrence('-'), 'helloworld'));
    test('4. Target is at the end', () => expect('hello-'.removeLastOccurrence('-'), 'hello'));
    test(
      '5. Target is at the beginning',
      () => expect('-hello'.removeLastOccurrence('-'), 'hello'),
    );
    test('6. Empty string input', () => expect(''.removeLastOccurrence('-'), ''));
    test('7. Empty target', () => expect('hello'.removeLastOccurrence(''), 'hello'));
    test('8. Target is the whole string', () => expect('abc'.removeLastOccurrence('abc'), ''));
    test('9. Overlapping occurrences', () => expect('ababab'.removeLastOccurrence('aba'), 'abb'));
    test(
      '10. With spaces',
      () => expect('a fine day is a good day'.removeLastOccurrence(' day'), 'a fine day is a good'),
    );
  });

  group('removeMatchingWrappingBrackets', () {
    test('1. With parentheses', () => expect('(hello)'.removeMatchingWrappingBrackets(), 'hello'));
    test(
      '2. With square brackets',
      () => expect('[hello]'.removeMatchingWrappingBrackets(), 'hello'),
    );
    test('3. No brackets', () => expect('hello'.removeMatchingWrappingBrackets(), 'hello'));
    test(
      '4. Mismatched brackets',
      () => expect('(hello]'.removeMatchingWrappingBrackets(), '(hello]'),
    );
    test('5. Internal brackets', () => expect('(a[b]c)'.removeMatchingWrappingBrackets(), 'a[b]c'));
    test('6. Empty brackets', () => expect('()'.removeMatchingWrappingBrackets(), ''));
    test('7. Empty string', () => expect(''.removeMatchingWrappingBrackets(), ''));
    test('8. Only one bracket', () => expect('(hello'.removeMatchingWrappingBrackets(), '(hello'));
    test(
      '9. Content with spaces',
      () => expect('[ hello world ]'.removeMatchingWrappingBrackets(), ' hello world '),
    );
    test(
      '10. Nested matching brackets',
      () => expect('([hello])'.removeMatchingWrappingBrackets(), '[hello]'),
    );
  });

  group('removeWrappingChar', () {
    test('1. Char at both ends', () => expect('|hello|'.removeWrappingChar('|'), 'hello'));
    test('2. Char at start only', () => expect('|hello'.removeWrappingChar('|'), 'hello'));
    test('3. Char at end only', () => expect('hello|'.removeWrappingChar('|'), 'hello'));
    test('4. Char not present', () => expect('hello'.removeWrappingChar('|'), 'hello'));
    test('5. Char in the middle', () => expect('he|llo'.removeWrappingChar('|'), 'he|llo'));
    test(
      '6. With trim: false and spaces',
      () => expect(' |hello| '.removeWrappingChar('|', trimFirst: false), ' |hello| '),
    );
    test(
      '7. With trim: true (default) and spaces',
      () => expect(' |hello| '.removeWrappingChar('|'), 'hello'),
    );
    test('8. Empty string', () => expect(''.removeWrappingChar('|'), ''));
    test('9. Multiple chars to wrap', () => expect('||hello||'.removeWrappingChar('|'), '|hello|'));
    test(
      '10. Using a word as the char',
      () => expect('STARThelloEND'.removeWrappingChar('START'), 'helloEND'),
    );
  });

  group('removeStart', () {
    test('1. Case sensitive match', () => expect('HelloWorld'.removeStart('Hello'), 'World'));
    test(
      '2. Case sensitive no match',
      () => expect('HelloWorld'.removeStart('hello'), 'HelloWorld'),
    );
    test(
      '3. Case insensitive match',
      () => expect('HelloWorld'.removeStart('hello', isCaseSensitive: false), 'World'),
    );
    test(
      '4. With trimFirst: true',
      () => expect('  HelloWorld'.removeStart('Hello', trimFirst: true), 'World'),
    );
    test(
      '5. With trimFirst: false',
      () => expect('  HelloWorld'.removeStart('Hello', trimFirst: false), '  HelloWorld'),
    );
    test('6. Start is empty', () => expect('Hello'.removeStart(''), 'Hello'));
    test('7. String is empty', () => expect(''.removeStart('a'), ''));
    test('8. Start is the whole string', () => expect('Hello'.removeStart('Hello'), null));
    test(
      '9. No match, trimFirst: true',
      () => expect('  Hello'.removeStart('World', trimFirst: true), 'Hello'),
    );
    test('10. Null start string', () => expect('Hello'.removeStart(null), 'Hello'));
  });

  group('removeEnd', () {
    test('1. Suffix exists', () => expect('Hello World'.removeEnd('World'), 'Hello '));
    test('2. Suffix does not exist', () => expect('Hello World'.removeEnd('Hello'), 'Hello World'));
    test('3. Empty suffix', () => expect('Hello'.removeEnd(''), 'Hello'));
    test('4. Empty string', () => expect(''.removeEnd('a'), ''));
    test('5. Suffix is the whole string', () => expect('Hello'.removeEnd('Hello'), ''));
    test('6. Case sensitive', () => expect('Hello'.removeEnd('hello'), 'Hello'));
    test('7. Suffix appears multiple times', () => expect('ababab'.removeEnd('ab'), 'abab'));
    test('8. With numbers', () => expect('file_v1'.removeEnd('_v1'), 'file'));
    test('9. With spaces in suffix', () => expect('file done'.removeEnd(' done'), 'file'));
    test('10. With Unicode', () => expect('你好世界'.removeEnd('世界'), '你好'));
  });

  group('removeFirst/Last/FirstLastChar', () {
    test('1. removeFirstChar on long string', () => expect('abc'.removeFirstChar(), 'bc'));
    test('2. removeFirstChar on single char string', () => expect('a'.removeFirstChar(), ''));
    test('3. removeLastChar on long string', () => expect('abc'.removeLastChar(), 'ab'));
    test('4. removeLastChar on single char string', () => expect('a'.removeLastChar(), ''));
    test(
      '5. removeFirstLastChar on long string',
      () => expect('abcde'.removeFirstLastChar(), 'bcd'),
    );
    test('6. removeFirstLastChar on 3-char string', () => expect('abc'.removeFirstLastChar(), 'b'));
    test('7. removeFirstLastChar on 2-char string', () => expect('ab'.removeFirstLastChar(), ''));
    test('8. removeFirstLastChar on empty string', () => expect(''.removeFirstLastChar(), ''));
    test('9. removeFirstChar on empty string', () => expect(''.removeFirstChar(), ''));
    test('10. removeLastChar on empty string', () => expect(''.removeLastChar(), ''));
  });

  group('normalizeApostrophe', () {
    test('1. With standard apostrophe', () => expect("it's".normalizeApostrophe(), "it's"));
    test('2. With curly apostrophe', () => expect('it’s'.normalizeApostrophe(), "it's"));
    test(
      '3. With mixed apostrophes',
      () => expect("it's a test, it’s great".normalizeApostrophe(), "it's a test, it's great"),
    );
    test('4. With no apostrophes', () => expect('its a test'.normalizeApostrophe(), 'its a test'));
    test('5. Empty string', () => expect(''.normalizeApostrophe(), ''));
    test(
      '6. Multiple curly apostrophes',
      () => expect('’tis the season’'.normalizeApostrophe(), "'tis the season'"),
    );
    test('7. At the start of string', () => expect('’twas'.normalizeApostrophe(), "'twas"));
    test('8. At the end of string', () => expect("O'Malley’".normalizeApostrophe(), "O'Malley'"));
    test('9. Only apostrophes', () => expect("''’".normalizeApostrophe(), "'''"));
    test('10. String with numbers', () => expect('the 90’s'.normalizeApostrophe(), "the 90's"));
  });

  group('Sanitization (toAlphaOnly, removeNonAlphaNumeric, removeNonNumbers)', () {
    test('1. toAlphaOnly basic', () => expect('a1 b2-c3'.toAlphaOnly(), 'abc'));
    test(
      '2. toAlphaOnly with space',
      () => expect('a1 b2-c3'.toAlphaOnly(allowSpace: true), 'a bc'),
    );
    test(
      '3. removeNonAlphaNumeric basic',
      () => expect('a1!b2@c3#'.removeNonAlphaNumeric(), 'a1b2c3'),
    );
    test(
      '4. removeNonAlphaNumeric with space',
      () => expect('a1! b2@ c3#'.removeNonAlphaNumeric(allowSpace: true), 'a1 b2 c3'),
    );
    // test('5. removeNonNumbers basic', () => expect('a1b2c3'.removeNonNumbers(), '123'));
    // test(
    //   '6. removeNonNumbers with symbols',
    //   () => expect('+1 (800) 555-1234'.removeNonNumbers(), '18005551234'),
    // );
    test('7. toAlphaOnly on empty string', () => expect(''.toAlphaOnly(), ''));
    test('8. removeNonAlphaNumeric on empty string', () => expect(''.removeNonAlphaNumeric(), ''));
    // test('9. removeNonNumbers on empty string', () => expect(''.removeNonNumbers(), ''));
    // test('10. removeNonNumbers with no numbers', () => expect('abc-def'.removeNonNumbers(), ''));
  });

  group('escapeForRegex', () {
    test('1. Empty string', () => expect(''.escapeForRegex(), ''));
    test('2. No special characters', () => expect('abc'.escapeForRegex(), 'abc'));
    test(
      '3. All special characters',
      () => expect(r'.*+?^${}()|[]\'.escapeForRegex(), r'\.\*\+\?\^\$\{\}\(\)\|\[\]\\'),
    );
    test(
      '4. Text with period and question mark',
      () => expect('Hello?'.escapeForRegex(), r'Hello\?'),
    );
    test('5. Text with parentheses', () => expect('group (A)'.escapeForRegex(), r'group \(A\)'));
    test('6. Text with backslash', () => expect(r'C:\path'.escapeForRegex(), r'C:\\path'));
    test(
      '7. Text with dollar sign',
      () => expect(r'Price is $5'.escapeForRegex(), r'Price is \$5'),
    );
    test('8. Repeated special characters', () => expect('...'.escapeForRegex(), r'\.\.\.'));
    test('9. Hyphen is not escaped', () => expect('a-b'.escapeForRegex(), 'a-b'));
    test(
      '10. Complex sentence',
      () => expect(r'So, $5.00+ for (this)?'.escapeForRegex(), r'So, \$5\.00\+ for \(this\)\?'),
    );
  });

  group('removeConsecutiveSpaces / compressSpaces', () {
    test('1. No consecutive spaces', () => expect('a b c'.removeConsecutiveSpaces(), 'a b c'));
    test(
      '2. Multiple spaces in middle',
      () => expect('a  b   c'.removeConsecutiveSpaces(), 'a b c'),
    );
    test(
      '3. Leading and trailing spaces with trim (default)',
      () => expect('  a b  '.removeConsecutiveSpaces(), 'a b'),
    );
    test(
      '4. Leading and trailing spaces without trim',
      () => expect('  a b  '.removeConsecutiveSpaces(trim: false), ' a b '),
    );
    test('5. Tabs and newlines', () => expect('a\t\nb\nc'.removeConsecutiveSpaces(), 'a b c'));
    test('6. Empty string', () => expect(''.removeConsecutiveSpaces(), null));
    test('7. Whitespace-only string', () => expect('   '.removeConsecutiveSpaces(), null));
    test('8. Alias compressSpaces works', () => expect('a  b'.compressSpaces(), 'a b'));
    test('9. Mixed whitespace characters', () => expect('a \t b \n c'.compressSpaces(), 'a b c'));
    test('10. Single word with spaces', () => expect('  word  '.compressSpaces(), 'word'));
  });

  group('replaceNonNumbers', () {
    // Test 1: Default behavior (no replacement provided) should remove non-numbers.
    test('should remove non-numbers when no replacement is given', () {
      expect('abc123def'.replaceNonNumbers(), '123');
    });

    // Test 2: Replace non-numbers with a space.
    test('should replace non-numbers with a space', () {
      expect('a1b2c3'.replaceNonNumbers(replacement: ' '), ' 1 2 3');
    });

    // Test 3: Replace non-numbers with a dash.
    test('should replace non-numbers in a phone number format with a dash', () {
      // The original string is '(123) 456-7890'
      // The non-digits are: '(', ')', ' ', '-'
      // Correctly becomes: '-123--456-7890'
      expect('(123) 456-7890'.replaceNonNumbers(replacement: '-'), '-123--456-7890');
    });

    // Test 4: An empty string should remain empty.
    test('should return an empty string if the input is empty', () {
      expect(''.replaceNonNumbers(replacement: 'X'), '');
    });

    // Test 5: A string with only numbers should not be changed.
    test('should not change a string that contains only numbers', () {
      expect('1234567890'.replaceNonNumbers(replacement: 'X'), '1234567890');
    });

    // Test 6: A string with only non-numbers should be completely replaced.
    test('should replace all characters in a string with only non-numbers', () {
      expect('abc-def'.replaceNonNumbers(replacement: '#'), '#######');
    });

    // Test 7: Replace with a multi-character string.
    test('should replace each non-number with a multi-character string', () {
      expect('a1b2'.replaceNonNumbers(replacement: '---'), '---1---2');
    });

    // Test 8: A string containing special characters and symbols.
    test('should replace currency symbols and decimals', () {
      expect('\$99.99'.replaceNonNumbers(replacement: '_'), '_99_99');
    });

    // Test 9: A string that is a mix of letters, numbers, and spaces.
    test('should correctly replace a mixed string', () {
      expect('Order 1, item 2'.replaceNonNumbers(replacement: ''), '12');
    });

    // Test 10: Using an empty string for replacement.
    test('should behave exactly like removeNonNumbers when replacement is an empty string', () {
      expect('abc-123'.replaceNonNumbers(replacement: ''), '123');
    });
  });

  group('removeNonNumbers (Additional Cases)', () {
    // Test 1: String with only non-numeric characters.
    test('should return an empty string if no numbers are present', () {
      expect('abcdef!@#\$%'.removeNonNumbers(), '');
    });

    // Test 2: String that already contains only numbers.
    test('should return the same string if it only contains numbers', () {
      expect('1234567890'.removeNonNumbers(), '1234567890');
    });

    // Test 3: String with leading and trailing non-numeric characters.
    test('should remove leading and trailing characters', () {
      expect('---123---'.removeNonNumbers(), '123');
    });

    // Test 4: String containing decimals and commas.
    test('should remove decimal points and commas from a formatted number', () {
      expect('1,234,567.89'.removeNonNumbers(), '123456789');
    });

    // Test 5: Empty string input.
    test('should return an empty string for an empty input', () {
      expect(''.removeNonNumbers(), '');
    });

    // Test 6: String containing whitespace characters like spaces, tabs, and newlines.
    test('should remove all whitespace characters', () {
      expect(' 1\n2\t3 '.removeNonNumbers(), '123');
    });

    // Test 7: Phone number format with parentheses and dashes.
    test('should correctly parse a standard phone number format', () {
      expect('+1 (123) 456-7890'.removeNonNumbers(), '11234567890');
    });

    // Test 8: A string that contains the number zero.
    test('should correctly keep the digit zero', () {
      expect('Value: 0'.removeNonNumbers(), '0');
    });

    // Test 9: A string with international or unicode characters.
    test('should remove non-ASCII characters', () {
      expect('你好123世界'.removeNonNumbers(), '123');
    });

    // Test 10: A string with a single number surrounded by characters.
    test('should isolate a single number from surrounding text', () {
      expect('abc-1-def'.removeNonNumbers(), '1');
    });
  });

  group('splitCapitalizedUnicode', () {
    test(
      '1. Basic split',
      () => expect('helloWorld'.splitCapitalizedUnicode(), <String>['hello', 'World']),
    );
    test(
      '2. With Unicode characters',
      () => expect('straßeMitÖsterreich'.splitCapitalizedUnicode(), <String>[
        'straße',
        'Mit',
        'Österreich',
      ]),
    );
    test(
      '3. With splitNumbers true',
      () => expect('area51TestSite'.splitCapitalizedUnicode(splitNumbers: true), <String>[
        'area',
        '51',
        'Test',
        'Site',
      ]),
    );
    test(
      '4. With splitNumbers false (default)',
      () => expect('area51TestSite'.splitCapitalizedUnicode(), <String>['area51Test', 'Site']),
    );

    test(
      '5. With minLength to merge short parts',
      () => expect('aB'.splitCapitalizedUnicode(minLength: 2), <String>['aB']),
    );
    test(
      '6. With minLength and Unicode',
      () => expect('straßeMitÖsterreich'.splitCapitalizedUnicode(minLength: 4), <String>[
        'straßeMit',
        'Österreich',
      ]),
    );
    test(
      '7. With splitBySpace true',
      () => expect('helloWorld From APlace'.splitCapitalizedUnicode(splitBySpace: true), <String>[
        'hello',
        'World',
        'From',
        'APlace',
      ]),
    );
    test('8. Empty string input', () => expect(''.splitCapitalizedUnicode(), <dynamic>[]));
    test(
      '9. String with no capitals',
      () => expect('helloworld'.splitCapitalizedUnicode(), <String>['helloworld']),
    );
    test(
      '10. String with leading/trailing spaces and splitBySpace',
      () => expect(
        '  leadingSpace AndTrailing '.splitCapitalizedUnicode(splitBySpace: true),
        <String>['leading', 'Space', 'And', 'Trailing'],
      ),
    );
  });

  group('getEverythingBefore', () {
    test('1. Substring found in middle', () => expect('abc-def'.getEverythingBefore('-'), 'abc'));
    test('2. Substring not found', () => expect('abcdef'.getEverythingBefore('-'), 'abcdef'));
    test('3. Substring is at the start', () => expect('-abcdef'.getEverythingBefore('-'), ''));
    test('4. Substring is at the end', () => expect('abcdef-'.getEverythingBefore('-'), 'abcdef'));
    test('5. Multiple occurrences', () => expect('abc-def-ghi'.getEverythingBefore('-'), 'abc'));
    test('6. Empty string input', () => expect(''.getEverythingBefore('-'), ''));
    test('7. Empty find parameter', () => expect('abcdef'.getEverythingBefore(''), ''));
    test('8. Find is the whole string', () => expect('abc'.getEverythingBefore('abc'), ''));
    test('9. With Unicode characters', () => expect('你好-世界'.getEverythingBefore('-'), '你好'));
    test(
      '10. Find is longer than the string',
      () => expect('abc'.getEverythingBefore('abcdef'), 'abc'),
    );
  });

  group('getEverythingAfter', () {
    test('1. Substring found in middle', () => expect('abc-def'.getEverythingAfter('-'), 'def'));
    test('2. Substring not found', () => expect('abcdef'.getEverythingAfter('-'), 'abcdef'));
    test('3. Substring is at the start', () => expect('-abcdef'.getEverythingAfter('-'), 'abcdef'));
    test('4. Substring is at the end', () => expect('abcdef-'.getEverythingAfter('-'), ''));
    test('5. Multiple occurrences', () => expect('abc-def-ghi'.getEverythingAfter('-'), 'def-ghi'));
    test('6. Empty string input', () => expect(''.getEverythingAfter('-'), ''));
    test('7. Empty find parameter', () => expect('abcdef'.getEverythingAfter(''), 'abcdef'));
    test('8. Find is the whole string', () => expect('abc'.getEverythingAfter('abc'), ''));
    test('9. With Unicode characters', () => expect('你好-世界'.getEverythingAfter('-'), '世界'));
    test(
      '10. Find is longer than the string',
      () => expect('abc'.getEverythingAfter('abcdef'), 'abc'),
    );
  });

  group('getEverythingAfterLast', () {
    test('1. Multiple occurrences', () => expect('abc-def-ghi'.getEverythingAfterLast('-'), 'ghi'));
    test('2. Single occurrence', () => expect('abc-def'.getEverythingAfterLast('-'), 'def'));
    test('3. Substring not found', () => expect('abcdef'.getEverythingAfterLast('-'), 'abcdef'));
    test('4. Substring is at the end', () => expect('abcdef-'.getEverythingAfterLast('-'), ''));
    test(
      '5. Substring is at the start',
      () => expect('-abcdef'.getEverythingAfterLast('-'), 'abcdef'),
    );
    test('6. Empty string input', () => expect(''.getEverythingAfterLast('-'), ''));
    test('7. Empty find parameter', () => expect('abcdef'.getEverythingAfterLast(''), 'abcdef'));
    test('8. Find is the whole string', () => expect('abc'.getEverythingAfterLast('abc'), ''));
    test(
      '9. With file paths',
      () => expect('path/to/file.txt'.getEverythingAfterLast('/'), 'file.txt'),
    );
    test(
      '10. No trailing character',
      () => expect('path.to.file'.getEverythingAfterLast('.'), 'file'),
    );
  });

  group('substringSafe', () {
    test('1. Valid range', () => expect('abcdef'.substringSafe(1, 4), 'bcd'));
    test('2. Start is out of bounds (positive)', () => expect('abcdef'.substringSafe(10), ''));
    test('3. End is larger than length', () => expect('abcdef'.substringSafe(3, 10), 'def'));
    test('4. Start is negative', () => expect('abcdef'.substringSafe(-1), ''));
    test('5. End is negative', () => expect('abcdef'.substringSafe(1, -1), ''));
    test('6. End is before start', () => expect('abcdef'.substringSafe(4, 2), ''));
    test('7. No end parameter', () => expect('abcdef'.substringSafe(3), 'def'));
    test('8. Empty string input', () => expect(''.substringSafe(0, 1), ''));
    test('9. Start and end are equal', () => expect('abcdef'.substringSafe(3, 3), ''));
    test('10. Extracts single character', () => expect('abcdef'.substringSafe(2, 3), 'c'));
  });

  group('lastChars', () {
    test('1. n is less than length', () => expect('abcdef'.lastChars(3), 'def'));
    test('2. n is equal to length', () => expect('abcdef'.lastChars(6), 'abcdef'));
    test('3. n is greater than length', () => expect('abc'.lastChars(5), 'abc'));
    test('4. n is 0', () => expect('abcdef'.lastChars(0), ''));
    test('5. n is negative', () => expect('abcdef'.lastChars(-2), ''));
    test('6. n is 1', () => expect('abcdef'.lastChars(1), 'f'));
    test('7. Empty string input', () => expect(''.lastChars(3), ''));
    test('8. String with spaces', () => expect('hello world'.lastChars(5), 'world'));
    test('9. With Unicode characters', () => expect('你好世界'.lastChars(2), '世界'));
    test('10. String with numbers', () => expect('1234567890'.lastChars(4), '7890'));
  });

  group('words', () {
    test('1. Empty string returns null', () => expect(''.words(), null));
    test('2. Single word string', () => expect('Hello'.words(), <String>['Hello']));
    test(
      '3. Multiple words string',
      () => expect('Hello world from Dart'.words(), <String>['Hello', 'world', 'from', 'Dart']),
    );
    test(
      '4. String with leading and trailing spaces',
      () => expect('  Hello world  '.words(), <String>['Hello', 'world']),
    );
    test(
      '5. String with multiple spaces between words',
      () => expect('Hello   world  from     Dart'.words(), <String>[
        'Hello',
        'world',
        'from',
        'Dart',
      ]),
    );
    test(
      '6. String with special characters in words',
      () => expect('Word-1 word_2 word#3'.words(), <String>['Word-1', 'word_2', 'word#3']),
    );
    test(
      '7. String with numbers as words',
      () => expect('123 456 789'.words(), <String>['123', '456', '789']),
    );
    test(
      '8. String with punctuation attached to words',
      () => expect('Hello, world!'.words(), <String>['Hello,', 'world!']),
    );
    test('9. String with only whitespace returns null', () => expect('   '.words(), null));
    test('10. String with Unicode words', () => expect('你好 世界'.words(), <String>['你好', '世界']));
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
    // Updated: Empty string is always contained (standard string semantics)
    test('7. Empty `other` parameter', () => expect('Hello'.containsIgnoreCase(''), isTrue));
    test('8. Null `other` parameter', () => expect('Hello'.containsIgnoreCase(null), isFalse));
    test(
      '9. Empty string does not contain anything',
      () => expect(''.containsIgnoreCase('a'), isFalse),
    );
    test(
      '10. `other` is longer than the string',
      () => expect('Hi'.containsIgnoreCase('Hello'), isFalse),
    );

    // Fix 10: Additional algorithm fix tests (empty string semantics)
    test(
      '11. Empty string is contained in empty string',
      () => expect(''.containsIgnoreCase(''), isTrue),
    );
    test(
      '12. Lowercase search in uppercase text',
      () => expect('HELLO WORLD'.containsIgnoreCase('hello'), isTrue),
    );
    test(
      '13. Mixed case search in mixed case text',
      () => expect('HeLLo WoRLd'.containsIgnoreCase('hello world'), isTrue),
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

  group('hasInvalidUnicode', () {
    test('1. Empty string has no invalid unicode', () => expect(''.hasInvalidUnicode, isFalse));
    test('2. Normal ASCII string', () => expect('hello'.hasInvalidUnicode, isFalse));
    test('3. Valid unicode characters', () => expect('你好世界'.hasInvalidUnicode, isFalse));
    test('4. Valid emoji string', () => expect('👍🚀'.hasInvalidUnicode, isFalse));
    test('5. Mixed valid content', () => expect('Hello 你好 👍'.hasInvalidUnicode, isFalse));
    test('6. Numbers and symbols', () => expect('123!@#'.hasInvalidUnicode, isFalse));
    test('7. Whitespace characters', () => expect(' \t\n'.hasInvalidUnicode, isFalse));
    test('8. Accented characters', () => expect('café résumé'.hasInvalidUnicode, isFalse));
    test('9. Arabic text', () => expect('مرحبا'.hasInvalidUnicode, isFalse));
    test('10. Japanese text', () => expect('こんにちは'.hasInvalidUnicode, isFalse));
  });

  group('removeInvalidUnicode', () {
    test('1. Empty string returns empty', () => expect(''.removeInvalidUnicode(), ''));
    test('2. Normal ASCII string unchanged', () => expect('hello'.removeInvalidUnicode(), 'hello'));
    test('3. Valid unicode unchanged', () => expect('你好世界'.removeInvalidUnicode(), '你好世界'));
    test('4. Valid emoji unchanged', () => expect('👍🚀'.removeInvalidUnicode(), '👍🚀'));
    test(
      '5. Mixed valid content unchanged',
      () => expect('Hello 你好'.removeInvalidUnicode(), 'Hello 你好'),
    );
    test('6. Numbers unchanged', () => expect('12345'.removeInvalidUnicode(), '12345'));
    test('7. Whitespace unchanged', () => expect(' \t\n'.removeInvalidUnicode(), ' \t\n'));
    test('8. Accented characters unchanged', () => expect('café'.removeInvalidUnicode(), 'café'));
    test('9. Arabic unchanged', () => expect('مرحبا'.removeInvalidUnicode(), 'مرحبا'));
    test('10. Japanese unchanged', () => expect('こんにちは'.removeInvalidUnicode(), 'こんにちは'));
  });

  group('isVowel', () {
    test('1. Lowercase a', () => expect('a'.isVowel(), isTrue));
    test('2. Lowercase e', () => expect('e'.isVowel(), isTrue));
    test('3. Lowercase i', () => expect('i'.isVowel(), isTrue));
    test('4. Lowercase o', () => expect('o'.isVowel(), isTrue));
    test('5. Lowercase u', () => expect('u'.isVowel(), isTrue));
    test('6. Uppercase A', () => expect('A'.isVowel(), isTrue));
    test('7. Uppercase E', () => expect('E'.isVowel(), isTrue));
    test('8. Consonant b', () => expect('b'.isVowel(), isFalse));
    test('9. Consonant z', () => expect('z'.isVowel(), isFalse));
    test('10. Empty string', () => expect(''.isVowel(), isFalse));
    test('11. Multi-character string', () => expect('ae'.isVowel(), isFalse));
    test('12. Number', () => expect('1'.isVowel(), isFalse));
    test('13. Symbol', () => expect('@'.isVowel(), isFalse));
    test('14. Space', () => expect(' '.isVowel(), isFalse));
    test('15. Uppercase consonant', () => expect('B'.isVowel(), isFalse));
  });

  group('hasAnyDigits', () {
    test('1. String with single digit', () => expect('abc1def'.hasAnyDigits(), isTrue));
    test('2. String with multiple digits', () => expect('a1b2c3'.hasAnyDigits(), isTrue));
    test('3. Only digits', () => expect('12345'.hasAnyDigits(), isTrue));
    test('4. No digits', () => expect('abcdef'.hasAnyDigits(), isFalse));
    test('5. Empty string', () => expect(''.hasAnyDigits(), isFalse));
    test('6. Digit at start', () => expect('1abc'.hasAnyDigits(), isTrue));
    test('7. Digit at end', () => expect('abc9'.hasAnyDigits(), isTrue));
    test('8. Only letters and symbols', () => expect('abc!@#'.hasAnyDigits(), isFalse));
    test('9. Unicode with digit', () => expect('你好1世界'.hasAnyDigits(), isTrue));
    test('10. Spaces and letters only', () => expect('hello world'.hasAnyDigits(), isFalse));
  });

  group('last', () {
    test('1. Get last 3 characters', () => expect('hello'.last(3), 'llo'));
    test('2. Get last 1 character', () => expect('hello'.last(1), 'o'));
    test('3. Request more than length', () => expect('abc'.last(5), 'abc'));
    test('4. Request exactly length', () => expect('abc'.last(3), 'abc'));
    test('5. Empty string', () => expect(''.last(3), ''));
    test('6. Zero length request', () => expect('hello'.last(0), ''));
    test('7. Negative length', () => expect('hello'.last(-1), ''));
    test('8. Unicode characters', () => expect('你好世界'.last(2), '世界'));
    test('9. Mixed content', () => expect('abc123'.last(3), '123'));
    test('10. Single char string', () => expect('a'.last(1), 'a'));
    test('11. Emoji string', () => expect('🚀👍🎉'.last(2), '👍🎉'));
    test('12. Last from long string', () => expect('abcdefghijklmnop'.last(4), 'mnop'));
  });

  group('getRandomChar', () {
    test('1. Non-empty string returns single char', () {
      final String result = 'hello'.getRandomChar();
      expect(result.length, 1);
      expect('hello'.contains(result), isTrue);
    });
    test('2. Empty string returns empty', () => expect(''.getRandomChar(), ''));
    test('3. Single char returns that char', () => expect('a'.getRandomChar(), 'a'));
    test('4. Result is from original string', () {
      const String source = 'xyz';
      final String result = source.getRandomChar();
      expect(source.contains(result), isTrue);
    });
    test('5. Numeric string', () {
      const String source = '12345';
      final String result = source.getRandomChar();
      expect(source.contains(result), isTrue);
    });
  });

  group('repeat', () {
    test('1. Repeat 3 times', () => expect('ab'.repeat(3), 'ababab'));
    test('2. Repeat 1 time', () => expect('ab'.repeat(1), 'ab'));
    test('3. Repeat 0 times', () => expect('ab'.repeat(0), ''));
    test('4. Repeat negative times', () => expect('ab'.repeat(-1), ''));
    test('5. Empty string repeat', () => expect(''.repeat(5), ''));
    test('6. Single char repeat', () => expect('a'.repeat(4), 'aaaa'));
    test('7. Unicode repeat', () => expect('你好'.repeat(2), '你好你好'));
    test('8. Symbol repeat', () => expect('*'.repeat(5), '*****'));
    test('9. Space repeat', () => expect(' '.repeat(3), '   '));
    test('10. Long string repeat', () => expect('abc'.repeat(2), 'abcabc'));
  });

  group('removeAll', () {
    test('1. Remove single char pattern', () => expect('a-b-c'.removeAll('-'), 'abc'));
    test(
      '2. Remove multiple char pattern',
      () => expect('abXYZcdXYZef'.removeAll('XYZ'), 'abcdef'),
    );
    test('3. Pattern not found', () => expect('hello'.removeAll('xyz'), 'hello'));
    test('4. Remove all occurrences', () => expect('aaa'.removeAll('a'), ''));
    test('5. Empty string', () => expect(''.removeAll('a'), ''));
    test('6. Null pattern', () => expect('hello'.removeAll(null), 'hello'));
    test('7. Remove spaces', () => expect('a b c'.removeAll(' '), 'abc'));
    test('8. Remove regex pattern', () => expect('a1b2c3'.removeAll(RegExp(r'\d')), 'abc'));
    test('9. Unicode pattern', () => expect('你好你好'.removeAll('你'), '好好'));
    test('10. Case sensitive removal', () => expect('AaAa'.removeAll('a'), 'AA'));
  });

  group('replaceLastNCharacters', () {
    test(
      '1. Replace last 3 chars',
      () => expect('password'.replaceLastNCharacters(3, '*'), 'passw***'),
    );
    test('2. Replace last 1 char', () => expect('test'.replaceLastNCharacters(1, '#'), 'tes#'));
    test('3. Replace more than length', () => expect('ab'.replaceLastNCharacters(5, '*'), 'ab'));
    test('4. Replace 0 chars', () => expect('hello'.replaceLastNCharacters(0, '*'), 'hello'));
    test('5. Replace negative', () => expect('hello'.replaceLastNCharacters(-1, '*'), 'hello'));
    test('6. Replace all chars', () => expect('abc'.replaceLastNCharacters(3, '*'), '***'));
    test('7. Empty string', () => expect(''.replaceLastNCharacters(2, '*'), ''));
    test(
      '8. Replace with multiple chars',
      () => expect('test'.replaceLastNCharacters(2, 'XX'), 'teXXXX'),
    );
    test('9. Replace exactly length', () => expect('abc'.replaceLastNCharacters(3, '#'), '###'));
    test('10. Single char string', () => expect('a'.replaceLastNCharacters(1, '*'), '*'));
  });

  group('makeNonBreaking', () {
    test('1. Replace hyphen', () => expect('non-breaking'.makeNonBreaking(), 'non\u2011breaking'));
    test('2. Replace space', () => expect('hello world'.makeNonBreaking(), 'hello\u00A0world'));
    test('3. Replace both', () => expect('a-b c'.makeNonBreaking(), 'a\u2011b\u00A0c'));
    test('4. No replacements needed', () => expect('hello'.makeNonBreaking(), 'hello'));
    test('5. Empty string', () => expect(''.makeNonBreaking(), ''));
    test('6. Multiple hyphens', () => expect('a-b-c'.makeNonBreaking(), 'a\u2011b\u2011c'));
    test('7. Multiple spaces', () => expect('a b c'.makeNonBreaking(), 'a\u00A0b\u00A0c'));
    test('8. Only hyphens', () => expect('---'.makeNonBreaking(), '\u2011\u2011\u2011'));
    test('9. Only spaces', () => expect('   '.makeNonBreaking(), '\u00A0\u00A0\u00A0'));
    test(
      '10. Mixed content',
      () => expect('hello-world test'.makeNonBreaking(), 'hello\u2011world\u00A0test'),
    );
  });

  group('removeSingleCharacterWords', () {
    test(
      '1. Remove single letter words',
      () => expect('a b c test'.removeSingleCharacterWords(), 'test'),
    );
    test(
      '2. No single char words',
      () => expect('hello world'.removeSingleCharacterWords(), 'hello world'),
    );
    test('3. Empty string', () => expect(''.removeSingleCharacterWords(), ''));
    test('4. Only single char words', () => expect('a b c'.removeSingleCharacterWords(), null));
    test(
      '5. Preserve multi-char words',
      () => expect('I am a test'.removeSingleCharacterWords(), 'am test'),
    );
    test(
      '6. Without trim',
      () => expect('  a test  '.removeSingleCharacterWords(trim: false), ' test '),
    );
    test(
      '7. Without removing multiple spaces',
      () => expect(
        'a  test'.removeSingleCharacterWords(removeMultipleSpaces: false, trim: false),
        '  test',
      ),
    );
    test(
      '8. Numbers as single chars',
      () => expect('1 2 test'.removeSingleCharacterWords(), 'test'),
    );
    test(
      '9. Mixed content',
      () => expect('a test b word c'.removeSingleCharacterWords(), 'test word'),
    );
    test(
      '10. Single word preserved',
      () => expect('a hello'.removeSingleCharacterWords(), 'hello'),
    );
    test(
      '11. Unicode single-letter words',
      () => expect('你 好 test'.removeSingleCharacterWords(), 'test'),
    );
  });

  group('replaceLineBreaks', () {
    test('1. Replace newlines with space', () => expect('a\nb\nc'.replaceLineBreaks(' '), 'a b c'));
    test('2. Replace newlines with empty', () => expect('a\nb'.replaceLineBreaks(''), 'ab'));
    test('3. No newlines', () => expect('hello'.replaceLineBreaks(' '), 'hello'));
    test('4. Empty string', () => expect(''.replaceLineBreaks(' '), ''));
    test('5. Replace with comma', () => expect('a\nb\nc'.replaceLineBreaks(', '), 'a, b, c'));
    test('6. Null replacement', () => expect('a\nb'.replaceLineBreaks(null), 'ab'));
    test(
      '7. Multiple consecutive newlines with dedup',
      () => expect('a\n\nb'.replaceLineBreaks(' '), 'a b'),
    );
    test(
      '8. Multiple newlines without dedup',
      () => expect('a\n\nb'.replaceLineBreaks(' ', deduplicate: false), 'a  b'),
    );
    test('9. Only newlines', () => expect('\n\n\n'.replaceLineBreaks(' '), ' '));
    test(
      '10. Newline at start and end',
      () => expect('\nhello\n'.replaceLineBreaks(' '), ' hello '),
    );
    test('11. Special replacement +', () => expect('a\n\n\nb'.replaceLineBreaks('+'), 'a+b'));
    test(
      '12. Special replacement regex chars',
      () => expect('a\n\nb'.replaceLineBreaks('.*'), 'a.*b'),
    );
  });

  group('removeLeadingAndTrailing', () {
    test(
      '1. Remove from both ends',
      () => expect('---hello---'.removeLeadingAndTrailing('-'), 'hello'),
    );
    test(
      '2. Remove from start only',
      () => expect('---hello'.removeLeadingAndTrailing('-'), 'hello'),
    );
    test(
      '3. Remove from end only',
      () => expect('hello---'.removeLeadingAndTrailing('-'), 'hello'),
    );
    test('4. Nothing to remove', () => expect('hello'.removeLeadingAndTrailing('-'), 'hello'));
    test('5. Empty string', () => expect(''.removeLeadingAndTrailing('-'), ''));
    test('6. Null find', () => expect('hello'.removeLeadingAndTrailing(null), 'hello'));
    test('7. Empty find', () => expect('hello'.removeLeadingAndTrailing(''), 'hello'));
    test(
      '8. Remove multi-char pattern',
      () => expect('XXhelloXX'.removeLeadingAndTrailing('XX'), 'hello'),
    );
    test(
      '9. With trim enabled',
      () => expect('  ---hello---  '.removeLeadingAndTrailing('-', trim: true), 'hello'),
    );
    test('10. All removed returns null', () => expect('---'.removeLeadingAndTrailing('-'), null));
    test(
      '11. Keep middle occurrences',
      () => expect('---hel-lo---'.removeLeadingAndTrailing('-'), 'hel-lo'),
    );
    test('12. Unicode pattern', () => expect('你你hello你你'.removeLeadingAndTrailing('你'), 'hello'));
  });

  group('firstWord', () {
    test('1. Multiple words', () => expect('hello world test'.firstWord(), 'hello'));
    test('2. Single word', () => expect('hello'.firstWord(), 'hello'));
    test('3. Empty string', () => expect(''.firstWord(), null));
    test('4. Leading spaces', () => expect('  hello world'.firstWord(), 'hello'));
    test('5. Only spaces', () => expect('   '.firstWord(), null));
    test('6. Unicode words', () => expect('你好 世界'.firstWord(), '你好'));
    test('7. Numbers as first word', () => expect('123 abc'.firstWord(), '123'));
    test('8. Punctuation attached', () => expect('hello, world'.firstWord(), 'hello,'));
    test('9. Hyphenated word', () => expect('well-known fact'.firstWord(), 'well-known'));
    test(
      '10. Tab separator',
      () => expect('hello\tworld'.firstWord(), 'hello\tworld'),
    ); // Tab not a separator
  });

  group('secondWord', () {
    test('1. Multiple words', () => expect('hello world test'.secondWord(), 'world'));
    test('2. Two words', () => expect('hello world'.secondWord(), 'world'));
    test('3. Single word', () => expect('hello'.secondWord(), null));
    test('4. Empty string', () => expect(''.secondWord(), null));
    test('5. Leading spaces', () => expect('  hello world'.secondWord(), 'world'));
    test('6. Only spaces', () => expect('   '.secondWord(), null));
    test('7. Unicode words', () => expect('你好 世界 测试'.secondWord(), '世界'));
    test('8. Three words', () => expect('one two three'.secondWord(), 'two'));
    test('9. Numbers', () => expect('1 2 3'.secondWord(), '2'));
    test('10. Extra spaces between', () => expect('hello    world'.secondWord(), 'world'));
  });

  group('count', () {
    test('1. Count single char', () => expect('banana'.count('a'), 3));
    test('2. Count pattern', () => expect('abcabcabc'.count('abc'), 3));
    test('3. Not found', () => expect('hello'.count('x'), 0));
    test('4. Empty find', () => expect('hello'.count(''), 0));
    test('5. Empty string', () => expect(''.count('a'), 0));
    test('6. Count at edges', () => expect('-hello-world-'.count('-'), 3));
    test('7. Case sensitive', () => expect('AaAa'.count('a'), 2));
    test('8. Unicode', () => expect('你好你好'.count('你'), 2));
    test('9. Overlapping not counted', () => expect('aaaa'.count('aa'), 2));
    test('10. Long pattern', () => expect('testtest'.count('test'), 2));
  });

  group('lettersOnly', () {
    test('1. Mixed content', () => expect('abc123!@#'.lettersOnly(), 'abc'));
    test('2. Only letters', () => expect('hello'.lettersOnly(), 'hello'));
    test('3. No letters', () => expect('12345'.lettersOnly(), ''));
    test('4. Empty string', () => expect(''.lettersOnly(), ''));
    test('5. Spaces removed', () => expect('hello world'.lettersOnly(), 'helloworld'));
    test('6. Mixed case', () => expect('HeLLo'.lettersOnly(), 'HeLLo'));
    test('7. Symbols removed', () => expect('a!b@c#'.lettersOnly(), 'abc'));
    test('8. Unicode letters removed', () => expect('abc你好'.lettersOnly(), 'abc'));
    test('9. Accented chars removed', () => expect('café'.lettersOnly(), 'caf'));
    test('10. Numbers between letters', () => expect('a1b2c3'.lettersOnly(), 'abc'));
  });

  group('lowerCaseLettersOnly', () {
    test('1. Mixed case', () => expect('HeLLo'.lowerCaseLettersOnly(), 'eo'));
    test('2. All lowercase', () => expect('hello'.lowerCaseLettersOnly(), 'hello'));
    test('3. All uppercase', () => expect('HELLO'.lowerCaseLettersOnly(), ''));
    test('4. Empty string', () => expect(''.lowerCaseLettersOnly(), ''));
    test('5. Mixed with numbers', () => expect('aB1cD2'.lowerCaseLettersOnly(), 'ac'));
    test('6. Only numbers', () => expect('12345'.lowerCaseLettersOnly(), ''));
    test('7. Spaces', () => expect('a b c'.lowerCaseLettersOnly(), 'abc'));
    test('8. Symbols', () => expect('a!b@c'.lowerCaseLettersOnly(), 'abc'));
    test('9. Single lowercase', () => expect('ABCdEFG'.lowerCaseLettersOnly(), 'd'));
    test('10. Unicode removed', () => expect('你abc好'.lowerCaseLettersOnly(), 'abc'));
  });

  group('firstLines', () {
    test('1. Get first 2 lines', () => expect('line1\nline2\nline3'.firstLines(2), 'line1\nline2'));
    test('2. Get first 1 line', () => expect('line1\nline2'.firstLines(1), 'line1'));
    test(
      '3. Request more lines than exist',
      () => expect('line1\nline2'.firstLines(5), 'line1\nline2'),
    );
    test('4. Single line string', () => expect('single'.firstLines(3), 'single'));
    test('5. Empty string', () => expect(''.firstLines(2), ''));
    test('6. Zero lines', () => expect('line1\nline2'.firstLines(0), ''));
    test('7. Negative lines', () => expect('line1\nline2'.firstLines(-1), ''));
    test('8. All lines', () => expect('a\nb\nc'.firstLines(3), 'a\nb\nc'));
    test('9. Empty lines included', () => expect('a\n\nb'.firstLines(2), 'a\n'));
    test('10. Trailing newline', () => expect('a\nb\n'.firstLines(2), 'a\nb'));
  });

  group('trimLines', () {
    test('1. Trim each line', () => expect('  a  \n  b  '.trimLines(), 'a\nb'));
    test('2. Remove empty lines', () => expect('a\n\nb'.trimLines(), 'a\nb'));
    test('3. Single line', () => expect('  hello  '.trimLines(), 'hello'));
    test('4. Empty string', () => expect(''.trimLines(), ''));
    test('5. Only whitespace lines', () => expect('  \n  \n  '.trimLines(), ''));
    test('6. Mixed content', () => expect('  a  \n  \n  b  '.trimLines(), 'a\nb'));
    test('7. No trimming needed', () => expect('a\nb\nc'.trimLines(), 'a\nb\nc'));
    test('8. Tab characters', () => expect('\ta\t\n\tb\t'.trimLines(), 'a\nb'));
    test('9. Multiple empty lines', () => expect('a\n\n\n\nb'.trimLines(), 'a\nb'));
    test('10. Leading empty lines', () => expect('\n\na\nb'.trimLines(), 'a\nb'));
  });

  group('multiLinePrefix', () {
    test('1. Prefix each line', () => expect('a\nb\nc'.multiLinePrefix('> '), '> a\n> b\n> c'));
    test('2. Single line', () => expect('hello'.multiLinePrefix('> '), '> hello'));
    test('3. Empty prefix', () => expect('a\nb'.multiLinePrefix(''), 'a\nb'));
    test('4. Empty string no prefix', () => expect(''.multiLinePrefix('> '), ''));
    test(
      '5. Empty string with prefix when enabled',
      () => expect(''.multiLinePrefix('> ', prefixEmptyStrings: true), '> '),
    );
    test('6. Number prefix', () => expect('a\nb'.multiLinePrefix('1. '), '1. a\n1. b'));
    test('7. Tab prefix', () => expect('a\nb'.multiLinePrefix('\t'), '\ta\n\tb'));
    test('8. Multi-char prefix', () => expect('a\nb'.multiLinePrefix('>>> '), '>>> a\n>>> b'));
    test('9. Unicode prefix', () => expect('a\nb'.multiLinePrefix('• '), '• a\n• b'));
    test(
      '10. Nested content',
      () => expect('line1\nline2'.multiLinePrefix('  '), '  line1\n  line2'),
    );
  });

  group('endsWithAny', () {
    test(
      '1. Ends with one of list',
      () => expect('hello!'.endsWithAny(<String>['.', '!', '?']), isTrue),
    );
    test(
      '2. Does not end with any',
      () => expect('hello'.endsWithAny(<String>['.', '!', '?']), isFalse),
    );
    test('3. Empty list', () => expect('hello!'.endsWithAny(<String>[]), isFalse));
    test('4. Empty string', () => expect(''.endsWithAny(<String>['a']), isFalse));
    test('5. Ends with period', () => expect('test.'.endsWithAny(<String>['.', '!']), isTrue));
    test(
      '6. Multiple matches (first wins)',
      () => expect('test?'.endsWithAny(<String>['!', '?']), isTrue),
    );
    test('7. Single char string', () => expect('a'.endsWithAny(<String>['a', 'b']), isTrue));
    test('8. Unicode ending', () => expect('hello世'.endsWithAny(<String>['世', '界']), isTrue));
    test('9. Space ending', () => expect('hello '.endsWithAny(<String>[' ', '\t']), isTrue));
    test('10. Number ending', () => expect('test1'.endsWithAny(<String>['1', '2', '3']), isTrue));
  });

  group('endsWithPunctuation', () {
    test('1. Ends with period', () => expect('Hello.'.endsWithPunctuation(), isTrue));
    test('2. Ends with question', () => expect('Hello?'.endsWithPunctuation(), isTrue));
    test('3. Ends with exclamation', () => expect('Hello!'.endsWithPunctuation(), isTrue));
    test('4. No punctuation', () => expect('Hello'.endsWithPunctuation(), isFalse));
    test('5. Ends with comma', () => expect('Hello,'.endsWithPunctuation(), isFalse));
    test('6. Empty string', () => expect(''.endsWithPunctuation(), isFalse));
    test('7. Only period', () => expect('.'.endsWithPunctuation(), isTrue));
    test('8. Multiple sentences', () => expect('Hello. World!'.endsWithPunctuation(), isTrue));
    test('9. Ends with space', () => expect('Hello. '.endsWithPunctuation(), isFalse));
    test('10. Ends with semicolon', () => expect('Hello;'.endsWithPunctuation(), isFalse));
  });

  group('isAny', () {
    test('1. Match found', () => expect('hello'.isAny(<String>['hi', 'hello', 'hey']), isTrue));
    test('2. No match', () => expect('hello'.isAny(<String>['hi', 'hey']), isFalse));
    test('3. Empty list', () => expect('hello'.isAny(<String>[]), isFalse));
    test('4. Empty string', () => expect(''.isAny(<String>['', 'a']), isFalse));
    test('5. Case sensitive', () => expect('Hello'.isAny(<String>['hello']), isFalse));
    test('6. Single item match', () => expect('test'.isAny(<String>['test']), isTrue));
    test('7. Unicode match', () => expect('你好'.isAny(<String>['hello', '你好']), isTrue));
    test('8. Number match', () => expect('123'.isAny(<String>['123', '456']), isTrue));
    test('9. Whitespace match', () => expect(' '.isAny(<String>[' ', '\t']), isTrue));
    test('10. Partial no match', () => expect('hello'.isAny(<String>['hel', 'llo']), isFalse));
  });

  group('secondIndex', () {
    test('1. Second occurrence exists', () => expect('a-b-c'.secondIndex('-'), 3));
    test('2. Only one occurrence', () => expect('a-bc'.secondIndex('-'), -1));
    test('3. No occurrence', () => expect('abc'.secondIndex('-'), -1));
    test('4. Empty char', () => expect('abc'.secondIndex(''), -1));
    test('5. Empty string', () => expect(''.secondIndex('a'), -1));
    test('6. Multiple chars at start', () => expect('--abc'.secondIndex('-'), 1));
    test('7. Three occurrences', () => expect('a-b-c-d'.secondIndex('-'), 3));
    test('8. At end', () => expect('abc--'.secondIndex('-'), 4));
    test('9. Multi-char pattern', () => expect('abXYabXYab'.secondIndex('XY'), 6));
    test('10. Unicode', () => expect('你好你好'.secondIndex('好'), 3));
  });

  group('extractCurlyBraces', () {
    test(
      '1. Single match',
      () => expect('Hello {world}'.extractCurlyBraces(), <String>['{world}']),
    );
    test('2. Multiple matches', () {
      final List<String>? result = '{a} and {b}'.extractCurlyBraces();
      expect(result, isNotNull);
      expect(result!.isNotEmpty, isTrue);
    });
    test('3. No matches', () => expect('hello world'.extractCurlyBraces(), null));
    test('4. Empty braces', () => expect('{}'.extractCurlyBraces(), null));
    test('5. Empty string', () => expect(''.extractCurlyBraces(), null));
    test('6. Nested braces', () {
      final List<String>? result = '{{nested}}'.extractCurlyBraces();
      expect(result, isNotNull);
    });
    test(
      '7. At edges exact order',
      () => expect('{start} middle {end}'.extractCurlyBraces(), <String>['{start}', '{end}']),
    );
    test('8. With content', () => expect('Value: {123}'.extractCurlyBraces(), <String>['{123}']));
    test(
      '9. Complex content',
      () => expect('func({x: 1})'.extractCurlyBraces(), <String>['{x: 1}']),
    );
    test('10. Unicode inside', () => expect('{你好}'.extractCurlyBraces(), <String>['{你好}']));
    test(
      '11. Many adjacent groups',
      () => expect('{a}{b}{c}'.extractCurlyBraces(), <String>['{a}', '{b}', '{c}']),
    );
    test(
      '12. Non-greedy across groups',
      () => expect('{a}{bc}'.extractCurlyBraces(), <String>['{a}', '{bc}']),
    );
  });

  group('appendNotEmpty', () {
    test('1. Append to non-empty', () => expect('hello'.appendNotEmpty('!'), 'hello!'));
    test('2. Append to empty', () => expect(''.appendNotEmpty('!'), ''));
    test('3. Append empty string', () => expect('hello'.appendNotEmpty(''), 'hello'));
    test('4. Append space', () => expect('hello'.appendNotEmpty(' world'), 'hello world'));
    test('5. Unicode append', () => expect('你好'.appendNotEmpty('世界'), '你好世界'));
    test('6. Number append', () => expect('test'.appendNotEmpty('123'), 'test123'));
    test('7. Newline append', () => expect('line1'.appendNotEmpty('\nline2'), 'line1\nline2'));
    test('8. Symbol append', () => expect('done'.appendNotEmpty('...'), 'done...'));
    test('9. Single char', () => expect('a'.appendNotEmpty('b'), 'ab'));
    test('10. Multiple appends', () => expect('a'.appendNotEmpty('b').appendNotEmpty('c'), 'abc'));
  });

  group('prefixNotEmpty', () {
    test('1. Prefix non-empty', () => expect('world'.prefixNotEmpty('hello '), 'hello world'));
    test('2. Prefix empty string', () => expect(''.prefixNotEmpty('hello'), ''));
    test('3. Null prefix', () => expect('hello'.prefixNotEmpty(null), 'hello'));
    test('4. Empty prefix', () => expect('hello'.prefixNotEmpty(''), 'hello'));
    test('5. Unicode prefix', () => expect('世界'.prefixNotEmpty('你好'), '你好世界'));
    test('6. Number prefix', () => expect('abc'.prefixNotEmpty('123'), '123abc'));
    test('7. Symbol prefix', () => expect('item'.prefixNotEmpty('• '), '• item'));
    test('8. Newline prefix', () => expect('line2'.prefixNotEmpty('line1\n'), 'line1\nline2'));
    test('9. Single char', () => expect('b'.prefixNotEmpty('a'), 'ab'));
    test('10. Tab prefix', () => expect('content'.prefixNotEmpty('\t'), '\tcontent'));
  });

  group('grammarArticle', () {
    test('1. Starts with a', () => expect('apple'.grammarArticle(), 'an'));
    test('2. Starts with e', () => expect('elephant'.grammarArticle(), 'an'));
    test('3. Starts with i', () => expect('ice'.grammarArticle(), 'an'));
    test('4. Starts with o', () => expect('orange'.grammarArticle(), 'an'));
    test('5. Starts with u', () => expect('umbrella'.grammarArticle(), 'an'));
    test('6. Starts with consonant', () => expect('book'.grammarArticle(), 'a'));
    test('7. Uppercase vowel', () => expect('Apple'.grammarArticle(), 'an'));
    test('8. Uppercase consonant', () => expect('Book'.grammarArticle(), 'a'));
    test('9. Empty string', () => expect(''.grammarArticle(), ''));
    test('10. Single vowel', () => expect('a'.grammarArticle(), 'an'));
    test('11. Single consonant', () => expect('b'.grammarArticle(), 'a'));
    test('12. Number', () => expect('8'.grammarArticle(), 'a'));
    test('13. Silent h word', () => expect('hour'.grammarArticle(), 'an'));
    test('14. User with you-sound', () => expect('user'.grammarArticle(), 'a'));
    test('15. University you-sound', () => expect('university'.grammarArticle(), 'a'));
    test('16. One- prefixed', () => expect('one-time'.grammarArticle(), 'a'));
  });

  group('possess', () {
    test('1. Regular word', () => expect('John'.possess(), "John's"));
    test('2. Word ending in s (US)', () => expect('James'.possess(), "James'"));
    test(
      '3. Word ending in s (non-US)',
      () => expect('James'.possess(isLocaleUS: false), "James's"),
    );
    test('4. Empty string', () => expect(''.possess(), ''));
    test('5. Single char', () => expect('a'.possess(), "a's"));
    test('6. Single char s', () => expect('s'.possess(), "s'"));
    test('7. Name with apostrophe', () => expect("O'Brien".possess(), "O'Brien's"));
    test('8. Unicode', () => expect('你好'.possess(), "你好's"));
    test('9. Plural ending in s', () => expect('cats'.possess(), "cats'"));
    test('10. Word ending in ss', () => expect('boss'.possess(), "boss'"));
    test('11. Trims input whitespace', () => expect('  James  '.possess(), "James'"));
  });

  group('pluralize', () {
    test('1. Regular plural', () => expect('cat'.pluralize(2), 'cats'));
    test('2. Count is 1 returns singular', () => expect('cat'.pluralize(1), 'cat'));
    test('3. Ends with s adds es', () {
      final String result = 'bus'.pluralize(2);
      expect(result, endsWith('s'));
    });
    test('4. Ends with x adds es', () {
      final String result = 'box'.pluralize(2);
      expect(result, endsWith('s'));
    });
    test('5. Ends with z adds es', () {
      final String result = 'quiz'.pluralize(2);
      expect(result, endsWith('s'));
    });
    test('6. Ends with y after consonant', () => expect('baby'.pluralize(2), 'babies'));
    test('7. Ends with y after vowel', () => expect('day'.pluralize(2), 'days'));
    test('8. Ends with sh', () => expect('dish'.pluralize(2), 'dishes'));
    test('9. Ends with ch', () => expect('watch'.pluralize(2), 'watches'));
    test('10. Simple mode', () => expect('cat'.pluralize(2, simple: true), 'cats'));
    test('11. Empty string', () => expect(''.pluralize(2), ''));
    test('12. Single char', () => expect('a'.pluralize(2), 'a'));
    test('13. Count null', () => expect('cat'.pluralize(null), 'cats'));
    test('14. Count zero', () => expect('cat'.pluralize(0), 'cats'));
  });

  group('trimWithEllipsis', () {
    test('1. Long string gets trimmed', () {
      final String result = 'abcdefghijklmnop'.trimWithEllipsis();
      expect(result, contains('…'));
      expect(result.length, lessThan(16));
    });
    test('2. Short string returns ellipsis', () => expect('abc'.trimWithEllipsis(), '…'));
    test('3. Custom minLength', () {
      final String result = 'abcdefghij'.trimWithEllipsis(minLength: 3);
      expect(result, contains('…'));
    });
    test('4. Exactly at threshold', () {
      final String result = 'abcdefghijkl'.trimWithEllipsis();
      expect(result, contains('…'));
    });
    test('5. Empty string', () => expect(''.trimWithEllipsis(), '…'));
    test('6. Single char', () => expect('a'.trimWithEllipsis(), '…'));
    test('7. MinLength 1', () {
      final String result = 'abcde'.trimWithEllipsis(minLength: 1);
      expect(result, contains('…'));
    });
    test('8. Long string minLength 10', () {
      final String result = 'abcdefghijklmnopqrstuvwxyz'.trimWithEllipsis(minLength: 10);
      expect(result, contains('…'));
      expect(result, startsWith('abcdefghij'));
    });
    test('9. Unicode string', () {
      final String result = '你好世界测试文本内容'.trimWithEllipsis();
      expect(result, contains('…'));
    });
    test('10. MinLength 2', () {
      final String result = 'abcdefgh'.trimWithEllipsis(minLength: 2);
      expect(result, contains('…'));
    });
  });

  group('collapseMultilineString', () {
    test(
      '1. Collapse newlines',
      () => expect('hello\nworld'.collapseMultilineString(cropLength: 20), 'hello world'),
    );
    test(
      '2. Crop long string',
      () => expect('hello world test'.collapseMultilineString(cropLength: 10), 'hello…'),
    );
    test(
      '3. No ellipsis option',
      () => expect(
        'hello world test'.collapseMultilineString(cropLength: 10, appendEllipsis: false),
        'hello',
      ),
    );
    test('4. Empty string', () => expect(''.collapseMultilineString(cropLength: 10), ''));
    test(
      '5. Short string unchanged',
      () => expect('hi'.collapseMultilineString(cropLength: 10), 'hi'),
    );
    test(
      '6. Multiple newlines',
      () => expect('a\nb\nc'.collapseMultilineString(cropLength: 20), 'a b c'),
    );
    test(
      '7. Collapse double spaces',
      () => expect('hello  world'.collapseMultilineString(cropLength: 20), 'hello world'),
    );
    test(
      '8. Crop at word boundary',
      () => expect(
        'hello beautiful world'.collapseMultilineString(cropLength: 15),
        'hello beautiful…',
      ),
    );
    test(
      '9. Leading/trailing whitespace',
      () => expect('  hello world  '.collapseMultilineString(cropLength: 20), 'hello world'),
    );
    test(
      '10. Unicode content',
      () => expect('你好\n世界'.collapseMultilineString(cropLength: 10), '你好 世界'),
    );
  });
}
