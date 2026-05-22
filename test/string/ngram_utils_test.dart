import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/ngram_utils.dart';

void main() {
  // cspell: disable
  group('characterNgrams', () {
    test('should produce overlapping bigrams', () {
      expect(characterNgrams('abcd', 2), <String>['ab', 'bc', 'cd']);
    });

    test('should produce trigrams', () {
      expect(characterNgrams('hello', 3), <String>['hel', 'ell', 'llo']);
    });

    test('should return single full string when n equals length', () {
      expect(characterNgrams('abc', 3), <String>['abc']);
    });

    test('should return empty when n greater than length', () {
      expect(characterNgrams('ab', 3), <String>[]);
    });

    test('should return empty for n < 1', () {
      expect(characterNgrams('abc', 0), <String>[]);
      expect(characterNgrams('abc', -1), <String>[]);
    });

    test('should return empty for empty string', () {
      expect(characterNgrams('', 2), <String>[]);
    });

    test('should produce 1-grams of every character', () {
      expect(characterNgrams('cat', 1), <String>['c', 'a', 't']);
    });
  });

  group('wordNgrams', () {
    test('should produce word bigrams', () {
      expect(
        wordNgrams('the quick brown fox', 2),
        <List<String>>[
          ['the', 'quick'],
          ['quick', 'brown'],
          ['brown', 'fox'],
        ],
      );
    });

    test('should produce single 1-grams', () {
      expect(
        wordNgrams('a b c', 1),
        <List<String>>[
          ['a'],
          ['b'],
          ['c'],
        ],
      );
    });

    test('should handle multiple spaces between words', () {
      expect(
        wordNgrams('the   quick', 2),
        <List<String>>[
          ['the', 'quick'],
        ],
      );
    });

    test('should return empty when n greater than word count', () {
      expect(wordNgrams('only two', 3), <List<String>>[]);
    });

    test('should return empty for n < 1', () {
      expect(wordNgrams('a b c', 0), <List<String>>[]);
    });

    test('should return single gram when n equals word count', () {
      expect(
        wordNgrams('one two', 2),
        <List<String>>[
          ['one', 'two'],
        ],
      );
    });
  });
}
