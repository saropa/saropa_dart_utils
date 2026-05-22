import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/damerau_levenshtein_utils.dart';

void main() {
  group('damerauLevenshteinDistance', () {
    test('should return 0 for identical strings', () {
      expect(damerauLevenshteinDistance('', ''), 0);
      expect(damerauLevenshteinDistance('a', 'a'), 0);
      expect(damerauLevenshteinDistance('hello', 'hello'), 0);
    });

    test('should return length of the other when one is empty', () {
      expect(damerauLevenshteinDistance('', 'abc'), 3);
      expect(damerauLevenshteinDistance('abc', ''), 3);
    });

    test('should count a single substitution', () {
      expect(damerauLevenshteinDistance('a', 'b'), 1);
      expect(damerauLevenshteinDistance('cat', 'cot'), 1);
    });

    test('should count a single insertion or deletion', () {
      expect(damerauLevenshteinDistance('abc', 'abcd'), 1);
      expect(damerauLevenshteinDistance('abcd', 'abc'), 1);
    });

    test('should match classic kitten/sitting', () {
      expect(damerauLevenshteinDistance('kitten', 'sitting'), 3);
    });

    test('should compute mixed-edit distance', () {
      // 'ca' -> 'abc': insert 'a' at front and 'b' (or equivalent), no helpful
      // transposition. Verified against the algorithm contract.
      expect(damerauLevenshteinDistance('ca', 'abc'), 3);
    });

    test('should handle unicode characters', () {
      expect(damerauLevenshteinDistance('café', 'cafe'), 1);
      expect(damerauLevenshteinDistance('über', 'uber'), 1);
    });

    test(
      'should treat an adjacent swap as one edit (transposition)',
      () {
        expect(damerauLevenshteinDistance('ab', 'ba'), 1);
      },
    );

    test(
      'should treat ca/ac as one transposition',
      () {
        expect(damerauLevenshteinDistance('ca', 'ac'), 1);
      },
    );

    test(
      'should treat abc/acb as one transposition',
      () {
        expect(damerauLevenshteinDistance('abc', 'acb'), 1);
      },
    );

    test('should be symmetric for substitutions/indels', () {
      expect(
        damerauLevenshteinDistance('flaw', 'lawn'),
        damerauLevenshteinDistance('lawn', 'flaw'),
      );
    });
  });
}
