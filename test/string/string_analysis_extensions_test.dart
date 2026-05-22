import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_analysis_extensions.dart';

void main() {
  // cspell: disable
  group('isLatin', () {
    test('should be true for ASCII letters only', () {
      expect('Hello'.isLatin(), isTrue);
    });

    test('should be false when digits present', () {
      expect('Hello1'.isLatin(), isFalse);
    });

    test('should be false for accented letters', () {
      expect('café'.isLatin(), isFalse);
    });

    test('should be false for empty string', () {
      expect(''.isLatin(), isFalse);
    });
  });

  group('isEquals', () {
    test('should be case-insensitive by default', () {
      expect('Hello'.isEquals('hello'), isTrue);
    });

    test('should be case-sensitive when ignoreCase is false', () {
      expect('Hello'.isEquals('hello', ignoreCase: false), isFalse);
    });

    test('should normalize curly apostrophes by default', () {
      expect("it's".isEquals('it’s'), isTrue);
    });

    test('should not normalize apostrophes when disabled', () {
      expect("it's".isEquals('it’s', normalizeApostrophe: false), isFalse);
    });

    test('should be false when other is null', () {
      expect('Hello'.isEquals(null), isFalse);
    });
  });

  group('containsIgnoreCase', () {
    test('should find a substring ignoring case', () {
      expect('Hello World'.containsIgnoreCase('world'), isTrue);
    });

    test('should be true for empty needle', () {
      expect('Hello'.containsIgnoreCase(''), isTrue);
    });

    test('should be false when not contained', () {
      expect('Hello'.containsIgnoreCase('xyz'), isFalse);
    });

    test('should be false when other is null', () {
      expect('Hello'.containsIgnoreCase(null), isFalse);
    });
  });

  group('getFirstDiffChar', () {
    test('should return the differing char from other', () {
      expect('abc'.getFirstDiffChar('abd'), 'd');
    });

    test('should return the extra char when other is longer', () {
      expect('abc'.getFirstDiffChar('abcd'), 'd');
    });

    test('should return the extra char when this is longer', () {
      expect('abcd'.getFirstDiffChar('abc'), 'd');
    });

    test('should return empty string for identical strings', () {
      expect('abc'.getFirstDiffChar('abc'), '');
    });
  });

  group('hasInvalidUnicode', () {
    test('should be false for normal text', () {
      expect('Hello'.hasInvalidUnicode, isFalse);
    });

    test('should be false for empty string', () {
      expect(''.hasInvalidUnicode, isFalse);
    });
  });

  group('removeInvalidUnicode', () {
    test('should return normal text unchanged', () {
      expect('Hello'.removeInvalidUnicode(), 'Hello');
    });

    test('should return empty string unchanged', () {
      expect(''.removeInvalidUnicode(), '');
    });
  });

  group('isVowel', () {
    test('should be true for a single vowel', () {
      expect('a'.isVowel(), isTrue);
    });

    test('should be true for an uppercase vowel', () {
      expect('E'.isVowel(), isTrue);
    });

    test('should be false for a consonant', () {
      expect('b'.isVowel(), isFalse);
    });

    test('should be false for multi-character input', () {
      expect('ae'.isVowel(), isFalse);
    });

    test('should be false for empty string', () {
      expect(''.isVowel(), isFalse);
    });
  });

  group('hasAnyDigits', () {
    test('should be true when a digit is present', () {
      expect('abc1'.hasAnyDigits(), isTrue);
    });

    test('should be false when no digit present', () {
      expect('abc'.hasAnyDigits(), isFalse);
    });
  });

  group('count', () {
    test('should count non-overlapping occurrences', () {
      expect('hello'.count('l'), 2);
    });

    test('should not double-count overlaps', () {
      expect('aaa'.count('aa'), 1);
    });

    test('should return 0 when absent', () {
      expect('test'.count('x'), 0);
    });

    test('should return 0 for empty needle', () {
      expect('hello'.count(''), 0);
    });
  });

  group('secondIndex', () {
    test('should return index of the second occurrence', () {
      expect('hello'.secondIndex('l'), 3);
    });

    test('should return -1 when only one occurrence', () {
      expect('hello'.secondIndex('h'), -1);
    });

    test('should return -1 when absent', () {
      expect('hello'.secondIndex('z'), -1);
    });

    test('should return -1 for empty char', () {
      expect('hello'.secondIndex(''), -1);
    });
  });

  group('extractCurlyBraces', () {
    test('should extract multiple brace groups including braces', () {
      expect('{start} middle {end}'.extractCurlyBraces(), <String>['{start}', '{end}']);
    });

    test('should extract adjacent groups', () {
      expect('{a}{b}{c}'.extractCurlyBraces(), <String>['{a}', '{b}', '{c}']);
    });

    test('should return null when no braces present', () {
      expect('no braces'.extractCurlyBraces(), isNull);
    });
  });

  group('obscureText', () {
    test('should return null for empty string', () {
      expect(''.obscureText(), isNull);
    });

    test('should return a string of bullets within jitter bounds', () {
      final String? result = 'password'.obscureText();
      expect(result, isNotNull);
      // length 8 +/- obscureLength(3); never below 1.
      expect(result!.length, inInclusiveRange(5, 11));
      expect(result.split('').toSet(), <String>{'•'});
    });

    test('should honor a custom obscure character', () {
      final String? result = 'secret'.obscureText(char: '*');
      expect(result, isNotNull);
      expect(result!.split('').toSet(), <String>{'*'});
    });
  });

  group('endsWithAny', () {
    test('should be true when last char is in the list', () {
      expect('hello!'.endsWithAny(<String>['?', '!']), isTrue);
    });

    test('should be false when last char not in list', () {
      expect('hello'.endsWithAny(<String>['?', '!']), isFalse);
    });

    test('should be false for empty string', () {
      expect(''.endsWithAny(<String>['!']), isFalse);
    });

    test('should be false for empty list', () {
      expect('hi'.endsWithAny(<String>[]), isFalse);
    });
  });

  group('endsWithPunctuation', () {
    test('should be true for a period', () {
      expect('Done.'.endsWithPunctuation(), isTrue);
    });

    test('should be true for a question mark', () {
      expect('Really?'.endsWithPunctuation(), isTrue);
    });

    test('should be false without ending punctuation', () {
      expect('Done'.endsWithPunctuation(), isFalse);
    });
  });

  group('isAny', () {
    test('should be true when string matches a list item', () {
      expect('cat'.isAny(<String>['dog', 'cat']), isTrue);
    });

    test('should be false when no item matches', () {
      expect('cat'.isAny(<String>['dog', 'fish']), isFalse);
    });

    test('should be false for empty string', () {
      expect(''.isAny(<String>['']), isFalse);
    });

    test('should be false for empty list', () {
      expect('cat'.isAny(<String>[]), isFalse);
    });
  });
}
