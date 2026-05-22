import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/text_similarity_utils.dart';

void main() {
  // cspell: disable
  group('termFrequencies', () {
    test('should count repeated tokens', () {
      expect(
        termFrequencies(<String>['a', 'b', 'a']),
        <String, int>{'a': 2, 'b': 1},
      );
    });

    test('should return empty map for empty list', () {
      expect(termFrequencies(<String>[]), <String, int>{});
    });
  });

  group('textToTf', () {
    test('should lowercase and split on non-alphanumerics', () {
      expect(
        textToTf('Cat, cat! Dog.'),
        <String, int>{'cat': 2, 'dog': 1},
      );
    });

    test('should keep digits as tokens', () {
      expect(textToTf('a1 a1 b2'), <String, int>{'a1': 2, 'b2': 1});
    });

    test('should return empty map for whitespace-only input', () {
      expect(textToTf('   '), <String, int>{});
    });
  });

  group('cosineSimilarity', () {
    test('should be ~1.0 for identical maps', () {
      // sqrt rounding makes the result 0.9999999999999998 rather than exactly 1.0.
      const Map<String, int> tf = <String, int>{'a': 2, 'b': 1};
      expect(cosineSimilarity(tf, tf), closeTo(1.0, 1e-9));
    });

    test('should be 0.0 for disjoint maps', () {
      expect(
        cosineSimilarity(<String, int>{'a': 1}, <String, int>{'b': 1}),
        0.0,
      );
    });

    test('should be 0.5 for one shared term out of two each', () {
      expect(
        cosineSimilarity(<String, int>{'cat': 1, 'dog': 1}, <String, int>{'cat': 1, 'fox': 1}),
        closeTo(0.5, 1e-12),
      );
    });

    test('should be 0.0 when either map is empty', () {
      expect(cosineSimilarity(<String, int>{}, <String, int>{'a': 1}), 0.0);
      expect(cosineSimilarity(<String, int>{'a': 1}, <String, int>{}), 0.0);
    });
  });

  group('textSimilarity', () {
    test('should be ~1.0 for identical text', () {
      expect(textSimilarity('hello world', 'hello world'), closeTo(1.0, 1e-9));
    });

    test('should be ~1.0 for word-reordered text (bag of words)', () {
      expect(textSimilarity('hello world', 'world hello'), closeTo(1.0, 1e-9));
    });

    test('should be 0.0 for fully disjoint text', () {
      expect(textSimilarity('cat dog', 'fox owl'), 0.0);
    });

    test('should be 0.5 for half-overlapping text', () {
      expect(textSimilarity('cat dog', 'cat fox'), closeTo(0.5, 1e-12));
    });

    test('should be 0.0 when one side is empty', () {
      expect(textSimilarity('', 'hello'), 0.0);
    });
  });
}
