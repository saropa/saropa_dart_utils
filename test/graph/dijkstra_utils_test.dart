import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/dijkstra_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('dijkstraDistances', () {
    test('shortest distances on a chain', () {
      // 0 ->(1) 1 ->(2) 2 ->(3) 3
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
        const GraphUtils(2, 3, 3),
      ], 4);
      expect(dijkstraDistances(g, 0), <double>[0, 1, 3, 6]);
    });

    test('terminates on a reachable negative-weight cycle (regression)', () {
      // Without a settled set this hung forever (dist kept decreasing and the
      // node re-queued). Dijkstra is non-negative-only, so the result may be
      // wrong, but it must TERMINATE. 1->2 (-1), 2->1 (-1) is a negative cycle.
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, -1),
        const GraphUtils(2, 1, -1),
      ], 3);
      expect(() => dijkstraDistances(g, 0), returnsNormally);
    });

    test('chooses cheaper of two routes', () {
      // 0->2 direct cost 10; 0->1->2 cost 3
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 2, 10),
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
      ], 3);
      expect(dijkstraDistances(g, 0), <double>[0, 1, 3]);
    });

    test('unreachable nodes are infinity', () {
      // 0 -> 1; node 2 unreachable
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 5),
      ], 3);
      final List<double> dist = dijkstraDistances(g, 0);
      expect(dist[0], 0);
      expect(dist[1], 5);
      expect(dist[2], double.infinity);
    });

    test('source distance is 0', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 4),
      ], 2);
      expect(dijkstraDistances(g, 0)[0], 0);
    });

    test('single node graph: distance to itself is 0', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[], 1);
      expect(dijkstraDistances(g, 0), <double>[0]);
    });

    test('non-zero source', () {
      // 1 -> 2 (cost 7); node 0 unreachable from 1
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 7),
      ], 3);
      final List<double> dist = dijkstraDistances(g, 1);
      expect(dist[0], double.infinity);
      expect(dist[1], 0);
      expect(dist[2], 7);
    });
  });

  group('dijkstraWithParents', () {
    test('returns distances and predecessor chain', () {
      // 0 -> 1 -> 2; parents 1<-0, 2<-1
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
      ], 3);
      final (List<double> dist, List<int?> parent) result = dijkstraWithParents(g, 0);
      expect(result.$1, <double>[0, 1, 3]);
      expect(result.$2, <int?>[null, 0, 1]);
    });

    test('parent records the cheaper route', () {
      // 0->2 direct 10; 0->1->2 cost 3 so parent of 2 should be 1
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 2, 10),
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
      ], 3);
      final (List<double> dist, List<int?> parent) result = dijkstraWithParents(g, 0);
      expect(result.$1, <double>[0, 1, 3]);
      expect(result.$2[2], 1);
    });

    test('source has null parent and unreachable nodes have null parent', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 4),
      ], 3);
      final (List<double> dist, List<int?> parent) result = dijkstraWithParents(g, 0);
      expect(result.$2[0], isNull);
      expect(result.$2[1], 0);
      expect(result.$2[2], isNull);
    });

    test('single node graph: distance 0 and null parent', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[], 1);
      final (List<double> dist, List<int?> parent) result = dijkstraWithParents(g, 0);
      expect(result.$1, <double>[0]);
      expect(result.$2, <int?>[null]);
    });
  });
}
