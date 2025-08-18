import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_parsing_and_slicing_extensions.dart';

// cspell: disable
void main() {
  // --- Group 1: StringParsingAndSlicingExtensions ---
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
}
