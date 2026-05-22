import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/did_you_mean_utils.dart';

void main() {
  // cspell: disable
  group('didYouMean', () {
    const List<String> dictionary = <String>['apple', 'apply', 'ample', 'banana', 'orange'];

    test('should return exact match first', () {
      expect(didYouMean('apple', dictionary).first, 'apple');
    });

    test('should rank closest edit-distance candidates first', () {
      // distance('aple', x): apple=1, apply=2, ample=1. Stable sort by distance
      // keeps the two distance-1 entries in their dictionary order (apple, ample),
      // then apply at distance 2.
      final List<String> result = didYouMean('aple', dictionary, limit: 3);
      expect(result, <String>['apple', 'ample', 'apply']);
    });

    test('should respect the limit parameter', () {
      expect(didYouMean('aaaaa', dictionary, limit: 2), hasLength(2));
    });

    test('should default to a limit of 5', () {
      expect(didYouMean('aaaaa', dictionary), hasLength(5));
    });

    test('should return empty list for empty word', () {
      expect(didYouMean('', dictionary), <String>[]);
    });

    test('should return empty list for empty dictionary', () {
      expect(didYouMean('apple', <String>[]), <String>[]);
    });

    test('should return all words when limit exceeds dictionary size', () {
      expect(didYouMean('x', <String>['a', 'b']), hasLength(2));
    });
  });
}
