import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/accept_language_utils.dart';

void main() {
  group('parseAcceptLanguage', () {
    test('parses tags and q-values, ordered by quality', () {
      final List<LanguageRange> ranges = parseAcceptLanguage('en-US,en;q=0.9,fr;q=0.8');
      expect(ranges.map((LanguageRange r) => r.tag), <String>['en-us', 'en', 'fr']);
      expect(ranges.map((LanguageRange r) => r.quality), <double>[1.0, 0.9, 0.8]);
    });

    test('defaults absent q to 1.0', () {
      expect(parseAcceptLanguage('de').single.quality, 1.0);
    });

    test('drops q=0 (not acceptable)', () {
      final List<LanguageRange> ranges = parseAcceptLanguage('en,de;q=0');
      expect(ranges.map((LanguageRange r) => r.tag), <String>['en']);
    });

    test('keeps header order for equal quality (stable)', () {
      final List<LanguageRange> ranges = parseAcceptLanguage('a;q=0.5,b;q=0.5,c;q=0.9');
      expect(ranges.map((LanguageRange r) => r.tag), <String>['c', 'a', 'b']);
    });

    test('skips malformed entries but keeps valid ones', () {
      final List<LanguageRange> ranges = parseAcceptLanguage('en;q=2,fr');
      expect(ranges.map((LanguageRange r) => r.tag), <String>['fr']);
    });

    test('empty header yields empty list', () {
      expect(parseAcceptLanguage(''), isEmpty);
      expect(parseAcceptLanguage('   '), isEmpty);
    });
  });
}
