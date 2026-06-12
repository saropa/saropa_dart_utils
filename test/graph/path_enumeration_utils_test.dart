import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';
import 'package:saropa_dart_utils/graph/path_enumeration_utils.dart';

void main() {
  group('enumeratePaths', () {
    // Canonicalize a path list to a set of comma-joined strings for order-free
    // comparison, since DFS visitation order is an implementation detail.
    Set<String> asSet(List<List<int>> paths) => paths.map((List<int> p) => p.join(',')).toSet();

    test('should enumerate every simple path in a small DAG', () {
      // 0->1->3, 0->2->3, 0->3: three distinct simple paths to 3.
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (0, 2), (0, 3), (1, 3), (2, 3)],
        4,
      );

      expect(
        asSet(enumeratePaths(g, 0, 3)),
        equals(<String>{'0,3', '0,1,3', '0,2,3'}),
      );
    });

    test('should not loop forever on a cyclic graph', () {
      // 0->1->2->0 cycle plus 2->3; only finite simple paths reach 3.
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (1, 2), (2, 0), (2, 3)],
        4,
      );

      expect(asSet(enumeratePaths(g, 0, 3)), equals(<String>{'0,1,2,3'}));
    });

    test('should yield a single zero-edge path when start equals target', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 2);

      expect(
        enumeratePaths(g, 0, 0),
        equals(<List<int>>[
          <int>[0],
        ]),
      );
    });

    test('should cap path length by maxDepth edges', () {
      // 0->1->2->3 (3 edges) and 0->3 (1 edge); maxDepth 1 keeps only the short one.
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (1, 2), (2, 3), (0, 3)],
        4,
      );

      expect(
        enumeratePaths(g, 0, 3, maxDepth: 1),
        equals(<List<int>>[
          <int>[0, 3],
        ]),
      );
    });

    test('should return an empty list when no path exists', () {
      // 1 has no outgoing edge toward 0; 0 cannot be reached from 2.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 3);

      expect(enumeratePaths(g, 2, 0), isEmpty);
    });

    test('should return an empty list for out-of-range endpoints', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 2);

      expect(enumeratePaths(g, 0, 9), isEmpty);
      expect(enumeratePaths(g, -1, 1), isEmpty);
    });
  });
}
