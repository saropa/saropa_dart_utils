import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_text_extensions.dart';

void main() {
  // cspell: disable
  final String ellipsis = String.fromCharCode(0x2026);

  group('removeConsecutiveSpaces', () {
    test('should collapse runs of whitespace', () {
      expect('a   b    c'.removeConsecutiveSpaces(), 'a b c');
    });

    test('should trim by default', () {
      expect('  a  b  '.removeConsecutiveSpaces(), 'a b');
    });

    test('should keep edges when trim is false', () {
      expect('  a  '.removeConsecutiveSpaces(trim: false), ' a ');
    });

    test('should return null for empty string', () {
      expect(''.removeConsecutiveSpaces(), isNull);
    });
  });

  group('compressSpaces', () {
    test('should be an alias for removeConsecutiveSpaces', () {
      expect('a   b'.compressSpaces(), 'a b');
    });
  });

  group('splitCapitalizedUnicode', () {
    test('should split at a lower-to-upper boundary', () {
      expect('fooBar'.splitCapitalizedUnicode(), <String>['foo', 'Bar']);
    });

    test('should split multiple boundaries', () {
      expect('oneTwoThree'.splitCapitalizedUnicode(), <String>['one', 'Two', 'Three']);
    });

    test('should split before digits when splitNumbers is true', () {
      expect('abc123'.splitCapitalizedUnicode(splitNumbers: true), <String>['abc', '123']);
    });

    test('should return empty list for empty string', () {
      expect(''.splitCapitalizedUnicode(), <String>[]);
    });

    test('should further split by space when requested', () {
      expect(
        'fooBar baz'.splitCapitalizedUnicode(splitBySpace: true),
        <String>['foo', 'Bar', 'baz'],
      );
    });

    // The minLength merging branch (the most complex path in the method) is
    // exercised below. minLength == 1 leaves the raw capitalization split alone;
    // only minLength > 1 walks the buffer and fuses adjacent short parts.

    test('minLength 1 does not merge: aB stays split', () {
      // minLength == 1 skips the merge branch entirely, so the lower-to-upper
      // boundary in 'aB' survives as two parts.
      expect('aB'.splitCapitalizedUnicode(minLength: 1), <String>['a', 'B']);
    });

    test('minLength 2 fuses a one-char part into its neighbor: aB -> [aB]', () {
      // Split yields ['a', 'B']; 'a' (length 1) is below minLength 2, so it
      // fuses with the following part into a single 'aB'.
      expect('aB'.splitCapitalizedUnicode(minLength: 2), <String>['aB']);
    });

    test('minLength 2 keeps parts when every part already meets the floor', () {
      // 'abCdEf' splits to ['ab', 'Cd', 'Ef']; all three are length 2, so none
      // is below the floor and no merging occurs.
      expect(
        'abCdEf'.splitCapitalizedUnicode(minLength: 2),
        <String>['ab', 'Cd', 'Ef'],
      );
    });

    test('minLength 2 fuses only the short leading part', () {
      // 'aBcdEf' splits to ['a', 'Bcd', 'Ef']; only 'a' is below the floor, so
      // it fuses forward to 'aBcd' and 'Ef' stays separate — a partial merge,
      // not an all-or-nothing collapse.
      expect(
        'aBcdEf'.splitCapitalizedUnicode(minLength: 2),
        <String>['aBcd', 'Ef'],
      );
    });

    test('minLength larger than any part fuses everything into one', () {
      // With a floor of 100 no part can ever satisfy the threshold, so the whole
      // capitalization split collapses back into the original string.
      expect(
        'aBcD'.splitCapitalizedUnicode(minLength: 100),
        <String>['aBcD'],
      );
    });

    test('Unicode merge: straße/Mit/Österreich at minLength 4', () {
      // Splits to ['straße', 'Mit', 'Österreich']; 'Mit' (length 3) is below 4,
      // so it fuses backward into 'straßeMit', while 'Österreich' (length 10)
      // stands alone. Confirms the merge walks Unicode parts correctly.
      expect(
        'straßeMitÖsterreich'.splitCapitalizedUnicode(minLength: 4),
        <String>['straßeMit', 'Österreich'],
      );
    });

    test('splitNumbers splits the digit-to-letter boundary too', () {
      // The number-aware regex splits BOTH lower-to-digit and digit-to-letter,
      // so 'Area51TestSite' yields four parts, not three. (The originating app's
      // copy lacked the digit-to-letter rule and produced '51Test' fused; the
      // library deliberately separates them.) minLength 1 disables merging.
      expect(
        'Area51TestSite'.splitCapitalizedUnicode(
          splitNumbers: true,
          minLength: 1,
        ),
        <String>['Area', '51', 'Test', 'Site'],
      );
    });

    test('splitBySpace runs after merging and is not subject to minLength', () {
      // '160 / 4A' has no capitalization boundary, so it stays one segment
      // through the (skipped) merge step; the trailing space split then breaks
      // it into ['160', '/', '4A']. The single-char '/' survives even though
      // minLength is 2, because the space split does not re-apply the floor.
      expect(
        '160 / 4A'.splitCapitalizedUnicode(splitBySpace: true, minLength: 2),
        <String>['160', '/', '4A'],
      );
    });

    test('splitBySpace yields single-char tokens regardless of minLength', () {
      // 'A B C D' has no lower-to-upper boundary, so the merge step is a no-op
      // on the single segment; only the space split fires, producing four
      // one-char tokens that minLength 3 does not collapse.
      expect(
        'A B C D'.splitCapitalizedUnicode(splitBySpace: true, minLength: 3),
        <String>['A', 'B', 'C', 'D'],
      );
    });
  });

  group('words', () {
    test('should split on spaces', () {
      expect('a b c'.words(), <String>['a', 'b', 'c']);
    });

    test('should filter out empty words', () {
      expect('a  b'.words(), <String>['a', 'b']);
    });

    test('should return null for empty string', () {
      expect(''.words(), isNull);
    });
  });

  group('firstWord', () {
    test('should return the first word', () {
      expect('hello world'.firstWord(), 'hello');
    });

    test('should return null for empty string', () {
      expect(''.firstWord(), isNull);
    });
  });

  group('secondWord', () {
    test('should return the second word', () {
      expect('hello world foo'.secondWord(), 'world');
    });

    test('should return null when fewer than two words', () {
      expect('hello'.secondWord(), isNull);
    });

    test('should return null for empty string', () {
      expect(''.secondWord(), isNull);
    });
  });

  group('removeSingleCharacterWords', () {
    test('should remove single-character words', () {
      expect('a hello world'.removeSingleCharacterWords(), 'hello world');
    });

    test('should remove single-digit words too', () {
      expect('I am 5 years old'.removeSingleCharacterWords(), 'am years old');
    });

    test('should return null when everything is removed', () {
      expect('x y z'.removeSingleCharacterWords(), isNull);
    });
  });

  group('firstLines', () {
    test('should return the first N lines', () {
      expect('a\nb\nc\nd'.firstLines(2), 'a\nb');
    });

    test('should return empty string for limit <= 0', () {
      expect('a\nb'.firstLines(0), '');
    });

    test('should return empty string for empty input', () {
      expect(''.firstLines(3), '');
    });
  });

  group('trimLines', () {
    test('should trim each line and drop empty lines', () {
      expect('  a  \n\n  b  '.trimLines(), 'a\nb');
    });
  });

  group('multiLinePrefix', () {
    test('should prefix every line', () {
      expect('a\nb'.multiLinePrefix('> '), '> a\n> b');
    });

    test('should return this for empty prefix', () {
      expect('a\nb'.multiLinePrefix(''), 'a\nb');
    });

    test('should return empty for empty input by default', () {
      expect(''.multiLinePrefix('> '), '');
    });

    test('should prefix empty input when prefixEmptyStrings is true', () {
      expect(''.multiLinePrefix('> ', prefixEmptyStrings: true), '> ');
    });
  });

  group('grammarArticle', () {
    test('should return an for a vowel-initial word', () {
      expect('apple'.grammarArticle(), 'an');
    });

    test('should return an for a silent-h word', () {
      expect('hour'.grammarArticle(), 'an');
    });

    test('should return a for a you-sound word', () {
      expect('user'.grammarArticle(), 'a');
    });

    test('should return a for a university word', () {
      expect('university'.grammarArticle(), 'a');
    });

    test('should return a for a one-sound word', () {
      expect('one-time'.grammarArticle(), 'a');
    });

    test('should return a for a consonant-initial word', () {
      expect('cat'.grammarArticle(), 'a');
    });

    test('should return empty string for empty input', () {
      expect(''.grammarArticle(), '');
    });
  });

  group('possess', () {
    test('should add apostrophe-s to a non-s word', () {
      expect('John'.possess(), "John's");
    });

    test('should add only an apostrophe to an s-word in US style', () {
      expect('boss'.possess(), "boss'");
    });

    test('should add apostrophe-s to an s-word in non-US style', () {
      expect('boss'.possess(isLocaleUS: false), "boss's");
    });

    test('should return this for empty input', () {
      expect(''.possess(), '');
    });
  });

  group('pluralize', () {
    test('should add s for a regular word', () {
      expect('cat'.pluralize(2), 'cats');
    });

    test('should add es for an x-ending word', () {
      expect('box'.pluralize(2), 'boxes');
    });

    test('should switch consonant+y to ies', () {
      expect('city'.pluralize(2), 'cities');
    });

    test('should add s for vowel+y', () {
      expect('day'.pluralize(2), 'days');
    });

    test('should add es for sh-ending word', () {
      expect('dish'.pluralize(2), 'dishes');
    });

    test('should return singular when count is 1', () {
      expect('cat'.pluralize(1), 'cat');
    });

    test('should just add s when simple is true', () {
      expect('box'.pluralize(2, simple: true), 'boxs');
    });
  });

  group('trimWithEllipsis', () {
    test('should return ellipsis for very short strings', () {
      expect('ab'.trimWithEllipsis(), ellipsis);
    });

    test('should keep head plus ellipsis for medium strings', () {
      expect('abcdefg'.trimWithEllipsis(), 'abcde$ellipsis');
    });

    test('should keep head and tail for long strings', () {
      expect('abcdefghijklmno'.trimWithEllipsis(), 'abcde${ellipsis}klmno');
    });
  });

  group('collapseMultilineString', () {
    test('should join lines and return trimmed when within cropLength', () {
      expect('hello\nworld'.collapseMultilineString(cropLength: 100), 'hello world');
    });

    test('should crop at a word boundary and append ellipsis', () {
      expect('hello world foo'.collapseMultilineString(cropLength: 8), 'hello$ellipsis');
    });

    test('should omit ellipsis when appendEllipsis is false', () {
      expect(
        'hello world foo'.collapseMultilineString(cropLength: 8, appendEllipsis: false),
        'hello',
      );
    });

    test('should return this for empty input', () {
      expect(''.collapseMultilineString(cropLength: 5), '');
    });
  });
}
