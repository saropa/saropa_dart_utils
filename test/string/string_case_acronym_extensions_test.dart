import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_case_acronym_extensions.dart';

void main() {
  // cspell: disable
  group('toCamelCaseAcronyms', () {
    test('should lowercase a leading acronym and camel-case the rest', () {
      expect('HTTP response'.toCamelCaseAcronyms(), 'httpResponse');
    });

    test('should lowercase a trailing all-uppercase acronym word as a unit', () {
      // An all-uppercase word is lowercased whole, so 'HTML' becomes 'html' with
      // no capitalized boundary -> 'parsehtml'.
      expect('parse HTML'.toCamelCaseAcronyms(), 'parsehtml');
    });

    test('should title-case mixed-case words after the first', () {
      expect('foo bar baz'.toCamelCaseAcronyms(), 'fooBarBaz');
    });

    test('should split on non-alpha separators', () {
      expect('foo-bar_baz'.toCamelCaseAcronyms(), 'fooBarBaz');
    });

    test('should uppercase single-letter words after the first', () {
      expect('a b c'.toCamelCaseAcronyms(), 'aBC');
    });

    test('should return empty string for empty input', () {
      expect(''.toCamelCaseAcronyms(), '');
    });

    test('should return empty string when only separators present', () {
      expect('---'.toCamelCaseAcronyms(), '');
    });
  });

  group('toSnakeCaseAcronyms', () {
    test('should snake-case an acronym followed by a word', () {
      expect('HTTPResponse'.toSnakeCaseAcronyms(), 'http_response');
    });

    test('should snake-case a lowerCamel boundary', () {
      expect('fooBar'.toSnakeCaseAcronyms(), 'foo_bar');
    });

    test('should convert spaces and hyphens to underscores', () {
      expect('foo bar-baz'.toSnakeCaseAcronyms(), 'foo_bar_baz');
    });

    test('should collapse repeated underscores', () {
      expect('foo  bar'.toSnakeCaseAcronyms(), 'foo_bar');
    });

    test('should not add a boundary inside an acronym run', () {
      expect('HTML'.toSnakeCaseAcronyms(), 'html');
    });

    test('should trim leading and trailing underscores', () {
      expect(' foo '.toSnakeCaseAcronyms(), 'foo');
    });

    test('should return empty string for empty input', () {
      expect(''.toSnakeCaseAcronyms(), '');
    });
  });
}
