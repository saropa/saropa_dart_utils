import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_manipulation_and_sanitization_extensions.dart';

// cspell: disable
void main() {
  group('StringManipulationAndSanitizationExtensions', () {
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
        () =>
            expect('a fine day is a good day'.removeLastOccurrence(' day'), 'a fine day is a good'),
      );
    });

    group('removeMatchingWrappingBrackets', () {
      test(
        '1. With parentheses',
        () => expect('(hello)'.removeMatchingWrappingBrackets(), 'hello'),
      );
      test(
        '2. With square brackets',
        () => expect('[hello]'.removeMatchingWrappingBrackets(), 'hello'),
      );
      test('3. No brackets', () => expect('hello'.removeMatchingWrappingBrackets(), 'hello'));
      test(
        '4. Mismatched brackets',
        () => expect('(hello]'.removeMatchingWrappingBrackets(), '(hello]'),
      );
      test(
        '5. Internal brackets',
        () => expect('(a[b]c)'.removeMatchingWrappingBrackets(), 'a[b]c'),
      );
      test('6. Empty brackets', () => expect('()'.removeMatchingWrappingBrackets(), ''));
      test('7. Empty string', () => expect(''.removeMatchingWrappingBrackets(), ''));
      test(
        '8. Only one bracket',
        () => expect('(hello'.removeMatchingWrappingBrackets(), '(hello'),
      );
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
      test(
        '9. Multiple chars to wrap',
        () => expect('||hello||'.removeWrappingChar('|'), '|hello|'),
      );
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
      test(
        '2. Suffix does not exist',
        () => expect('Hello World'.removeEnd('Hello'), 'Hello World'),
      );
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
      test(
        '6. removeFirstLastChar on 3-char string',
        () => expect('abc'.removeFirstLastChar(), 'b'),
      );
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
      test(
        '4. With no apostrophes',
        () => expect('its a test'.normalizeApostrophe(), 'its a test'),
      );
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
      test('5. removeNonNumbers basic', () => expect('a1b2c3'.removeNonNumbers(), '123'));
      test(
        '6. removeNonNumbers with symbols',
        () => expect('+1 (800) 555-1234'.removeNonNumbers(), '18005551234'),
      );
      test('7. toAlphaOnly on empty string', () => expect(''.toAlphaOnly(), ''));
      test(
        '8. removeNonAlphaNumeric on empty string',
        () => expect(''.removeNonAlphaNumeric(), ''),
      );
      test('9. removeNonNumbers on empty string', () => expect(''.removeNonNumbers(), ''));
      test('10. removeNonNumbers with no numbers', () => expect('abc-def'.removeNonNumbers(), ''));
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
  });
}
