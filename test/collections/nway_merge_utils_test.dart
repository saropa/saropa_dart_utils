import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/nway_merge_utils.dart';

void main() {
  group('nWayMerge', () {
    test('should merge multiple sorted iterables into one sorted list', () {
      expect(nWayMerge<num>([
        [1, 4, 7],
        [2, 5],
        [3, 6, 8],
      ]), [1, 2, 3, 4, 5, 6, 7, 8]);
    });

    test('should return empty list for no iterables', () {
      expect(nWayMerge<num>(<Iterable<num>>[]), <num>[]);
    });

    test('should handle a single iterable unchanged', () {
      expect(nWayMerge<num>([
        [1, 2, 3],
      ]), [1, 2, 3]);
    });

    test('should skip empty iterables', () {
      expect(nWayMerge<num>([
        <num>[],
        [1, 2],
        <num>[],
      ]), [1, 2]);
    });

    test('should return empty list when all iterables are empty', () {
      expect(nWayMerge<num>([<num>[], <num>[]]), <num>[]);
    });

    test('should preserve duplicate values across iterables', () {
      expect(nWayMerge<num>([
        [1, 3],
        [1, 2],
      ]), [1, 1, 2, 3]);
    });

    test('should merge sorted strings lexicographically', () {
      expect(nWayMerge<String>([
        ['a', 'c'],
        ['b', 'd'],
      ]), ['a', 'b', 'c', 'd']);
    });

    test('should handle iterables of differing lengths', () {
      expect(nWayMerge<num>([
        [1],
        [2, 3, 4, 5],
      ]), [1, 2, 3, 4, 5]);
    });
  });
}
