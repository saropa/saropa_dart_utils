import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/kmeans_utils.dart';

void main() {
  group('kmeans2D', () {
    test('should return one cluster index per point', () {
      final List<int> result = kmeans2D([
        (0.0, 0.0),
        (0.1, 0.1),
        (10.0, 10.0),
        (10.1, 9.9),
      ], 2);
      expect(result, hasLength(4));
    });

    test('should group two well-separated clusters identically within group', () {
      final List<int> result = kmeans2D([
        (0.0, 0.0),
        (0.1, 0.1),
        (10.0, 10.0),
        (10.1, 9.9),
      ], 2);
      // The two near (0,0) share a cluster; the two near (10,10) share another.
      expect(result[0], result[1]);
      expect(result[2], result[3]);
      expect(result[0], isNot(result[2]));
    });

    test('should put everything in cluster 0 when k is 1', () {
      expect(
        kmeans2D([
          (1.0, 1.0),
          (2.0, 2.0),
          (3.0, 3.0),
        ], 1),
        [0, 0, 0],
      );
    });

    test('should return empty list for empty points', () {
      expect(kmeans2D(<(double, double)>[], 3), <int>[]);
    });

    test('should return empty list when k is less than 1', () {
      expect(kmeans2D([(1.0, 1.0)], 0), <int>[]);
    });

    test('should produce indices within range 0..k-1', () {
      final List<int> result = kmeans2D([
        (0.0, 0.0),
        (5.0, 5.0),
        (10.0, 10.0),
      ], 3);
      expect(result.every((int i) => i >= 0 && i < 3), isTrue);
    });

    test('should assign a single point to cluster 0', () {
      expect(kmeans2D([(7.0, 7.0)], 2), [0]);
    });

    test('should respect maxIterations parameter without error', () {
      final List<int> result = kmeans2D(
        [
          (0.0, 0.0),
          (1.0, 1.0),
        ],
        2,
        maxIterations: 1,
      );
      expect(result, hasLength(2));
    });
  });
}
