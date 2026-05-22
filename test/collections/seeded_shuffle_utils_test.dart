import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/seeded_shuffle_utils.dart';

void main() {
  group('shuffleWithSeed', () {
    test('should be deterministic for the same seed', () {
      final List<int> a = shuffleWithSeed([1, 2, 3, 4, 5], 42);
      final List<int> b = shuffleWithSeed([1, 2, 3, 4, 5], 42);
      expect(a, b);
    });

    test('should preserve all elements (a permutation)', () {
      final List<int> result = shuffleWithSeed([1, 2, 3, 4, 5], 7);
      expect(result..sort(), [1, 2, 3, 4, 5]);
    });

    test('should not mutate the original list', () {
      final List<int> original = [1, 2, 3, 4, 5];
      shuffleWithSeed(original, 7);
      expect(original, [1, 2, 3, 4, 5]);
    });

    test('should usually differ between different seeds', () {
      final List<int> a = shuffleWithSeed([1, 2, 3, 4, 5, 6, 7, 8], 1);
      final List<int> b = shuffleWithSeed([1, 2, 3, 4, 5, 6, 7, 8], 999);
      expect(a, isNot(b));
    });

    test('should return empty list for empty input', () {
      expect(shuffleWithSeed(<int>[], 1), <int>[]);
    });

    test('should return single element unchanged', () {
      expect(shuffleWithSeed([42], 5), [42]);
    });

    test('should return a copy, not the same instance', () {
      final List<int> input = [1, 2, 3];
      final List<int> result = shuffleWithSeed(input, 1);
      expect(identical(result, input), isFalse);
    });

    test('should shuffle strings deterministically', () {
      final List<String> a = shuffleWithSeed(['a', 'b', 'c', 'd'], 3);
      final List<String> b = shuffleWithSeed(['a', 'b', 'c', 'd'], 3);
      expect(a, b);
      expect(a..sort(), ['a', 'b', 'c', 'd']);
    });
  });
}
