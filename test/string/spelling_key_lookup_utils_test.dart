import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/spelling_key_lookup_utils.dart';

void main() {
  // cspell: disable
  const Map<String, List<String>> map = <String, List<String>>{
    'color': <String>['colour', 'colors'],
    'gray': <String>['grey'],
  };

  group('lookupWithVariants', () {
    test('should return the canonical key for an exact key match', () {
      expect(lookupWithVariants('color', map), 'color');
    });

    test('should match the canonical key case-insensitively', () {
      expect(lookupWithVariants('COLOR', map), 'color');
    });

    test('should resolve an exact variant to its canonical key', () {
      expect(lookupWithVariants('colour', map), 'color');
    });

    test('should resolve a variant within the edit-distance budget', () {
      // 'collour' is one edit from 'colour' (default maxDistance 2).
      expect(lookupWithVariants('collour', map), 'color');
    });

    test('should return null when nothing is within maxDistance', () {
      expect(lookupWithVariants('banana', map), isNull);
    });

    test('should respect a tighter maxDistance', () {
      // 'gry' is 1 edit from 'grey'; with maxDistance 0 it should not match.
      expect(lookupWithVariants('gry', map, maxDistance: 0), isNull);
    });

    test('should match within an explicit maxDistance', () {
      expect(lookupWithVariants('gry', map, maxDistance: 1), 'gray');
    });

    test('should trim and lowercase the query', () {
      expect(lookupWithVariants('  Grey  ', map), 'gray');
    });

    test('should return null for an empty map', () {
      expect(lookupWithVariants('color', <String, List<String>>{}), isNull);
    });
  });
}
