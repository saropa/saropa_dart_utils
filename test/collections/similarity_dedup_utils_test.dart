import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/similarity_dedup_utils.dart';

void main() {
  group('clusterBySimilarity', () {
    // Adjacent integers (difference of exactly 1) count as similar.
    bool adjacent(int a, int b) => (a - b).abs() == 1;

    test('should return no clusters for an empty input', () {
      expect(
        clusterBySimilarity<int>(<int>[], areSimilar: adjacent),
        isEmpty,
      );
    });

    test('should return one singleton cluster for a single item', () {
      expect(
        clusterBySimilarity<int>(<int>[5], areSimilar: adjacent),
        equals(<List<int>>[
          <int>[5],
        ]),
      );
    });

    test('should merge a transitive chain even without direct similarity', () {
      // 1~2 and 2~3 but NOT 1~3 — still one cluster via the chain.
      expect(
        clusterBySimilarity<int>(<int>[1, 2, 3], areSimilar: adjacent),
        equals(<List<int>>[
          <int>[1, 2, 3],
        ]),
      );
    });

    test('should keep fully distinct items in separate clusters', () {
      expect(
        clusterBySimilarity<int>(<int>[10, 20, 30], areSimilar: adjacent),
        equals(<List<int>>[
          <int>[10],
          <int>[20],
          <int>[30],
        ]),
      );
    });

    test('should put all-identical items in one cluster', () {
      expect(
        clusterBySimilarity<int>(<int>[4, 4, 4], areSimilar: (int a, int b) => a == b),
        equals(<List<int>>[
          <int>[4, 4, 4],
        ]),
      );
    });

    test('should preserve first-seen order of items and clusters', () {
      // Chain 1-2-3 appears first; 9 is its own cluster, after.
      expect(
        clusterBySimilarity<int>(<int>[2, 1, 3, 9], areSimilar: adjacent),
        equals(<List<int>>[
          <int>[2, 1, 3],
          <int>[9],
        ]),
      );
    });
  });

  group('dedupBySimilarity', () {
    bool adjacent(int a, int b) => (a - b).abs() == 1;

    test('should return an empty list for empty input', () {
      expect(dedupBySimilarity<int>(<int>[], areSimilar: adjacent), isEmpty);
    });

    test('should keep the first representative of each cluster', () {
      // 2-1-3 collapses to its first-seen member (2); 9 stands alone.
      expect(
        dedupBySimilarity<int>(<int>[2, 1, 3, 9], areSimilar: adjacent),
        equals(<int>[2, 9]),
      );
    });

    test('should collapse all-identical items to a single representative', () {
      expect(
        dedupBySimilarity<int>(<int>[7, 7, 7], areSimilar: (int a, int b) => a == b),
        equals(<int>[7]),
      );
    });
  });
}
