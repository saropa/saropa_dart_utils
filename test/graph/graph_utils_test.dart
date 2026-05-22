import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('GraphUtils (weighted directed edge)', () {
    test('constructor with explicit weight exposes from/to/weight', () {
      const GraphUtils edge = GraphUtils(1, 2, 3.5);
      expect(edge.from, 1);
      expect(edge.to, 2);
      expect(edge.weight, 3.5);
    });

    test('constructor defaults weight to 1.0', () {
      const GraphUtils edge = GraphUtils(0, 4);
      expect(edge.from, 0);
      expect(edge.to, 4);
      expect(edge.weight, 1.0);
    });

    test('toString reflects fields', () {
      const GraphUtils edge = GraphUtils(2, 7, 9.0);
      expect(edge.toString(), 'GraphUtils(from: 2, to: 7, weight: 9.0)');
    });
  });

  group('buildGraph (unweighted adjacency)', () {
    test('builds adjacency from edges', () {
      expect(buildGraph(<(int, int)>[(0, 1), (1, 2)], 3), <List<int>>[
        [1],
        [2],
        <int>[],
      ]);
    });

    test('multiple edges out of one node are all recorded in order', () {
      expect(buildGraph(<(int, int)>[(0, 2), (0, 1)], 3), <List<int>>[
        [2, 1],
        <int>[],
        <int>[],
      ]);
    });

    test('empty edge list yields all-empty adjacency', () {
      expect(buildGraph(<(int, int)>[], 3), <List<int>>[<int>[], <int>[], <int>[]]);
    });

    test('zero nodes yields empty adjacency', () {
      expect(buildGraph(<(int, int)>[], 0), <List<int>>[]);
    });

    test('out-of-range source or target edges are skipped', () {
      // 5 is out of range for nodeCount 2; -1 is below range.
      expect(buildGraph(<(int, int)>[(0, 5), (-1, 1), (0, 1)], 2), <List<int>>[
        [1],
        <int>[],
      ]);
    });

    test('self-loop edge is recorded', () {
      expect(buildGraph(<(int, int)>[(1, 1)], 2), <List<int>>[
        <int>[],
        [1],
      ]);
    });
  });

  group('buildWeightedGraph', () {
    test('builds weighted adjacency from edges', () {
      final WeightedAdjacency adj = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1, 2.0),
        const GraphUtils(1, 2, 3.0),
      ], 3);
      expect(adj, <List<(int, double)>>[
        [(1, 2.0)],
        [(2, 3.0)],
        <(int, double)>[],
      ]);
    });

    test('uses default weight 1.0 when edge omits it', () {
      final WeightedAdjacency adj = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 1),
      ], 2);
      expect(adj, <List<(int, double)>>[
        [(1, 1.0)],
        <(int, double)>[],
      ]);
    });

    test('empty edge list yields all-empty adjacency', () {
      expect(
        buildWeightedGraph(<GraphUtils>[], 2),
        <List<(int, double)>>[<(int, double)>[], <(int, double)>[]],
      );
    });

    test('out-of-range edges are skipped', () {
      final WeightedAdjacency adj = buildWeightedGraph(<GraphUtils>[
        const GraphUtils(0, 9, 5.0),
        const GraphUtils(0, 1, 2.0),
      ], 2);
      expect(adj, <List<(int, double)>>[
        [(1, 2.0)],
        <(int, double)>[],
      ]);
    });
  });
}
