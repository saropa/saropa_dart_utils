import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/levenshtein_utils.dart';

void main() {
  group('LevenshteinUtils.distance', () {
    test('identical strings', () {
      expect(LevenshteinUtils.distance('', ''), 0);
      expect(LevenshteinUtils.distance('a', 'a'), 0);
      expect(LevenshteinUtils.distance('kitten', 'kitten'), 0);
    });
    test('one empty', () {
      expect(LevenshteinUtils.distance('', 'abc'), 3);
      expect(LevenshteinUtils.distance('abc', ''), 3);
    });
    test('classic kitten/sitting', () {
      expect(LevenshteinUtils.distance('kitten', 'sitting'), 3);
    });
    test('single char diff', () {
      expect(LevenshteinUtils.distance('a', 'b'), 1);
      expect(LevenshteinUtils.distance('ab', 'ac'), 1);
    });
    test('insertion and deletion', () {
      expect(LevenshteinUtils.distance('abc', 'abcd'), 1);
      expect(LevenshteinUtils.distance('abcd', 'abc'), 1);
    });
    test('unicode', () {
      expect(LevenshteinUtils.distance('café', 'cafe'), 1);
      expect(LevenshteinUtils.distance('👋', '👋'), 0);
    });
  });

  group('LevenshteinUtils.ratio', () {
    test('identical', () {
      expect(LevenshteinUtils.ratio('', ''), 1.0);
      expect(LevenshteinUtils.ratio('abc', 'abc'), 1.0);
    });
    test('one empty', () {
      expect(LevenshteinUtils.ratio('', 'abc'), 0.0);
      expect(LevenshteinUtils.ratio('abc', ''), 0.0);
    });
    test('kitten/sitting', () {
      final double r = LevenshteinUtils.ratio('kitten', 'sitting');
      expect(r, closeTo(0.57, 0.01));
    });
    test('no overlap', () {
      expect(LevenshteinUtils.ratio('abc', 'xyz'), 0.0);
    });
  });

  group('LevenshteinUtils.fuzzyContains', () {
    test('exact substring', () {
      expect(LevenshteinUtils.fuzzyContains('hello world', 'world', 0), isTrue);
    });
    test('one edit', () {
      expect(LevenshteinUtils.fuzzyContains('hello world', 'worls', 1), isTrue);
    });
    test('no match', () {
      expect(LevenshteinUtils.fuzzyContains('hello', 'xyz', 2), isFalse);
    });
    test('empty target', () {
      expect(LevenshteinUtils.fuzzyContains('abc', '', 0), isTrue);
    });
    test('target longer than source', () {
      expect(LevenshteinUtils.fuzzyContains('ab', 'abcd', 2), isFalse);
    });
    test('maxDistance negative throws', () {
      expect(
        () => LevenshteinUtils.fuzzyContains('a', 'b', -1),
        throwsArgumentError,
      );
    });
  });
}
