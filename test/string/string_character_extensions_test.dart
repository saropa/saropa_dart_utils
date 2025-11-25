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
    test('14. Without grapheme support', () => expect('hello'.firstCharacter(supportGraphemes: false), 'h'));
    test('15. Unicode without grapheme', () => expect('你好'.firstCharacter(supportGraphemes: false), '你'));
  });

  group('secondCharacter', () {
    test('1. Basic string', () => expect('hello'.secondCharacter(), 'e'));
    test('2. Empty string', () => expect(''.secondCharacter(), ''));
    test('3. Single character', () => expect('a'.secondCharacter(), ''));
    test('4. Unicode string', () => expect('你好'.secondCharacter(), '好'));
    test('5. Emoji string', () => expect('🚀👍test'.secondCharacter(), '👍'));
    test('6. With leading space and trim', () => expect('  hello'.secondCharacter(), 'e'));
    test('7. With leading space no trim', () => expect('  hello'.secondCharacter(trim: false), ' '));
    test('8. Only whitespace with trim', () => expect('   '.secondCharacter(), ''));
    test('9. Only whitespace no trim', () => expect('   '.secondCharacter(trim: false), ' '));
    test('10. Two characters', () => expect('ab'.secondCharacter(), 'b'));
    test('11. Number second', () => expect('a1bc'.secondCharacter(), '1'));
    test('12. Symbol second', () => expect('a@bc'.secondCharacter(), '@'));
    test('13. Tab as second no trim', () => expect('a\tb'.secondCharacter(trim: false), '\t'));
    test('14. Without grapheme support', () => expect('hello'.secondCharacter(supportGraphemes: false), 'e'));
    test('15. Unicode without grapheme', () => expect('你好世'.secondCharacter(supportGraphemes: false), '好'));
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
}
