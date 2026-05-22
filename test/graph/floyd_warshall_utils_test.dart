import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/floyd_warshall_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('floydWarshall', () {
    test('all-pairs shortest paths on a chain', () {
      // 0 ->(1) 1 ->(2) 2
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
      ], 3);
      final List<List<double>> dist = floydWarshall(g);
      const double inf = double.infinity;
      expect(dist, <List<double>>[
        <double>[0, 1, 3],
        <double>[inf, 0, 2],
        <double>[inf, inf, 0],
      ]);
    });

    test('relaxes through intermediate node', () {
      // 0->2 direct cost 10; via 1: 0->1 (1) + 1->2 (2) = 3
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 2, 10),
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
      ], 3);
      final List<List<double>> dist = floydWarshall(g);
      expect(dist[0][2], 3);
      expect(dist[0][1], 1);
      expect(dist[1][2], 2);
    });

    test('diagonal is zero', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 5),
      ], 2);
      final List<List<double>> dist = floydWarshall(g);
      expect(dist[0][0], 0);
      expect(dist[1][1], 0);
    });

    test('unreachable pairs are infinity', () {
      // 0 -> 1; no path 1 -> 0
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 3),
      ], 2);
      final List<List<double>> dist = floydWarshall(g);
      expect(dist[1][0], double.infinity);
      expect(dist[0][1], 3);
    });

    test('single node graph: 1x1 zero matrix', () {
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[], 1);
      expect(floydWarshall(g), <List<double>>[<double>[0]]);
    });

    test('empty graph returns empty matrix', () {
      expect(floydWarshall(<List<(int, double)>>[]), <List<double>>[]);
    });

    test('cycle yields full reachability', () {
      // 0->1->2->0, all weight 1
      final WeightedAdjacency g = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 1),
        const GraphUtils(2, 0, 1),
      ], 3);
      final List<List<double>> dist = floydWarshall(g);
      expect(dist[0][2], 2);
      expect(dist[2][1], 2);
      expect(dist[1][0], 2);
    });
  });
}
