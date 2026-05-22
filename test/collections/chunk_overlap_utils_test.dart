import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/chunk_overlap_utils.dart';

void main() {
  group('chunksWithOverlap', () {
    test('should split into overlapping chunks', () {
      expect(chunksWithOverlap([1, 2, 3, 4, 5], 3, 1), [
        [1, 2, 3],
        [3, 4, 5],
        [5],
      ]);
    });

    test('should split into non-overlapping chunks when overlap is 0', () {
      expect(chunksWithOverlap([1, 2, 3, 4, 5, 6], 2, 0), [
        [1, 2],
        [3, 4],
        [5, 6],
      ]);
    });

    test('should produce more chunks with larger overlap', () {
      // step = chunkSize - overlap = 1; windows start at 0,1,2,3 producing a
      // trailing single-element chunk for the last position.
      expect(chunksWithOverlap([1, 2, 3, 4], 2, 1), [
        [1, 2],
        [2, 3],
        [3, 4],
        [4],
      ]);
    });

    test('should return empty list for empty input', () {
      expect(chunksWithOverlap(<int>[], 3, 1), <List<int>>[]);
    });

    test('should return whole list as single chunk for invalid chunkSize', () {
      expect(chunksWithOverlap([1, 2, 3], 0, 0), [
        [1, 2, 3],
      ]);
    });

    test('should return whole list when overlap >= chunkSize', () {
      expect(chunksWithOverlap([1, 2, 3], 2, 2), [
        [1, 2, 3],
      ]);
    });

    test('should return whole list when overlap is negative', () {
      expect(chunksWithOverlap([1, 2, 3], 2, -1), [
        [1, 2, 3],
      ]);
    });

    test('should handle chunkSize larger than list', () {
      expect(chunksWithOverlap([1, 2], 5, 1), [
        [1, 2],
      ]);
    });

    test('should work for strings', () {
      // step = 1; the final position yields a trailing single-element chunk.
      expect(chunksWithOverlap(['a', 'b', 'c'], 2, 1), [
        ['a', 'b'],
        ['b', 'c'],
        ['c'],
      ]);
    });
  });
}
