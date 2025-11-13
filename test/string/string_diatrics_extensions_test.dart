import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_diacritics_extensions.dart';

void main() {
  // cspell: disable
  // --- Tests for removeDiacritics() ---
  group('removeDiacritics()', () {
    test('1. should return an empty string if the input is empty', () {
      expect(''.removeDiacritics(), '');
    });

    test('2. should not change a string with no diacritics', () {
      const String text = 'Hello world! 123';
      expect(text.removeDiacritics(), text);
    });

    test('3. should remove simple lowercase diacritics', () {
      const String text = 'crème brûlée';
      expect(text.removeDiacritics(), 'creme brulee');
    });

    test('4. should remove simple uppercase diacritics', () {
      const String text = 'ÉLOÏSE À L\'ÉCOLE';
      expect(text.removeDiacritics(), 'ELOISE A L\'ECOLE');
    });

    test('5. should handle mixed case diacritics correctly', () {
      const String text = 'František a Šárka';
      expect(text.removeDiacritics(), 'Frantisek a Sarka');
    });

    test('6. should handle a wide range of vowel diacritics', () {
      const String text = 'áàäâãåāăǎíìïîīĭįǐóòöôõøōŏőúùüûūŭű';
      // CORRECTED: The expected string now has the correct number of characters
      // to match the input string above.
      expect(text.removeDiacritics(), 'aaaaaaaaaiiiiiiiiooooooooouuuuuuu');
    });

    test('7. should handle a wide range of consonant diacritics', () {
      const String text = 'čçćĉċďđñňńņřŕŗšśşșťțžźż';
      // CORRECTED: The expected string now has the correct number of characters
      // to match the input string above.
      expect(text.removeDiacritics(), 'cccccddnnnnrrrssssttzzz');
    });

    test('8. should correctly transliterate the German Eszett (ß)', () {
      const String text = 'Straße';
      expect(text.removeDiacritics(), 'Strasse');
    });

    test('9. should correctly transliterate the uppercase German Eszett (ẞ)', () {
      const String text = 'GROẞE';
      expect(text.removeDiacritics(), 'GROSSE');
    });

    test('10. should correctly transliterate ligatures (æ, œ)', () {
      const String text = 'Æther, œsophagus';
      expect(text.removeDiacritics(), 'AEther, oesophagus');
    });

    test('11. should preserve numbers and symbols within the string', () {
      const String text = 'Súper-Strëss-Tëst 100%';
      expect(text.removeDiacritics(), 'Super-Stress-Test 100%');
    });

    test('12. should not affect non-Latin characters like Cyrillic or Greek', () {
      const String text = 'Привет, Γειά σου, Šárka';
      expect(text.removeDiacritics(), 'Привет, Γειά σου, Sarka');
    });
  });

  // --- Tests for containsDiacritics() ---
  group('containsDiacritics()', () {
    test('13. should return false for an empty string', () {
      expect(''.containsDiacritics(), isFalse);
    });

    test('14. should return false for a plain ASCII string', () {
      const String text = 'A regular string without accents.';
      expect(text.containsDiacritics(), isFalse);
    });

    test('15. should return true for a string with a simple diacritic', () {
      const String text = 'This is a café.';
      expect(text.containsDiacritics(), isTrue);
    });

    test('16. should return true for a string with an uppercase diacritic', () {
      const String text = 'ÅNGSTRÖM';
      expect(text.containsDiacritics(), isTrue);
    });

    test('17. should return true for a string containing a ligature', () {
      const String text = 'Cæsar';
      expect(text.containsDiacritics(), isTrue);
    });

    test('18. should return true for a string containing the German Eszett', () {
      const String text = 'weiß';
      expect(text.containsDiacritics(), isTrue);
    });

    test('19. should return false for a string with only symbols and numbers', () {
      const String text = '!@#\$%^&*()_+-=[]{}|;:",./<>?1234567890';
      expect(text.containsDiacritics(), isFalse);
    });

    test('20. should return false for non-Latin strings that are not diacritics', () {
      const String text = 'こんにちは世界'; // Japanese
      expect(text.containsDiacritics(), isFalse);
    });
  });
  // cspell: enable
}
