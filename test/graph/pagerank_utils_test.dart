import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';
import 'package:saropa_dart_utils/graph/pagerank_utils.dart';

void main() {
  group('pageRank', () {
    // Sum of all ranks should always be ~1.0 (a probability distribution).
    double sum(List<double> ranks) => ranks.fold<double>(0, (double acc, double r) => acc + r);

    test('should return an empty list for an empty graph', () {
      expect(pageRank(<List<int>>[]), isEmpty);
    });

    test('should return [1.0] for a single node', () {
      final List<double> ranks = pageRank(buildGraph(<(int, int)>[], 1));

      expect(ranks.length, equals(1));
      expect(ranks.first, closeTo(1.0, 1e-9));
    });

    test('should give uniform ranks on a symmetric ring', () {
      // 0 -> 1 -> 2 -> 0: every node has identical in/out structure.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 0)], 3);
      final List<double> ranks = pageRank(g);

      for (final double r in ranks) {
        expect(r, closeTo(1.0 / 3, 1e-6));
      }
    });

    test('should rank a universally-linked node highest', () {
      // Nodes 0, 1, 2 all link to node 3; node 3 links nowhere (dangling).
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 3), (1, 3), (2, 3)],
        4,
      );
      final List<double> ranks = pageRank(g);
      final double hub = ranks[3];

      for (int i = 0; i < 3; i++) {
        expect(hub, greaterThan(ranks[i]));
      }
    });

    test('should keep ranks summing to ~1.0 even with dangling nodes', () {
      // Node 2 is dangling; its mass must be redistributed, not lost.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);

      expect(sum(pageRank(g)), closeTo(1.0, 1e-6));
    });

    test('should keep ranks summing to ~1.0 on a larger mixed graph', () {
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (0, 2), (1, 2), (2, 0), (3, 2), (4, 5)],
        6,
      );

      expect(sum(pageRank(g)), closeTo(1.0, 1e-6));
    });
  });
}
