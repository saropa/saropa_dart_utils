import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/keyphrase_utils.dart';

void main() {
  // cspell: disable
  group('tokenizeKeyphrases', () {
    test('should lowercase and split on non-alphanumerics', () {
      expect(tokenizeKeyphrases('Quick, Brown-Fox!'), ['quick', 'brown', 'fox']);
    });

    test('should drop stopwords and one-character tokens', () {
      expect(tokenizeKeyphrases('the cat a x dog'), ['cat', 'dog']);
    });

    test('should return empty list for empty text', () {
      expect(tokenizeKeyphrases(''), <String>[]);
    });

    test('should return empty list for stopwords-only text', () {
      expect(tokenizeKeyphrases('the and of to'), <String>[]);
    });

    test('should keep digit tokens longer than one character', () {
      expect(tokenizeKeyphrases('year 2026 was 7'), ['year', '2026']);
    });

    test('should split on accented letters and emoji as non-ascii runs', () {
      // The ascii-only regex treats every non-[a-z0-9] char (accents, dashes,
      // emoji) as a separator, so 'café' splits to 'caf' and 'résumé' to 'sum'.
      expect(tokenizeKeyphrases('café — résumé 👋 data'), ['caf', 'sum', 'data']);
    });
  });

  group('termFrequencies', () {
    test('should count repeated terms', () {
      expect(termFrequencies(['cat', 'cat', 'dog']), {'cat': 2, 'dog': 1});
    });

    test('should return empty map for empty input', () {
      expect(termFrequencies(<String>[]), <String, int>{});
    });

    test('should count a single term as one', () {
      expect(termFrequencies(['solo']), {'solo': 1});
    });
  });

  group('computeIdf', () {
    test('should use smoothed idf so single-doc corpus stays positive', () {
      // ln(1 + 1/1) = ln 2, no division by zero for a one-document corpus.
      final idf = computeIdf([
        ['cat', 'dog'],
      ]);
      expect(idf['cat'], closeTo(math.log(2), 1e-12));
    });

    test('should give rarer terms higher idf than common ones', () {
      final idf = computeIdf([
        ['cat', 'rare'],
        ['cat'],
        ['cat'],
      ]);
      expect(idf['rare']! > idf['cat']!, isTrue);
    });

    test('should return empty map for empty corpus', () {
      expect(computeIdf(<List<String>>[]), <String, double>{});
    });

    test('should count a term once per document, not per occurrence', () {
      // 'cat' appears twice in one doc but df is 1, so idf = ln(1 + 1/1).
      final idf = computeIdf([
        ['cat', 'cat'],
      ]);
      expect(idf['cat'], closeTo(math.log(2), 1e-12));
    });
  });

  group('extractKeyphrases', () {
    test('should return empty list for empty document', () {
      expect(extractKeyphrases('', <List<String>>[]), <Keyphrase>[]);
    });

    test('should rank the most frequent term first in single-doc mode', () {
      final result = extractKeyphrases('cat cat cat dog', <List<String>>[]);
      expect(result.first.phrase, 'cat');
    });

    test('should respect topK cap', () {
      final result = extractKeyphrases(
        'alpha beta gamma delta epsilon',
        <List<String>>[],
        const KeyphraseOptions(topK: 2),
      );
      expect(result, hasLength(2));
    });

    test('should break ties alphabetically for equal scores', () {
      // Each term appears once with identical idf, so scores tie; phrase order
      // must be deterministic and ascending.
      final result = extractKeyphrases('delta charlie bravo', <List<String>>[]);
      expect(result.map((k) => k.phrase).toList(), ['bravo', 'charlie', 'delta']);
    });

    test('should weight rare corpus terms above common ones', () {
      // 'cat' is common across the corpus (low idf); 'unicorn' is rare (high
      // idf), so it should outrank cat despite equal term frequency.
      final corpus = [
        ['cat', 'dog'],
        ['cat', 'fish'],
        ['cat', 'bird'],
      ];
      final result = extractKeyphrases('cat unicorn', corpus);
      expect(result.first.phrase, 'unicorn');
    });

    test('should include bigrams when enabled', () {
      final result = extractKeyphrases(
        'machine learning machine learning',
        <List<String>>[],
        const KeyphraseOptions(includeBigrams: true, topK: 10),
      );
      expect(result.any((k) => k.phrase == 'machine learning'), isTrue);
    });

    test('should not include bigrams by default', () {
      final result = extractKeyphrases('machine learning', <List<String>>[]);
      expect(result.every((k) => !k.phrase.contains(' ')), isTrue);
    });

    test('should return empty list when topK is zero or negative', () {
      final result = extractKeyphrases(
        'cat dog',
        <List<String>>[],
        const KeyphraseOptions(topK: 0),
      );
      expect(result, <Keyphrase>[]);
    });

    test('should ignore stopwords in the document', () {
      final result = extractKeyphrases('the cat and the dog', <List<String>>[]);
      expect(result.every((k) => k.phrase != 'the' && k.phrase != 'and'), isTrue);
    });

    test('should produce positive scores for matched terms', () {
      final result = extractKeyphrases('keyphrase', <List<String>>[]);
      expect(result.first.score > 0, isTrue);
    });
  });
}
