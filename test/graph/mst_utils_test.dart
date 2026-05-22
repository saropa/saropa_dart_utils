import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';
import 'package:saropa_dart_utils/graph/mst_utils.dart';

/// Renders an edge as a (from, to, weight) record for order-independent compares.
(int, int, double) _edgeTuple(GraphUtils e) => (e.from, e.to, e.weight);

void main() {
  group('kruskalMST', () {
    test('triangle keeps the two cheapest edges and skips the cycle-closing one', () {
      // 0-1 (1), 1-2 (2), 0-2 (3): MST takes 0-1 and 1-2, total 3.
      final List<GraphUtils> edges = <GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
        const GraphUtils(0, 2, 3),
      ];
      final (List<GraphUtils> mst, double cost) result = kruskalMST(3, edges);
      expect(result.$2, 3);
      expect(
        result.$1.map(_edgeTuple).toSet(),
        <(int, int, double)>{(0, 1, 1), (1, 2, 2)},
      );
    });

    test('already-minimal spanning chain keeps all edges', () {
      // 0-1 (1), 1-2 (2): no cycle, both retained, cost 3.
      final List<GraphUtils> edges = <GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(1, 2, 2),
      ];
      final (List<GraphUtils> mst, double cost) result = kruskalMST(3, edges);
      expect(result.$2, 3);
      expect(result.$1, hasLength(2));
    });

    test('processes edges in ascending weight order (cheapest first)', () {
      // Provide out of order; cheapest 0-1 (1) then 0-2 (2) selected before 1-2 (5).
      final List<GraphUtils> edges = <GraphUtils>[
        const GraphUtils(1, 2, 5),
        const GraphUtils(0, 2, 2),
        const GraphUtils(0, 1, 1),
      ];
      final (List<GraphUtils> mst, double cost) result = kruskalMST(3, edges);
      expect(result.$2, 3);
      expect(
        result.$1.map(_edgeTuple).toSet(),
        <(int, int, double)>{(0, 1, 1), (0, 2, 2)},
      );
    });

    test('forest: disconnected components yield fewer than n-1 edges', () {
      // Nodes 0-1 connected (weight 1); nodes 2-3 connected (weight 4); two components.
      final List<GraphUtils> edges = <GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(2, 3, 4),
      ];
      final (List<GraphUtils> mst, double cost) result = kruskalMST(4, edges);
      expect(result.$2, 5);
      expect(result.$1, hasLength(2));
    });

    test('no edges yields empty MST and zero cost', () {
      final (List<GraphUtils> mst, double cost) result = kruskalMST(3, <GraphUtils>[]);
      expect(result.$1, <GraphUtils>[]);
      expect(result.$2, 0);
    });

    test('duplicate parallel edges: only the first connecting one is kept', () {
      // Two 0-1 edges; the second is redundant once 0 and 1 are connected.
      final List<GraphUtils> edges = <GraphUtils>[
        const GraphUtils(0, 1, 1),
        const GraphUtils(0, 1, 2),
      ];
      final (List<GraphUtils> mst, double cost) result = kruskalMST(2, edges);
      expect(result.$1, hasLength(1));
      expect(result.$2, 1);
    });
  });
}
