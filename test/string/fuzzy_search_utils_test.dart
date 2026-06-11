import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/fuzzy_search_utils.dart';

void main() {
  // cspell: disable
  group('FuzzySearchUtils', () {
    test('should expose index, text, and score', () {
      const FuzzySearchUtils m = FuzzySearchUtils(2, 'apple', 0.75);
      expect(m.index, 2);
      expect(m.text, 'apple');
      expect(m.score, 0.75);
    });

    test('toString should render all fields', () {
      expect(
        const FuzzySearchUtils(1, 'cat', 1.0).toString(),
        'FuzzySearchUtils(index: 1, text: cat, score: 1.0)',
      );
    });
  });

  group('fuzzySearch', () {
    test('should rank an exact match top with score 1.0', () {
      final List<FuzzySearchUtils> result = fuzzySearch('apple', <String>['banana', 'apple']);
      expect(result.first.text, 'apple');
      expect(result.first.score, 1.0);
    });

    test('should sort results by descending score', () {
      final List<FuzzySearchUtils> result = fuzzySearch('apple', <String>['apple', 'appl', 'xyz']);
      expect(result.first.text, 'apple');
      // Scores must be non-increasing.
      for (int i = 1; i < result.length; i++) {
        expect(result[i - 1].score >= result[i].score, isTrue);
      }
    });

    test('should tolerate edits within maxDistance', () {
      final List<FuzzySearchUtils> result = fuzzySearch('worls', <String>['world']);
      expect(result.single.text, 'world');
      expect(result.single.score, closeTo(0.8, 1e-9));
    });

    test('should score 0 when no token is within maxDistance', () {
      final List<FuzzySearchUtils> result = fuzzySearch('apple', <String>['xyzzy']);
      expect(result.single.score, 0.0);
    });

    test('should exclude results below minScore', () {
      final List<FuzzySearchUtils> result = fuzzySearch(
        'apple',
        <String>['xyzzy'],
        minScore: 0.5,
      );
      expect(result, isEmpty);
    });

    test('should return all candidates with score 1.0 for empty query', () {
      final List<FuzzySearchUtils> result = fuzzySearch('', <String>['a', 'b']);
      expect(result.map((FuzzySearchUtils m) => m.score), everyElement(1.0));
      expect(result, hasLength(2));
    });

    test('should return empty list for empty candidates', () {
      expect(fuzzySearch('apple', <String>[]), isEmpty);
    });

    test('should preserve the original index of each candidate', () {
      final List<FuzzySearchUtils> result = fuzzySearch('apple', <String>['xyz', 'apple']);
      final FuzzySearchUtils appleMatch = result.firstWhere(
        (FuzzySearchUtils m) => m.text == 'apple',
      );
      expect(appleMatch.index, 1);
    });
  });

  group('partialRatio', () {
    test('scores a substring match as a perfect 1.0', () {
      // The shorter string aligns exactly with a window of the longer one.
      expect(partialRatio('New York', 'New York City'), 1.0);
    });

    test('is case-insensitive', () {
      expect(partialRatio('apple', 'APPLE pie'), 1.0);
    });

    test('two empty strings score 1.0', () {
      expect(partialRatio('', ''), 1.0);
    });

    test('empty against non-empty scores 0.0', () {
      expect(partialRatio('', 'abc'), 0.0);
    });

    test('a poor partial match scores below 1.0', () {
      expect(partialRatio('cat', 'dog house'), lessThan(1.0));
    });
  });

  group('tokenSortRatio', () {
    test('is order-insensitive (full match on reordered words)', () {
      expect(tokenSortRatio('York New', 'New York'), 1.0);
    });

    test('is case-insensitive', () {
      expect(tokenSortRatio('New York', 'new york'), 1.0);
    });

    test('collapses runs of whitespace between tokens', () {
      expect(tokenSortRatio('a   b', 'b a'), 1.0);
    });
  });

  group('tokenSetRatio', () {
    test('a token superset scores a perfect 1.0 on the shared core', () {
      expect(tokenSetRatio('apple pie', 'apple pie with cinnamon'), 1.0);
    });

    test('identical token sets score 1.0 regardless of order', () {
      expect(tokenSetRatio('red blue green', 'green red blue'), 1.0);
    });

    test('is case-insensitive', () {
      expect(tokenSetRatio('Apple Pie', 'apple pie'), 1.0);
    });

    test('disjoint token sets score below 1.0', () {
      expect(tokenSetRatio('cat dog', 'fish bird'), lessThan(1.0));
    });
  });
}
