import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/bipartite_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('bipartitePartition', () {
    test('simple bipartite graph is partitioned by color', () {
      // 0-1, 0-3, 2-1, 2-3 (directed edges suffice for BFS coloring here)
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (0, 3), (2, 1), (2, 3)], 4);
      final (bool isBipartite, List<int> left, List<int> right) result = bipartitePartition(g);
      expect(result.$1, isTrue);
      expect(result.$2.toSet(), <int>{0, 2});
      expect(result.$3.toSet(), <int>{1, 3});
    });

    test('odd cycle is not bipartite', () {
      // triangle 0->1->2->0 is an odd cycle
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 0)], 3);
      final (bool isBipartite, List<int> left, List<int> right) result = bipartitePartition(g);
      expect(result.$1, isFalse);
      expect(result.$2, <int>[]);
      expect(result.$3, <int>[]);
    });

    test('even cycle is bipartite', () {
      // 4-cycle 0->1->2->3->0
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 3), (3, 0)], 4);
      final (bool isBipartite, List<int> left, List<int> right) result = bipartitePartition(g);
      expect(result.$1, isTrue);
      expect(result.$2.toSet(), <int>{0, 2});
      expect(result.$3.toSet(), <int>{1, 3});
    });

    test('single edge splits two nodes into opposite sides', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 2);
      final (bool isBipartite, List<int> left, List<int> right) result = bipartitePartition(g);
      expect(result.$1, isTrue);
      expect(result.$2, <int>[0]);
      expect(result.$3, <int>[1]);
    });

    test('isolated nodes are all colored 0 (left)', () {
      final Adjacency g = buildGraph(<(int, int)>[], 3);
      final (bool isBipartite, List<int> left, List<int> right) result = bipartitePartition(g);
      expect(result.$1, isTrue);
      expect(result.$2, <int>[0, 1, 2]);
      expect(result.$3, <int>[]);
    });

    test('empty graph is trivially bipartite with empty sides', () {
      final (bool isBipartite, List<int> left, List<int> right) result = bipartitePartition(
        <List<int>>[],
      );
      expect(result.$1, isTrue);
      expect(result.$2, <int>[]);
      expect(result.$3, <int>[]);
    });
  });
}
