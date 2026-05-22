import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_unicode_extensions.dart';

void main() {
  // cspell: disable
  group('normalizeUnicodeNfc', () {
    test('should return the string unchanged (no-op without intl)', () {
      expect('café'.normalizeUnicodeNfc(), 'café');
    });

    test('should return empty string unchanged', () {
      expect(''.normalizeUnicodeNfc(), '');
    });

    test('should preserve emoji', () {
      expect('hi 👋'.normalizeUnicodeNfc(), 'hi 👋');
    });
  });

  group('normalizeUnicodeNfd', () {
    test('should return the string unchanged (no-op without intl)', () {
      expect('café'.normalizeUnicodeNfd(), 'café');
    });

    test('should return empty string unchanged', () {
      expect(''.normalizeUnicodeNfd(), '');
    });
  });
}
