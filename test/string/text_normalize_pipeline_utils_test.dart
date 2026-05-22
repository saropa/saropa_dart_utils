import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/text_normalize_pipeline_utils.dart';

void main() {
  // cspell: disable
  group('normalizeLower', () {
    test('should lowercase the string', () {
      expect(normalizeLower('Hello WORLD'), 'hello world');
    });

    test('should return empty string for empty input', () {
      expect(normalizeLower(''), '');
    });
  });

  group('normalizeTrim', () {
    test('should trim surrounding whitespace', () {
      expect(normalizeTrim('  spaced  '), 'spaced');
    });

    test('should leave inner whitespace intact', () {
      expect(normalizeTrim('  a b  '), 'a b');
    });
  });

  group('normalizeText', () {
    test('should apply a single step', () {
      expect(normalizeText('HELLO', <NormalizeStep>[normalizeLower]), 'hello');
    });

    test('should apply steps in order', () {
      expect(
        normalizeText('  HELLO  ', <NormalizeStep>[normalizeTrim, normalizeLower]),
        'hello',
      );
    });

    test('should return the input unchanged for an empty step list', () {
      expect(normalizeText('AsIs', <NormalizeStep>[]), 'AsIs');
    });

    test('should apply a custom step function', () {
      String exclaim(String s) => '$s!';
      expect(normalizeText('hi', <NormalizeStep>[exclaim]), 'hi!');
    });

    test('should thread output of one step into the next', () {
      String reverse(String s) => s.split('').reversed.join();
      expect(
        normalizeText('AB', <NormalizeStep>[normalizeLower, reverse]),
        'ba',
      );
    });
  });
}
