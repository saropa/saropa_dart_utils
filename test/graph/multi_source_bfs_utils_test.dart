import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';
import 'package:saropa_dart_utils/graph/multi_source_bfs_utils.dart';

void main() {
  group('multiSourceBfsDistances', () {
    test('should match plain BFS from a single source', () {
      // 0 -> 1 -> 2 -> 3 chain; a lone source acts exactly like single-BFS.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 3)], 4);

      expect(multiSourceBfsDistances(g, <int>[0]), equals(<int>[0, 1, 2, 3]));
    });

    test('should give each node its distance to the nearest source', () {
      // Two chains meeting in the middle: 0->1->2 and 4->3->2.
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (1, 2), (4, 3), (3, 2)],
        5,
      );

      expect(
        multiSourceBfsDistances(g, <int>[0, 4]),
        equals(<int>[0, 1, 2, 1, 0]),
      );
    });

    test('should mark unreachable nodes with -1', () {
      // Node 2 has no incoming edge from the source component.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 3);

      expect(multiSourceBfsDistances(g, <int>[0]), equals(<int>[0, 1, -1]));
    });

    test('should give a source itself distance 0', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 2);

      // Node 1 is the seed; its own entry must be 0. (Edge is directed 0->1, so
      // node 0 stays -1 here — index the source node explicitly, not [0].)
      expect(multiSourceBfsDistances(g, <int>[1])[1], equals(0));
    });

    test('should return all -1 when there are no sources', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);

      expect(multiSourceBfsDistances(g, <int>[]), equals(<int>[-1, -1, -1]));
    });

    test('should ignore out-of-range source indices', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 2);

      expect(multiSourceBfsDistances(g, <int>[5, 0]), equals(<int>[0, 1]));
    });
  });

  group('multiSourceBfsNearest', () {
    test('should record which source owns each node', () {
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (1, 2), (4, 3), (3, 2)],
        5,
      );

      final (List<int> dist, List<int> nearest) = multiSourceBfsNearest(
        g,
        <int>[0, 4],
      );

      expect(dist, equals(<int>[0, 1, 2, 1, 0]));
      // Node 2 is reached at distance 2 from BOTH seeds; the seed enqueued first
      // (0) settles it, so its owner is 0.
      expect(nearest, equals(<int>[0, 0, 0, 4, 4]));
    });

    test('should mark unreachable nodes with -1 owner', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 3);

      final (List<int> dist, List<int> nearest) = multiSourceBfsNearest(
        g,
        <int>[0],
      );

      expect(dist, equals(<int>[0, 1, -1]));
      expect(nearest, equals(<int>[0, 0, -1]));
    });

    test('should break distance ties by source order', () {
      // Node 1 is one hop from seed 0 and from seed 2; seed 0 comes first.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (2, 1)], 3);

      final (List<int> _, List<int> nearest) = multiSourceBfsNearest(
        g,
        <int>[0, 2],
      );

      expect(nearest[1], equals(0));
    });
  });
}
