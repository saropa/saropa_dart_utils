import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/lcs_substring_utils.dart';

void main() {
  group('longestCommonSubstringLength', () {
    test('should find the longest shared contiguous run length', () {
      expect(longestCommonSubstringLength('abcdef', 'zcdemf'), 3); // 'cde'
    });

    test('should return 0 when no characters are shared', () {
      expect(longestCommonSubstringLength('abc', 'xyz'), 0);
    });

    test('should return 0 when either string is empty', () {
      expect(longestCommonSubstringLength('', 'abc'), 0);
      expect(longestCommonSubstringLength('abc', ''), 0);
      expect(longestCommonSubstringLength('', ''), 0);
    });

    test('should return full length for identical strings', () {
      expect(longestCommonSubstringLength('hello', 'hello'), 5);
    });

    test('should count a single shared character', () {
      expect(longestCommonSubstringLength('abc', 'xbz'), 1);
    });

    test('should require contiguity (substring not subsequence)', () {
      // 'a_c' shares a and c but not contiguously; longest run is 1.
      expect(longestCommonSubstringLength('axc', 'ayc'), 1);
    });
  });

  group('longestCommonSubstring', () {
    test('should return the longest shared substring', () {
      expect(longestCommonSubstring('abcdef', 'zcdemf'), 'cde');
    });

    test('should return empty string when nothing is shared', () {
      expect(longestCommonSubstring('abcde', 'xyz'), '');
    });

    test('should return empty string when either input is empty', () {
      expect(longestCommonSubstring('', 'abc'), '');
      expect(longestCommonSubstring('abc', ''), '');
    });

    test('should return the whole string for identical inputs', () {
      expect(longestCommonSubstring('hello', 'hello'), 'hello');
    });

    test('should find a substring at the start', () {
      expect(longestCommonSubstring('abcxyz', 'abcq'), 'abc');
    });

    test('should find a substring at the end', () {
      expect(longestCommonSubstring('xyzend', 'qqend'), 'end');
    });
  });
}
