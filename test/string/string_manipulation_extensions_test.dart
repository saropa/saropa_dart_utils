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

  group('removeEndNullable', () {
    // Happy path: a real suffix is present and gets stripped once.
    test('should strip a matching suffix', () {
      expect('hello.txt'.removeEndNullable('.txt'), 'hello');
    });

    test('should leave string unchanged when suffix absent', () {
      expect('hello'.removeEndNullable('.txt'), 'hello');
    });

    // The "nothing to strip" branch: a null/empty find returns the receiver.
    test('should return receiver unchanged for null find', () {
      expect('hello'.removeEndNullable(null), 'hello');
    });

    test('should return receiver unchanged for empty find', () {
      expect('hello'.removeEndNullable(''), 'hello');
    });

    // The deliberate null-vs-empty split: empty receiver + a real suffix is
    // the ONLY case that yields null (no source to carry the suffix).
    test('should return null for empty receiver with non-empty find', () {
      expect(''.removeEndNullable('x'), isNull);
    });

    test('should return empty (unchanged) for empty receiver with null find', () {
      expect(''.removeEndNullable(null), '');
    });

    test('should return empty (unchanged) for empty receiver with empty find', () {
      expect(''.removeEndNullable(''), '');
    });

    // Whole-string match strips to '' — null is reserved for the empty-source
    // case above, so this must NOT collapse to null.
    test('should strip whole-string match to empty string, not null', () {
      expect('abc'.removeEndNullable('abc'), '');
    });

    // Suffix longer than the receiver cannot match: receiver returned as-is.
    test('should return unchanged when suffix longer than receiver', () {
      expect('ab'.removeEndNullable('xabc'), 'ab');
    });

    // find contains the whole receiver plus a prefix: still no suffix match.
    test('should return unchanged when find contains receiver plus more', () {
      expect('x'.removeEndNullable('yx'), 'x');
    });

    // Delegates to removeEnd, which removes only ONE trailing occurrence.
    test('should remove only one trailing occurrence of a repeated suffix', () {
      expect('aaa'.removeEndNullable('a'), 'aa');
    });

    // Suffix matching is case-sensitive: a case mismatch is not stripped.
    test('should be case-sensitive (no strip on case mismatch)', () {
      expect('Hello.TXT'.removeEndNullable('.txt'), 'Hello.TXT');
    });

    // Multi-byte (combining) and surrogate-pair suffixes strip cleanly.
    test('should strip a multi-byte accented-letter suffix', () {
      expect('café'.removeEndNullable('é'), 'caf');
    });

    test('should strip a surrogate-pair emoji suffix without leaving a lone surrogate', () {
      // U+1F642 is a single code point stored as a UTF-16 surrogate pair; the
      // full pair is the suffix, so the result must be a clean 'hi'.
      final String result = 'hi🙂'.removeEndNullable('🙂')!;
      expect(result, 'hi');
      expect(result.codeUnits, 'hi'.codeUnits);
    });

    // Code-unit matching is NOT grapheme-aware: stripping a bare combining
    // mark off a base+mark cluster is documented behavior, not a defect.
    test('should strip a bare combining mark (UTF-16 matching, not grapheme-aware)', () {
      final String acute = String.fromCharCode(0x0301); // combining acute accent
      // 'e' + combining acute is one grapheme; removing the mark leaves 'e'.
      expect(('e$acute').removeEndNullable(acute), 'e');
    });

    // Whitespace suffixes, including non-breaking space, are ordinary matches.
    test('should strip a trailing ASCII space suffix', () {
      expect('hi '.removeEndNullable(' '), 'hi');
    });

    test('should strip a trailing non-breaking space suffix', () {
      final String nbsp = String.fromCharCode(0x00A0);
      expect(('hi$nbsp').removeEndNullable(nbsp), 'hi');
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

    test('removeLastChar drops a trailing emoji whole, not a half surrogate', () {
      // 'a😀' is 'a' plus a surrogate-pair emoji (2 code units, 1 grapheme).
      // Grapheme-based removal drops the whole emoji and leaves a clean 'a';
      // a code-unit-based slice would strand the low surrogate.
      expect('a😀'.removeLastChar(), 'a');
    });

    test('removeFirstLastChar should drop both ends', () {
      expect('abcd'.removeFirstLastChar(), 'bc');
    });

    test('removeFirstLastChar should return empty for length < 2', () {
      expect('a'.removeFirstLastChar(), '');
    });
  });

  group('removeLastChars', () {
    test('should drop the last count characters', () {
      expect('Hello'.removeLastChars(2), 'Hel');
    });

    test('should be a no-op for count zero', () {
      expect('Hello'.removeLastChars(0), 'Hello');
    });

    test('should be a no-op for negative count', () {
      expect('Hello'.removeLastChars(-3), 'Hello');
    });

    test('should return empty when count equals length', () {
      expect('Hi'.removeLastChars(2), '');
    });

    test('should return empty when count exceeds length', () {
      expect('Hi'.removeLastChars(5), '');
    });

    test('should return empty for an empty string', () {
      expect(''.removeLastChars(3), '');
    });

    test('counts grapheme clusters, not code units, for a trailing emoji', () {
      // 'a😀' is 'a' (1 grapheme) + emoji (surrogate pair, 1 grapheme) = 2
      // graphemes though 3 UTF-16 code units. Removing 1 grapheme drops the
      // whole emoji and leaves a clean 'a' (no stranded low surrogate);
      // removing both graphemes empties the string.
      expect('a😀'.removeLastChars(1), 'a');
      expect('a😀'.removeLastChars(2), '');
    });

    test('keeps a precomposed accented letter intact', () {
      // Precomposed e-acute (U+00E9), built explicitly so the assertion holds
      // regardless of how this source file is normalized on disk. 'H' + é +
      // 'llo' removing the last 2 yields 'H' + é + 'l' with the accent intact.
      final String acute = String.fromCharCode(0x00E9);
      expect('H${acute}llo'.removeLastChars(2), 'H${acute}l');
    });

    test('treats a decomposed base+combining-mark pair as one grapheme', () {
      // Built explicitly as base 'e' + combining acute (U+0301) so the value is
      // genuinely decomposed regardless of source-file normalization: 'Cafe' +
      // U+0301 is 5 UTF-16 code units but only 4 grapheme clusters (the final
      // 'e' + mark fuse into one). Counting is grapheme-based throughout, so the
      // count argument is a count of visible characters: removing 1 drops the
      // whole accented cluster ('Caf'), and removing 2 drops the 'f' as well
      // ('Ca'). The accent is never split off its base.
      final String combiningAcute = String.fromCharCode(0x0301);
      final String decomposed = 'Cafe$combiningAcute';
      expect(decomposed.removeLastChars(1), 'Caf');
      expect(decomposed.removeLastChars(2), 'Ca');
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
