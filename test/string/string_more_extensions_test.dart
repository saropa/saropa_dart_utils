import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_more_extensions.dart';

void main() {
  // cspell: disable
  group('stripSubstring', () {
    test('should remove leading and trailing occurrences', () {
      expect('xxabcxx'.stripSubstring('x'), 'abc');
    });

    test('should remove repeated multi-char prefixes/suffixes', () {
      expect('ababcoreabab'.stripSubstring('ab'), 'core');
    });

    test('should return this for empty substring', () {
      expect('abc'.stripSubstring(''), 'abc');
    });
  });

  group('joinLines', () {
    test('should join lines with a custom separator', () {
      expect('a\nb\nc'.joinLines(', '), 'a, b, c');
    });

    test('should default to newline (no-op)', () {
      expect('a\nb'.joinLines(), 'a\nb');
    });
  });

  group('wrapAtChars', () {
    test('should wrap into width-sized lines', () {
      expect('abcdefgh'.wrapAtChars(3), 'abc\ndef\ngh');
    });

    test('should return this when shorter than width', () {
      expect('ab'.wrapAtChars(5), 'ab');
    });

    test('should return this when width < 1', () {
      expect('abc'.wrapAtChars(0), 'abc');
    });

    test('should be grapheme-safe for emoji', () {
      expect('👋👋👋👋'.wrapAtChars(2), '👋👋\n👋👋');
    });
  });

  group('capitalizeSentences', () {
    test('should capitalize the first letter', () {
      expect('hello world'.capitalizeSentences(), 'Hello world');
    });

    test('should capitalize after a sentence boundary', () {
      expect('hello. world'.capitalizeSentences(), 'Hello. World');
    });

    test('should return this for empty string', () {
      expect(''.capitalizeSentences(), '');
    });
  });

  group('swapCase', () {
    test('should swap upper and lower case', () {
      expect('Hello'.swapCase(), 'hELLO');
    });

    test('should leave digits unchanged', () {
      expect('aB3'.swapCase(), 'Ab3');
    });
  });

  group('removeRepeatedChars', () {
    test('should collapse runs of the same character', () {
      expect('aaabbbccaa'.removeRepeatedChars(), 'abca');
    });

    test('should return this for length <= 1', () {
      expect('a'.removeRepeatedChars(), 'a');
      expect(''.removeRepeatedChars(), '');
    });
  });

  group('countOccurrences', () {
    test('should count non-overlapping occurrences', () {
      expect('aaaa'.countOccurrences('aa'), 2);
    });

    test('should return 0 when absent', () {
      expect('abc'.countOccurrences('z'), 0);
    });

    test('should return 0 for empty substring', () {
      expect('abc'.countOccurrences(''), 0);
    });
  });

  group('allIndicesOf', () {
    test('should return all non-overlapping start indices', () {
      expect('aXbXc'.allIndicesOf('X'), <int>[1, 3]);
    });

    test('should return empty list when absent', () {
      expect('abc'.allIndicesOf('z'), <int>[]);
    });

    test('should return empty list for empty substring', () {
      expect('abc'.allIndicesOf(''), <int>[]);
    });
  });

  group('isPalindrome', () {
    test('should be true for a simple palindrome', () {
      expect('racecar'.isPalindrome(), isTrue);
    });

    test('should ignore case by default', () {
      expect('RaceCar'.isPalindrome(), isTrue);
    });

    test('should respect case when ignoreCase is false', () {
      expect('RaceCar'.isPalindrome(ignoreCase: false), isFalse);
    });

    test('should ignore punctuation when requested', () {
      expect('A man, a plan, a canal: Panama'.isPalindrome(ignorePunctuation: true), isTrue);
    });

    test('should be false for a non-palindrome', () {
      expect('hello'.isPalindrome(), isFalse);
    });
  });

  group('reverseWords', () {
    test('should reverse word order', () {
      expect('the quick brown'.reverseWords(), 'brown quick the');
    });

    test('should collapse whitespace runs', () {
      expect('a   b'.reverseWords(), 'b a');
    });
  });

  group('firstNWords', () {
    test('should return the first n words', () {
      expect('the quick brown fox'.firstNWords(2), 'the quick');
    });

    test('should return empty for n <= 0', () {
      expect('a b c'.firstNWords(0), '');
    });

    test('should return all words when n exceeds count', () {
      expect('a b'.firstNWords(5), 'a b');
    });
  });

  group('lastNWords', () {
    test('should return the last n words preserving order', () {
      expect('the quick brown fox'.lastNWords(2), 'brown fox');
    });

    test('should return empty for n <= 0', () {
      expect('a b c'.lastNWords(0), '');
    });

    test('should return all words when n exceeds count', () {
      expect('a b'.lastNWords(5), 'a b');
    });
  });

  group('padToWidth', () {
    test('should pad on the left by default', () {
      expect('5'.padToWidth(3, padChar: '0'), '005');
    });

    test('should pad on the right when padLeft is false', () {
      expect('5'.padToWidth(3, padLeft: false, padChar: '0'), '500');
    });

    test('should return this when already wide enough', () {
      expect('hello'.padToWidth(3), 'hello');
    });
  });

  group('stripHtmlComments', () {
    test('should remove an HTML comment', () {
      expect('a<!-- note -->b'.stripHtmlComments(), 'ab');
    });

    test('should remove a multi-line comment', () {
      expect('a<!--\nx\n-->b'.stripHtmlComments(), 'ab');
    });

    test('should leave text without comments unchanged', () {
      expect('plain'.stripHtmlComments(), 'plain');
    });
  });
}
