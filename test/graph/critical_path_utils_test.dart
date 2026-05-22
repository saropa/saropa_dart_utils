import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/critical_path_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('criticalPathDistances', () {
    test('longest path on a chain accumulates weights', () {
      // 0 ->(2) 1 ->(3) 2 ->(4) 3
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 2),
        const GraphUtils(1, 2, 3),
        const GraphUtils(2, 3, 4),
      ], 4);
      expect(criticalPathDistances(g, 0), <double>[0, 2, 5, 9]);
    });

    test('picks the longer of two parallel paths to a node', () {
      // 0->1 (1), 1->3 (1) gives 2; 0->2 (5), 2->3 (5) gives 10 -> dist[3] = 10
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 3, 1),
        const GraphUtils(0, 2, 5),
        const GraphUtils(2, 3, 5),
      ], 4);
      expect(criticalPathDistances(g, 0), <double>[0, 1, 5, 10]);
    });

    test('start node has distance 0', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 7),
      ], 2);
      final List<double> dist = criticalPathDistances(g, 0);
      expect(dist[0], 0);
      expect(dist[1], 7);
    });

    test('unreachable nodes keep negative infinity', () {
      // 0 -> 1; node 2 unreachable from 0
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 4),
      ], 3);
      final List<double> dist = criticalPathDistances(g, 0);
      expect(dist[0], 0);
      expect(dist[1], 4);
      expect(dist[2], double.negativeInfinity);
    });

    test('starting from a non-zero source', () {
      // 0 -> 1 -> 2; start at 1 so node 0 is unreachable
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 3),
        const GraphUtils(1, 2, 6),
      ], 3);
      final List<double> dist = criticalPathDistances(g, 1);
      expect(dist[0], double.negativeInfinity);
      expect(dist[1], 0);
      expect(dist[2], 6);
    });

    test('single node graph: distance to itself is 0', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[], 1);
      expect(criticalPathDistances(g, 0), <double>[0]);
    });
  });
}
