import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_character_extensions.dart';

// cspell: disable
void main() {
  group('substringCharacter', () {
    test('1. Basic substring', () => expect('hello'.substringCharacter(1, 4), 'ell'));
    test('2. From start', () => expect('hello'.substringCharacter(0, 3), 'hel'));
    test('3. To end', () => expect('hello'.substringCharacter(2), 'llo'));
    test('4. Empty string', () => expect(''.substringCharacter(0, 1), ''));
    test('5. Unicode characters', () => expect('你好世界'.substringCharacter(1, 3), '好世'));
    test('6. Emoji string', () => expect('🚀👍🎉'.substringCharacter(0, 2), '🚀👍'));
    test('7. Single character', () => expect('hello'.substringCharacter(2, 3), 'l'));
    test('8. Full string', () => expect('abc'.substringCharacter(0, 3), 'abc'));
    test('9. Negative start', () => expect('hello'.substringCharacter(-1, 2), ''));
    test('10. Start beyond length', () => expect('hello'.substringCharacter(10, 15), ''));
    test('11. End before start', () => expect('hello'.substringCharacter(3, 1), ''));
    test('12. Start equals end', () => expect('hello'.substringCharacter(2, 2), ''));
    test('13. End beyond length', () => expect('hello'.substringCharacter(2, 100), ''));
    test('14. Mixed content', () => expect('ab你cd好'.substringCharacter(2, 5), '你cd'));
    test('15. Single Unicode char', () => expect('你好'.substringCharacter(0, 1), '你'));
  });

  group('firstCharacter', () {
    test('1. Basic string', () => expect('hello'.firstCharacter(), 'h'));
    test('2. Empty string', () => expect(''.firstCharacter(), ''));
    test('3. Single character', () => expect('a'.firstCharacter(), 'a'));
    test('4. Unicode string', () => expect('你好'.firstCharacter(), '你'));
    test('5. Emoji', () => expect('🚀test'.firstCharacter(), '🚀'));
    test('6. With leading space and trim', () => expect('  hello'.firstCharacter(), 'h'));
    test('7. With leading space no trim', () => expect('  hello'.firstCharacter(trim: false), ' '));
    test('8. Only whitespace with trim', () => expect('   '.firstCharacter(), ''));
    test('9. Only whitespace no trim', () => expect('   '.firstCharacter(trim: false), ' '));
    test('10. Number first', () => expect('123abc'.firstCharacter(), '1'));
    test('11. Symbol first', () => expect('@test'.firstCharacter(), '@'));
    test('12. Tab character no trim', () => expect('\thello'.firstCharacter(trim: false), '\t'));
    test('13. Newline first no trim', () => expect('\nhello'.firstCharacter(trim: false), '\n'));
    test(
      '14. Without grapheme support',
      () => expect('hello'.firstCharacter(supportGraphemes: false), 'h'),
    );
    test(
      '15. Unicode without grapheme',
      () => expect('你好'.firstCharacter(supportGraphemes: false), '你'),
    );
  });

  group('secondCharacter', () {
    test('1. Basic string', () => expect('hello'.secondCharacter(), 'e'));
    test('2. Empty string', () => expect(''.secondCharacter(), ''));
    test('3. Single character', () => expect('a'.secondCharacter(), ''));
    test('4. Unicode string', () => expect('你好'.secondCharacter(), '好'));
    test('5. Emoji string', () => expect('🚀👍test'.secondCharacter(), '👍'));
    test('6. With leading space and trim', () => expect('  hello'.secondCharacter(), 'e'));
    test(
      '7. With leading space no trim',
      () => expect('  hello'.secondCharacter(trim: false), ' '),
    );
    test('8. Only whitespace with trim', () => expect('   '.secondCharacter(), ''));
    test('9. Only whitespace no trim', () => expect('   '.secondCharacter(trim: false), ' '));
    test('10. Two characters', () => expect('ab'.secondCharacter(), 'b'));
    test('11. Number second', () => expect('a1bc'.secondCharacter(), '1'));
    test('12. Symbol second', () => expect('a@bc'.secondCharacter(), '@'));
    test('13. Tab as second no trim', () => expect('a\tb'.secondCharacter(trim: false), '\t'));
    test(
      '14. Without grapheme support',
      () => expect('hello'.secondCharacter(supportGraphemes: false), 'e'),
    );
    test(
      '15. Unicode without grapheme',
      () => expect('你好世'.secondCharacter(supportGraphemes: false), '好'),
    );
  });

  group('graphemeLength', () {
    test('1. Basic ASCII string', () => expect('hello'.graphemeLength, 5));
    test('2. Empty string', () => expect(''.graphemeLength, 0));
    test('3. Single character', () => expect('a'.graphemeLength, 1));
    test('4. Unicode string', () => expect('你好'.graphemeLength, 2));
    test('5. Emoji string', () => expect('🚀👍'.graphemeLength, 2));
    test('6. Mixed content', () => expect('a你🚀'.graphemeLength, 3));
    test('7. Whitespace', () => expect('   '.graphemeLength, 3));
    test('8. Numbers', () => expect('12345'.graphemeLength, 5));
    test('9. Symbols', () => expect('!@#'.graphemeLength, 3));
    test('10. Newlines', () => expect('a\nb'.graphemeLength, 3));
    test('11. Tabs', () => expect('a\tb'.graphemeLength, 3));
    test('12. Long string', () => expect('abcdefghij'.graphemeLength, 10));
    test('13. Single emoji', () => expect('🎉'.graphemeLength, 1));
    test('14. Multiple Unicode', () => expect('你好世界'.graphemeLength, 4));
    test('15. Accented characters', () => expect('café'.graphemeLength, 4));
  });

  // --- Reusable Test Data ---
  const String sEmpty = '';
  const String sWhitespace = '   ';
  const String sAscii1 = 'A';
  const String sAsciiMulti = 'Apple';
  const String sLeadSpaceAscii = '  Banana';

  const String sCjk1 = '相';
  const String sCjkMulti = '相浦由莉絵';

  const String emojiSimple = '👍';
  const String emojiSimpleText = '${emojiSimple}great';

  const String emojiHeartBase = '❤';
  const String emojiHeartWithVS = '❤️';
  const String emojiHeartVSText = '${emojiHeartWithVS}love';

  const String emojiFamily = '👨‍👩‍👧‍👦';
  const String emojiFamilyText = '${emojiFamily}time';

  const String emojiThumbsUpSkin = '👍🏽';
  const String emojiThumbsUpSkinText = '${emojiThumbsUpSkin}ok';

  const String sMixed = 'A❤️B👍🏽C👨‍👩‍👧‍👦D';

  // --- Original simple tests for firstCharacter ---
  group('.firstCharacter() original simple tests', () {
    test('Basic functionality and trimming', () {
      expect('Alex'.firstCharacter(), 'A');
      expect('Alex '.firstCharacter(), 'A');
      expect(' Alex '.firstCharacter(), 'A');
      expect(' Alex '.firstCharacter(trim: false), ' ');
      expect('Alex Bright'.firstCharacter(), 'A');
      expect('  Alex   Bright '.firstCharacter(trim: false), ' ');
      expect('😎✈'.firstCharacter(), '😎');
    });
    test('Empty and whitespace only strings', () {
      expect(''.firstCharacter(), '');
      expect(' '.firstCharacter(), '');
    });
  });

  group('String.firstCharacter() detailed', () {
    group('[supportGraphemes = true]', () {
      String getChar(String s, {bool trim = true}) =>
          s.firstCharacter(supportGraphemes: true, trim: trim);

      test('empty string -> ""', () => expect(getChar(sEmpty), equals('')));
      test(
        'whitespace only (trimmed) -> ""',
        () => expect(getChar(sWhitespace, trim: true), equals('')),
      );
      test(
        'whitespace only (not trimmed) -> " "',
        () => expect(getChar(sWhitespace, trim: false), equals(' ')),
      );
      test('"$sAsciiMulti" -> "A"', () => expect(getChar(sAsciiMulti), equals('A')));
      test(
        '"$sLeadSpaceAscii" (trimmed) -> "B"',
        () => expect(getChar(sLeadSpaceAscii, trim: true), equals('B')),
      );
      test(
        '"$sLeadSpaceAscii" (not trimmed) -> " "',
        () => expect(getChar(sLeadSpaceAscii, trim: false), equals(' ')),
      );
      test('"$sCjkMulti" -> "$sCjk1"', () => expect(getChar(sCjkMulti), equals(sCjk1)));
      test(
        '"$emojiSimpleText" -> "$emojiSimple"',
        () => expect(getChar(emojiSimpleText), equals(emojiSimple)),
      );
      test(
        '"$emojiHeartVSText" -> "$emojiHeartWithVS"',
        () => expect(getChar(emojiHeartVSText), equals(emojiHeartWithVS)),
      );
      test(
        '"$emojiFamilyText" -> "$emojiFamily"',
        () => expect(getChar(emojiFamilyText), equals(emojiFamily)),
      );
      test(
        '"$emojiThumbsUpSkinText" -> "$emojiThumbsUpSkin"',
        () => expect(getChar(emojiThumbsUpSkinText), equals(emojiThumbsUpSkin)),
      );
    });

    group('[supportGraphemes = false]', () {
      String getChar(String s, {bool trim = true}) =>
          s.firstCharacter(supportGraphemes: false, trim: trim);

      test('empty string -> ""', () => expect(getChar(sEmpty), equals('')));
      test(
        'whitespace only (trimmed) -> ""',
        () => expect(getChar(sWhitespace, trim: true), equals('')),
      );
      test(
        'whitespace only (not trimmed) -> " "',
        () => expect(getChar(sWhitespace, trim: false), equals(' ')),
      );
      test('"$sAsciiMulti" -> "A"', () => expect(getChar(sAsciiMulti), equals('A')));
      test(
        '"$sLeadSpaceAscii" (trimmed) -> "B"',
        () => expect(getChar(sLeadSpaceAscii, trim: true), equals('B')),
      );
      test(
        '"$sLeadSpaceAscii" (not trimmed) -> " "',
        () => expect(getChar(sLeadSpaceAscii, trim: false), equals(' ')),
      );
      test('"$sCjkMulti" -> "$sCjk1"', () => expect(getChar(sCjkMulti), equals(sCjk1)));
      test(
        '"$emojiSimpleText" -> "$emojiSimple"',
        () => expect(getChar(emojiSimpleText), equals(emojiSimple)),
      );
      test(
        '"$emojiHeartVSText" -> "$emojiHeartBase"',
        () => expect(getChar(emojiHeartVSText), equals(emojiHeartBase)),
      );
      test('"$emojiFamilyText" -> "👨"', () => expect(getChar(emojiFamilyText), equals('👨')));
      test(
        '"$emojiThumbsUpSkinText" -> "$emojiSimple"',
        () => expect(getChar(emojiThumbsUpSkinText), equals(emojiSimple)),
      );
    });
  });

  group('String.secondCharacter() detailed', () {
    group('[supportGraphemes = true]', () {
      String getSecond(String s, {bool trim = true}) =>
          s.secondCharacter(supportGraphemes: true, trim: trim);

      test('empty string -> ""', () => expect(getSecond(sEmpty), equals('')));
      test('single char "$sAscii1" -> ""', () => expect(getSecond(sAscii1), equals('')));
      test(
        'whitespace only (trimmed) -> ""',
        () => expect(getSecond(sWhitespace, trim: true), equals('')),
      );
      test(
        'whitespace only (not trimmed) "   " -> " "',
        () => expect(getSecond(sWhitespace, trim: false), equals(' ')),
      );
      test('"$sAsciiMulti" ("Apple") -> "p"', () => expect(getSecond(sAsciiMulti), equals('p')));
      test(
        '"$sLeadSpaceAscii" ("  Banana") (trimmed) -> "a"',
        () => expect(getSecond(sLeadSpaceAscii, trim: true), equals('a')),
      );
      test(
        '"$sLeadSpaceAscii" ("  Banana") (not trimmed) -> " "',
        () => expect(getSecond(sLeadSpaceAscii, trim: false), equals(' ')),
      );
      test('"$sCjkMulti" ("相浦由莉絵") -> "浦"', () => expect(getSecond(sCjkMulti), equals('浦')));
      test(
        '"$emojiSimpleText" ("👍great") -> "g"',
        () => expect(getSecond(emojiSimpleText), equals('g')),
      );
      test(
        '"$emojiHeartVSText" ("❤️love") -> "l"',
        () => expect(getSecond(emojiHeartVSText), equals('l')),
      );
      test(
        '"$emojiFamilyText" ("👨‍👩‍👧‍👦time") -> "t"',
        () => expect(getSecond(emojiFamilyText), equals('t')),
      );
      test(
        '"$emojiThumbsUpSkinText" ("👍🏽ok") -> "o"',
        () => expect(getSecond(emojiThumbsUpSkinText), equals('o')),
      );
      test('Two graphemes "❤️👍" -> "👍"', () => expect(getSecond('❤️👍'), equals('👍')));
      test('Two graphemes "A👍" -> "👍"', () => expect(getSecond('A👍'), equals('👍')));
      test('Two graphemes "👍A" -> "A"', () => expect(getSecond('👍A'), equals('A')));
    });

    group('[supportGraphemes = false]', () {
      String getSecond(String s, {bool trim = true}) =>
          s.secondCharacter(supportGraphemes: false, trim: trim);

      test('empty string -> ""', () => expect(getSecond(sEmpty), equals('')));
      test('single char "$sAscii1" -> ""', () => expect(getSecond(sAscii1), equals('')));
      test(
        'whitespace only (trimmed) -> ""',
        () => expect(getSecond(sWhitespace, trim: true), equals('')),
      );
      test(
        'whitespace only (not trimmed) "   " -> " "',
        () => expect(getSecond(sWhitespace, trim: false), equals(' ')),
      );
      test('"$sAsciiMulti" ("Apple") -> "p"', () => expect(getSecond(sAsciiMulti), equals('p')));
      test(
        '"$sLeadSpaceAscii" ("  Banana") (trimmed) -> "a"',
        () => expect(getSecond(sLeadSpaceAscii, trim: true), equals('a')),
      );
      test(
        '"$sLeadSpaceAscii" ("  Banana") (not trimmed) -> " "',
        () => expect(getSecond(sLeadSpaceAscii, trim: false), equals(' ')),
      );
      test('"$sCjkMulti" ("相浦由莉絵") -> "浦"', () => expect(getSecond(sCjkMulti), equals('浦')));
      test(
        '"$emojiSimpleText" ("👍great") -> "g"',
        () => expect(getSecond(emojiSimpleText), equals('g')),
      );
      test('"$emojiHeartVSText" ("❤️love") -> variation selector "️"', () {
        expect(getSecond(emojiHeartVSText), equals(String.fromCharCode(0xFE0F)));
      });
      test('"$emojiFamilyText" ("👨‍👩‍👧‍👦time") -> ZWJ "‍"', () {
        expect(getSecond(emojiFamilyText), equals(String.fromCharCode(0x200D)));
      });
      test('"$emojiThumbsUpSkinText" ("👍🏽ok") -> skin tone modifier "🏽"', () {
        expect(getSecond(emojiThumbsUpSkinText), equals(String.fromCharCode(0x1F3FD)));
      });
      test('Two runes "AB" -> "B"', () => expect(getSecond('AB'), equals('B')));
      test('One rune "A" -> ""', () => expect(getSecond('A'), equals('')));
    });
  });

  group('String.substringCharacter() detailed', () {
    test('"$sAsciiMulti".substringCharacter(0, 2) -> "Ap"', () {
      expect(sAsciiMulti.substringCharacter(0, 2), equals('Ap'));
    });
    test('"$sAsciiMulti".substringCharacter(3) -> "le"', () {
      expect(sAsciiMulti.substringCharacter(3), equals('le'));
    });
    test('"$sCjkMulti".substringCharacter(0, 2) -> "相浦"', () {
      expect(sCjkMulti.substringCharacter(0, 2), equals('相浦'));
    });
    test('"$sCjkMulti".substringCharacter(2) -> "由莉絵"', () {
      expect(sCjkMulti.substringCharacter(2), equals('由莉絵'));
    });
    test('"$emojiSimpleText".substringCharacter(0, 1) -> "$emojiSimple"', () {
      expect(emojiSimpleText.substringCharacter(0, 1), equals(emojiSimple));
    });
    test('"$emojiSimpleText".substringCharacter(1, 3) -> "gr"', () {
      expect(emojiSimpleText.substringCharacter(1, 3), equals('gr'));
    });
    test('"$emojiHeartVSText".substringCharacter(0, 1) -> "$emojiHeartWithVS"', () {
      expect(emojiHeartVSText.substringCharacter(0, 1), equals(emojiHeartWithVS));
    });
    test('"$emojiHeartVSText".substringCharacter(1) -> "love"', () {
      expect(emojiHeartVSText.substringCharacter(1), equals('love'));
    });
    test('"$emojiFamilyText".substringCharacter(0, 1) -> "$emojiFamily"', () {
      expect(emojiFamilyText.substringCharacter(0, 1), equals(emojiFamily));
    });
    test('"$emojiFamilyText".substringCharacter(1, 3) -> "ti"', () {
      expect(emojiFamilyText.substringCharacter(1, 3), equals('ti'));
    });
    test('"$emojiThumbsUpSkinText".substringCharacter(0, 1) -> "$emojiThumbsUpSkin"', () {
      expect(emojiThumbsUpSkinText.substringCharacter(0, 1), equals(emojiThumbsUpSkin));
    });

    // --- Mixed String tests ---
    test(
      '"$sMixed".substringCharacter(0, 1) -> "A"',
      () => expect(sMixed.substringCharacter(0, 1), equals('A')),
    );
    test(
      '"$sMixed".substringCharacter(1, 2) -> "$emojiHeartWithVS"',
      () => expect(sMixed.substringCharacter(1, 2), equals(emojiHeartWithVS)),
    );
    test(
      '"$sMixed".substringCharacter(0, 2) -> "A$emojiHeartWithVS"',
      () => expect(sMixed.substringCharacter(0, 2), equals('A$emojiHeartWithVS')),
    );
    test(
      '"$sMixed".substringCharacter(3, 4) -> "$emojiThumbsUpSkin"',
      () => expect(sMixed.substringCharacter(3, 4), equals(emojiThumbsUpSkin)),
    );
    test(
      '"$sMixed".substringCharacter(5, 6) -> "$emojiFamily"',
      () => expect(sMixed.substringCharacter(5, 6), equals(emojiFamily)),
    );
    test(
      '"$sMixed".substringCharacter(6) -> "D"',
      () => expect(sMixed.substringCharacter(6), equals('D')),
    );
    test(
      '"$sMixed".substringCharacter(1, 6) -> "❤️B👍🏽C👨‍👩‍👧‍👦"',
      () => expect(sMixed.substringCharacter(1, 6), equals('❤️B👍🏽C👨‍👩‍👧‍👦')),
    );

    // --- Edge Cases ---
    test('"$sEmpty".substringCharacter(0) -> ""', () {
      expect(sEmpty.substringCharacter(0), equals(''));
    });
    test('"$sEmpty".substringCharacter(0, 0) -> ""', () {
      expect(sEmpty.substringCharacter(0, 0), equals(''));
    });
    test('"$sAsciiMulti".substringCharacter(-1) -> ""', () {
      expect(sAsciiMulti.substringCharacter(-1), equals(''));
    });
    test('"$sAsciiMulti".substringCharacter(100) -> ""', () {
      expect(sAsciiMulti.substringCharacter(100), equals(''));
    });
    test('"$sAsciiMulti".substringCharacter(3, 1) -> "" (end < start)', () {
      expect(sAsciiMulti.substringCharacter(3, 1), equals(''));
    });
    test('"$sAsciiMulti".substringCharacter(0, 100) -> "" (end > length)', () {
      expect(sAsciiMulti.substringCharacter(0, 100), equals(''));
    });
    test('"$sAsciiMulti".substringCharacter(2, 2) -> "" (start == end)', () {
      expect(sAsciiMulti.substringCharacter(2, 2), equals(''));
    });

    // --- Full string ---
    test('"$sMixed".substringCharacter(0) -> "$sMixed"', () {
      expect(sMixed.substringCharacter(0), equals(sMixed));
    });
    test('"$sMixed".substringCharacter(0, length) -> "$sMixed"', () {
      expect(sMixed.substringCharacter(0, sMixed.characters.length), equals(sMixed));
    });
  });
}
