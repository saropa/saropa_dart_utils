import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_lower_extensions.dart';

void main() {
  // cspell: disable
  group('padLeftTo', () {
    test('should pad on the left to the target length', () {
      expect('5'.padLeftTo(3, '0'), '005');
    });

    test('should use space by default', () {
      expect('x'.padLeftTo(3), '  x');
    });

    test('should leave longer strings unchanged', () {
      expect('hello'.padLeftTo(3), 'hello');
    });
  });

  group('padRightTo', () {
    test('should pad on the right to the target length', () {
      expect('5'.padRightTo(3, '0'), '500');
    });

    test('should use space by default', () {
      expect('x'.padRightTo(3), 'x  ');
    });
  });

  group('repeatTimes', () {
    test('should repeat the string n times', () {
      expect('ab'.repeatTimes(3), 'ababab');
    });

    test('should return empty string for n = 0', () {
      expect('ab'.repeatTimes(0), '');
    });

    test('should return empty string for negative n', () {
      expect('ab'.repeatTimes(-2), '');
    });

    test('should return empty string when repeating empty string', () {
      expect(''.repeatTimes(5), '');
    });
  });

  group('isWhitespaceOnly', () {
    test('should be true for spaces only', () {
      expect('   '.isWhitespaceOnly, isTrue);
    });

    test('should be true for tabs and newlines', () {
      expect('\t\n'.isWhitespaceOnly, isTrue);
    });

    test('should be false for empty string', () {
      expect(''.isWhitespaceOnly, isFalse);
    });

    test('should be false when non-whitespace present', () {
      expect(' a '.isWhitespaceOnly, isFalse);
    });
  });

  group('ensurePrefix', () {
    test('should add a missing prefix', () {
      expect('example.com'.ensurePrefix('https://'), 'https://example.com');
    });

    test('should not duplicate an existing prefix', () {
      expect('https://example.com'.ensurePrefix('https://'), 'https://example.com');
    });
  });

  group('ensureSuffix', () {
    test('should add a missing suffix', () {
      expect('file'.ensureSuffix('.txt'), 'file.txt');
    });

    test('should not duplicate an existing suffix', () {
      expect('file.txt'.ensureSuffix('.txt'), 'file.txt');
    });
  });

  group('removePrefix', () {
    test('should remove an existing prefix', () {
      expect('https://example.com'.removePrefix('https://'), 'example.com');
    });

    test('should return unchanged when prefix absent', () {
      expect('example.com'.removePrefix('https://'), 'example.com');
    });
  });

  group('removeSuffix', () {
    test('should remove an existing suffix', () {
      expect('file.txt'.removeSuffix('.txt'), 'file');
    });

    test('should return unchanged when suffix absent', () {
      expect('file'.removeSuffix('.txt'), 'file');
    });
  });

  group('StringDefaultEmptyExtension.orEmpty', () {
    test('should return the string when non-null', () {
      expect('hello'.orEmpty(), 'hello');
    });

    test('should return empty string when null', () {
      const String? value = null;
      expect(value.orEmpty(), '');
    });
  });
}
