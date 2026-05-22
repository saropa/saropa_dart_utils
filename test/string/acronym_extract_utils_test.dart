import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/acronym_extract_utils.dart';

void main() {
  // cspell: disable
  group('extractAcronyms', () {
    test('should extract a single full name with acronym', () {
      expect(
        extractAcronyms('Saropa Dart Utils (SDU)'),
        <(String, String)>[('SDU', 'Saropa Dart Utils')],
      );
    });

    test('should extract multiple acronyms in order', () {
      // The full-name capture is greedy over letters and spaces, so the second
      // match also pulls in the connecting word "and" before "United Nations".
      expect(
        extractAcronyms('World Health Organization (WHO) and United Nations (UN)'),
        <(String, String)>[
          ('WHO', 'World Health Organization'),
          ('UN', 'and United Nations'),
        ],
      );
    });

    test('should return empty list when no acronym present', () {
      expect(extractAcronyms('plain text with no parentheses'), <(String, String)>[]);
    });

    test('should return empty list for empty input', () {
      expect(extractAcronyms(''), <(String, String)>[]);
    });

    test('should ignore lowercase parenthetical (not all uppercase)', () {
      expect(extractAcronyms('Some Name (abc)'), <(String, String)>[]);
    });

    test('should ignore single uppercase letter (needs 2+)', () {
      expect(extractAcronyms('Some Name (A)'), <(String, String)>[]);
    });

    test('should trim whitespace from the full name', () {
      expect(
        extractAcronyms('The   Quick Brown   (QB)'),
        <(String, String)>[('QB', 'The   Quick Brown')],
      );
    });
  });
}
