import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/tokenize_sentences_utils.dart';

void main() {
  // cspell: disable
  group('tokenizeSentences', () {
    test('should split on period followed by space', () {
      expect(
        tokenizeSentences('Hello world. How are you.'),
        <String>['Hello world.', 'How are you.'],
      );
    });

    test('should split on question and exclamation marks', () {
      expect(
        tokenizeSentences('Really? Yes! Sure.'),
        <String>['Really?', 'Yes!', 'Sure.'],
      );
    });

    test('should keep a single sentence intact', () {
      expect(tokenizeSentences('No terminal punctuation here'), <String>[
        'No terminal punctuation here',
      ]);
    });

    test('should trim whitespace around sentences', () {
      expect(
        tokenizeSentences('One.   Two.'),
        <String>['One.', 'Two.'],
      );
    });

    test('should return empty list for empty input', () {
      expect(tokenizeSentences(''), <String>[]);
    });

    test('should return empty list for whitespace-only input', () {
      expect(tokenizeSentences('   '), <String>[]);
    });
  });

  group('tokenizeWords', () {
    test('should split on whitespace and strip punctuation', () {
      expect(
        tokenizeWords('Hello, world! 123'),
        <String>['Hello', 'world', '123'],
      );
    });

    test('should collapse multiple spaces', () {
      expect(tokenizeWords('a    b'), <String>['a', 'b']);
    });

    test('should drop tokens that are purely punctuation', () {
      expect(tokenizeWords('hello --- world'), <String>['hello', 'world']);
    });

    test('should keep underscores (word characters)', () {
      expect(tokenizeWords('foo_bar baz'), <String>['foo_bar', 'baz']);
    });

    test('should return empty list for empty input', () {
      expect(tokenizeWords(''), <String>[]);
    });
  });
}
