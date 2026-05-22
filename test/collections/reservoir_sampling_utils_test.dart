import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/reservoir_sampling_utils.dart';

void main() {
  group('reservoirSample', () {
    test('should return all items (copy) when length <= k', () {
      expect(reservoirSample([1, 2, 3], 5), [1, 2, 3]);
    });

    test('should return a copy, not the same list instance', () {
      final List<int> input = [1, 2, 3];
      final List<int> result = reservoirSample(input, 5);
      expect(identical(result, input), isFalse);
      expect(result, input);
    });

    test('should return exactly k items when length > k', () {
      final List<int> result = reservoirSample([1, 2, 3, 4, 5, 6], 3, Random(1));
      expect(result, hasLength(3));
    });

    test('should be deterministic for a fixed seeded Random', () {
      final List<int> a = reservoirSample([1, 2, 3, 4, 5, 6, 7, 8], 3, Random(42));
      final List<int> b = reservoirSample([1, 2, 3, 4, 5, 6, 7, 8], 3, Random(42));
      expect(a, b);
    });

    test('should only return items from the source', () {
      final Set<int> source = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
      final List<int> result = reservoirSample(source.toList(), 4, Random(7));
      expect(result.every(source.contains), isTrue);
    });

    test('should not return duplicate positions (distinct sampled items)', () {
      final List<int> result = reservoirSample([10, 20, 30, 40, 50], 3, Random(3));
      expect(result.toSet().length, result.length);
    });

    test('should return empty list for empty items', () {
      expect(reservoirSample(<int>[], 3), <int>[]);
    });

    test('should return empty list when k is less than 1', () {
      expect(reservoirSample([1, 2, 3], 0), <int>[]);
      expect(reservoirSample([1, 2, 3], -1), <int>[]);
    });

    test('should return a single item for k of 1', () {
      final List<int> result = reservoirSample([1, 2, 3, 4], 1, Random(9));
      expect(result, hasLength(1));
    });
  });
}
