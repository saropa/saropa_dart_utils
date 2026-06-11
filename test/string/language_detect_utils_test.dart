import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/language_detect_utils.dart';

void main() {
  // cspell: disable
  group('LanguageGuess', () {
    test('should expose confidence as the inverse of score', () {
      const guess = LanguageGuess('en', 0.25);
      expect(guess.confidence, closeTo(0.75, 1e-9));
    });

    test('should be value-equal for the same code and score', () {
      expect(const LanguageGuess('fr', 0.1), const LanguageGuess('fr', 0.1));
    });

    test('should differ when code or score differs', () {
      expect(const LanguageGuess('fr', 0.1), isNot(const LanguageGuess('de', 0.1)));
      expect(const LanguageGuess('fr', 0.1), isNot(const LanguageGuess('fr', 0.2)));
    });

    test('should render a readable toString', () {
      expect(const LanguageGuess('it', 0.3).toString(), 'LanguageGuess(it, 0.3)');
    });
  });

  group('languageTrigrams', () {
    test('should return empty for text shorter than three characters', () {
      expect(languageTrigrams('hi'), isEmpty);
    });

    test('should return empty for empty text', () {
      expect(languageTrigrams(''), isEmpty);
    });

    test('should rank the most frequent trigram first', () {
      // 'aaaa' has only the 'aaa' window, repeated, so it must lead the ranking.
      expect(languageTrigrams('aaaa').first, 'aaa');
    });

    test('should treat whitespace runs as a single space and lowercase', () {
      // Collapsed and lowercased, 'The   The' yields the same grams as 'the the'.
      expect(languageTrigrams('The   The'), languageTrigrams('the the'));
    });

    test('should keep spaces as significant trigram characters', () {
      expect(languageTrigrams('a b c'), contains('a b'));
    });

    test('should handle Unicode and emoji without throwing', () {
      expect(() => languageTrigrams('héllo 世界 👋 héllo'), returnsNormally);
    });
  });

  group('detectLanguage', () {
    test('should return null for text too short to decide', () {
      expect(detectLanguage('hi'), isNull);
    });

    test('should return null for empty text', () {
      expect(detectLanguage(''), isNull);
    });

    test('should detect English for an English sentence', () {
      final guess = detectLanguage('the quick brown fox and the lazy dog in the sun');
      expect(guess?.language, 'en');
    });

    test('should detect Spanish for a Spanish sentence', () {
      final guess = detectLanguage('el problema de la nacion es la relacion con la poblacion');
      expect(guess?.language, 'es');
    });

    test('should detect German for a German sentence', () {
      final guess = detectLanguage('der hund und die katze sind in dem haus und schlafen');
      expect(guess?.language, 'de');
    });

    test('should produce a score within the normalized range', () {
      final guess = detectLanguage('the quick brown fox');
      expect(guess, isNotNull);
      expect(guess!.score, inInclusiveRange(0.0, 1.0));
    });

    test('should be deterministic for the same input', () {
      expect(
        detectLanguage('the quick brown fox'),
        detectLanguage('the quick brown fox'),
      );
    });

    test('should never throw on Unicode-heavy input', () {
      expect(() => detectLanguage('世界 héllo 👋 mundo'), returnsNormally);
    });
  });
}
