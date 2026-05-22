import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/astar_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('astar', () {
    test('start equals goal returns single-node path', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
      ], 2);
      expect(astar(g, 0, 0, (int _) => 0), <int>[0]);
    });

    test('finds shortest path on a simple chain', () {
      // 0 -> 1 -> 2 -> 3, all weight 1
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1),
        const GraphUtils(1, 2),
        const GraphUtils(2, 3),
      ], 4);
      expect(astar(g, 0, 3, (int _) => 0), <int>[0, 1, 2, 3]);
    });

    test('chooses the cheaper of two routes', () {
      // Direct 0->3 cost 10; detour 0->1->2->3 cost 3
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 3, 10),
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 1),
        const GraphUtils(2, 3, 1),
      ], 4);
      expect(astar(g, 0, 3, (int _) => 0), <int>[0, 1, 2, 3]);
    });

    test('returns null when goal is unreachable', () {
      // 0 -> 1, goal 2 isolated
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
      ], 3);
      expect(astar(g, 0, 2, (int _) => 0), isNull);
    });

    test('admissible heuristic yields the optimal path', () {
      // Goal is node 3 at "distance" approximated by (3 - node).
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 1),
        const GraphUtils(2, 3, 1),
        const GraphUtils(0, 2, 5),
      ], 4);
      double heuristic(int node) => (3 - node).toDouble();
      expect(astar(g, 0, 3, heuristic), <int>[0, 1, 2, 3]);
    });

    test('single node graph: start equals goal returns it', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[], 1);
      expect(astar(g, 0, 0, (int _) => 0), <int>[0]);
    });
  });
}
