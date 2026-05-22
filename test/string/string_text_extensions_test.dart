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
