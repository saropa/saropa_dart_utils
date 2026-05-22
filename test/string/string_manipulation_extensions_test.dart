import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_manipulation_extensions.dart';

void main() {
  // cspell: disable
  group('insert', () {
    test('should insert at the given position', () {
      expect('helloworld'.insert(' ', 5), 'hello world');
    });

    test('should insert at the start', () {
      expect('bc'.insert('a', 0), 'abc');
    });

    test('should insert at the end', () {
      expect('ab'.insert('c', 2), 'abc');
    });

    test('should return unchanged when position out of bounds', () {
      expect('abc'.insert('x', 5), 'abc');
      expect('abc'.insert('x', -1), 'abc');
    });
  });

  group('removeLastOccurrence', () {
    test('should remove the last occurrence', () {
      expect('a-b-c'.removeLastOccurrence('-'), 'a-bc');
    });

    test('should return unchanged when not found', () {
      expect('abc'.removeLastOccurrence('-'), 'abc');
    });
  });

  group('isBracketWrapped', () {
    test('should be true for parentheses', () {
      expect('(x)'.isBracketWrapped(), isTrue);
    });

    test('should be true for square brackets', () {
      expect('[x]'.isBracketWrapped(), isTrue);
    });

    test('should be true for angle brackets', () {
      expect('<x>'.isBracketWrapped(), isTrue);
    });

    test('should be false for mismatched brackets', () {
      expect('(x]'.isBracketWrapped(), isFalse);
    });

    test('should be false for too-short strings', () {
      expect('('.isBracketWrapped(), isFalse);
    });
  });

  group('removeMatchingWrappingBrackets', () {
    test('should remove a matching pair', () {
      expect('(content)'.removeMatchingWrappingBrackets(), 'content');
    });

    test('should return unchanged when not wrapped', () {
      expect('content'.removeMatchingWrappingBrackets(), 'content');
    });
  });

  group('removeWrappingChar', () {
    test('should remove the wrapping char from both ends', () {
      expect('"quoted"'.removeWrappingChar('"'), 'quoted');
    });

    test('should trim before checking by default', () {
      expect('  *x*  '.removeWrappingChar('*'), 'x');
    });

    test('should not trim when trimFirst is false', () {
      expect('*x*'.removeWrappingChar('*', trimFirst: false), 'x');
    });
  });

  group('removeStart', () {
    test('should remove a matching start', () {
      expect('hello world'.removeStart('hello '), 'world');
    });

    test('should return null when result is empty', () {
      expect('abc'.removeStart('abc'), isNull);
    });

    test('should return unchanged when start absent', () {
      expect('abc'.removeStart('xyz'), 'abc');
    });

    test('should match case-insensitively when requested', () {
      expect('HELLOworld'.removeStart('hello', isCaseSensitive: false), 'world');
    });

    test('should trim before checking when trimFirst is true', () {
      expect('  hello world'.removeStart('hello ', trimFirst: true), 'world');
    });

    test('should return this for null or empty start', () {
      expect('abc'.removeStart(null), 'abc');
      expect('abc'.removeStart(''), 'abc');
    });
  });

  group('removeEnd', () {
    test('should remove a matching end', () {
      expect('file.txt'.removeEnd('.txt'), 'file');
    });

    test('should return unchanged when end absent', () {
      expect('file'.removeEnd('.txt'), 'file');
    });
  });

  group('removeFirstChar / removeLastChar / removeFirstLastChar', () {
    test('removeFirstChar should drop the first character', () {
      expect('abc'.removeFirstChar(), 'bc');
    });

    test('removeFirstChar should return empty for empty string', () {
      expect(''.removeFirstChar(), '');
    });

    test('removeLastChar should drop the last character', () {
      expect('abc'.removeLastChar(), 'ab');
    });

    test('removeFirstLastChar should drop both ends', () {
      expect('abcd'.removeFirstLastChar(), 'bc');
    });

    test('removeFirstLastChar should return empty for length < 2', () {
      expect('a'.removeFirstLastChar(), '');
    });
  });

  group('normalizeApostrophe', () {
    test('should replace a curly apostrophe with a straight one', () {
      final String curly = String.fromCharCode(0x2019);
      expect('it${curly}s'.normalizeApostrophe(), "it's");
    });

    test('should leave straight apostrophes unchanged', () {
      expect("it's".normalizeApostrophe(), "it's");
    });
  });

  group('toAlphaOnly', () {
    test('should remove non-letters', () {
      expect('Hello123!'.toAlphaOnly(), 'Hello');
    });

    test('should keep spaces when allowSpace is true', () {
      expect('Hello 123 World'.toAlphaOnly(allowSpace: true), 'Hello  World');
    });
  });

  group('removeNonAlphaNumeric', () {
    test('should remove symbols but keep letters and digits', () {
      expect('a1!b2@'.removeNonAlphaNumeric(), 'a1b2');
    });

    test('should keep spaces when allowSpace is true', () {
      expect('a1 b2!'.removeNonAlphaNumeric(allowSpace: true), 'a1 b2');
    });
  });

  group('replaceNonNumbers', () {
    test('should replace non-digits with the replacement', () {
      expect('abc123def'.replaceNonNumbers(replacement: '-'), '---123---');
    });

    test('should remove non-digits by default', () {
      expect('a1b2c3'.replaceNonNumbers(), '123');
    });
  });

  group('removeNonNumbers', () {
    test('should keep only digits', () {
      expect('(555) 123-4567'.removeNonNumbers(), '5551234567');
    });
  });

  group('removeAll', () {
    test('should remove all occurrences of a pattern', () {
      expect('a-b-c'.removeAll('-'), 'abc');
    });

    test('should return unchanged for null pattern', () {
      expect('a-b'.removeAll(null), 'a-b');
    });
  });

  group('replaceLastNCharacters', () {
    test('should replace the last n characters', () {
      expect('password'.replaceLastNCharacters(4, '*'), 'pass****');
    });

    test('should return unchanged when n <= 0', () {
      expect('abc'.replaceLastNCharacters(0, '*'), 'abc');
    });

    test('should return unchanged when n exceeds length', () {
      expect('abc'.replaceLastNCharacters(5, '*'), 'abc');
    });
  });

  group('makeNonBreaking', () {
    test('should replace hyphens with non-breaking hyphen U+2011', () {
      final String nbHyphen = String.fromCharCode(0x2011);
      expect('a-b'.makeNonBreaking(), 'a${nbHyphen}b');
    });

    test('should replace spaces with non-breaking space U+00A0', () {
      final String nbSpace = String.fromCharCode(0x00A0);
      expect('a b'.makeNonBreaking(), 'a${nbSpace}b');
    });
  });

  group('replaceLineBreaks', () {
    test('should replace newlines with the replacement', () {
      expect('a\nb\nc'.replaceLineBreaks(' '), 'a b c');
    });

    test('should deduplicate consecutive replacements by default', () {
      expect('a\n\n\nb'.replaceLineBreaks('-'), 'a-b');
    });

    test('should keep duplicates when deduplicate is false', () {
      expect('a\n\nb'.replaceLineBreaks('-', deduplicate: false), 'a--b');
    });

    test('should remove newlines for null replacement', () {
      expect('a\nb'.replaceLineBreaks(null), 'ab');
    });
  });

  group('removeLeadingAndTrailing', () {
    test('should strip leading and trailing occurrences', () {
      expect('--abc--'.removeLeadingAndTrailing('-'), 'abc');
    });

    test('should return null when everything is removed', () {
      expect('---'.removeLeadingAndTrailing('-'), isNull);
    });

    test('should return this for empty find', () {
      expect('abc'.removeLeadingAndTrailing(''), 'abc');
    });

    test('should trim between removals when trim is true', () {
      expect('  --abc--  '.removeLeadingAndTrailing('-', trim: true), 'abc');
    });
  });

  group('lettersOnly', () {
    test('should keep only ASCII letters', () {
      expect('Hello123World!'.lettersOnly(), 'HelloWorld');
    });

    test('should drop accented letters', () {
      expect('café'.lettersOnly(), 'caf');
    });

    test('should return empty for digits only', () {
      expect('123'.lettersOnly(), '');
    });

    test('should return empty for empty string', () {
      expect(''.lettersOnly(), '');
    });
  });

  group('lowerCaseLettersOnly', () {
    test('should keep only ASCII lowercase letters', () {
      expect('Hello123World!'.lowerCaseLettersOnly(), 'elloorld');
    });

    test('should return empty for uppercase and digits only', () {
      expect('ABC123'.lowerCaseLettersOnly(), '');
    });
  });

  group('getEverythingBefore / After / AfterLast', () {
    test('getEverythingBefore should return text before the first match', () {
      expect('a@b@c'.getEverythingBefore('@'), 'a');
    });

    test('getEverythingBefore should return this when not found', () {
      expect('abc'.getEverythingBefore('@'), 'abc');
    });

    test('getEverythingAfter should return text after the first match', () {
      expect('a@b@c'.getEverythingAfter('@'), 'b@c');
    });

    test('getEverythingAfterLast should return text after the last match', () {
      expect('a@b@c'.getEverythingAfterLast('@'), 'c');
    });

    test('getEverythingAfterLast should return this for empty find', () {
      expect('abc'.getEverythingAfterLast(''), 'abc');
    });
  });

  group('getRandomChar', () {
    test('should return a character from the string', () {
      expect('abc'.contains('abc'.getRandomChar()), isTrue);
    });

    test('should return empty for empty string', () {
      expect(''.getRandomChar(), '');
    });
  });

  group('repeat', () {
    test('should repeat the string count times', () {
      expect('abc'.repeat(3), 'abcabcabc');
    });

    test('should return empty for count <= 0', () {
      expect('abc'.repeat(0), '');
    });

    test('should return empty for empty string', () {
      expect(''.repeat(5), '');
    });
  });

  group('appendNotEmpty', () {
    test('should append when non-empty', () {
      expect('a'.appendNotEmpty('b'), 'ab');
    });

    test('should return empty when this is empty', () {
      expect(''.appendNotEmpty('b'), '');
    });
  });

  group('prefixNotEmpty', () {
    test('should prepend when both are non-empty', () {
      expect('b'.prefixNotEmpty('a'), 'ab');
    });

    test('should return this when this is empty', () {
      expect(''.prefixNotEmpty('a'), '');
    });

    test('should return this for null or empty value', () {
      expect('b'.prefixNotEmpty(null), 'b');
      expect('b'.prefixNotEmpty(''), 'b');
    });
  });
}
