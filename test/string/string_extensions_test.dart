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
    test(
      '5. Cutoff is shorter than the first word',
      () => expect('documentation'.truncateWithEllipsisPreserveWords(5), '…'),
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
    test(
      '10. Single long word string',
      () => expect('supercalifragilisticexpialidocious'.truncateWithEllipsisPreserveWords(10), '…'),
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
