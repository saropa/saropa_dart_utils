import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/bfs_dfs_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('bfs', () {
    test('visits all reachable nodes once in breadth-first order', () {
      // 0 -> 1, 0 -> 2, 1 -> 3, 2 -> 3
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (0, 2), (1, 3), (2, 3)], 4);
      final List<int> visited = <int>[];
      final Map<int, int> depthOf = <int, int>{};
      bfs(g, 0, (int node, int depth) {
        visited.add(node);
        depthOf[node] = depth;
      });
      expect(visited, <int>[0, 1, 2, 3]);
      expect(depthOf, <int, int>{0: 0, 1: 1, 2: 1, 3: 2});
    });

    test('does not visit unreachable nodes', () {
      // 0 -> 1, with isolated nodes 2 and 3
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 4);
      final List<int> visited = <int>[];
      bfs(g, 0, (int node, int _) => visited.add(node));
      expect(visited, <int>[0, 1]);
    });

    test('maxDepth caps traversal depth', () {
      // chain 0 -> 1 -> 2 -> 3; maxDepth 1 stops after depth-1 nodes
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 3)], 4);
      final List<int> visited = <int>[];
      bfs(g, 0, (int node, int _) => visited.add(node), maxDepth: 1);
      expect(visited, <int>[0, 1]);
    });

    test('maxDepth 0 visits only the start node', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);
      final List<int> visited = <int>[];
      bfs(g, 0, (int node, int _) => visited.add(node), maxDepth: 0);
      expect(visited, <int>[0]);
    });

    test('handles a cycle without revisiting nodes', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 0)], 3);
      final List<int> visited = <int>[];
      bfs(g, 0, (int node, int _) => visited.add(node));
      expect(visited, <int>[0, 1, 2]);
    });

    test('single isolated start node visits only itself at depth 0', () {
      final Adjacency g = buildGraph(<(int, int)>[], 1);
      final List<int> visited = <int>[];
      int? recordedDepth;
      bfs(g, 0, (int node, int depth) {
        visited.add(node);
        recordedDepth = depth;
      });
      expect(visited, <int>[0]);
      expect(recordedDepth, 0);
    });
  });

  group('dfs', () {
    test('visits all reachable nodes once', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (0, 2), (1, 3), (2, 3)], 4);
      final List<int> visited = <int>[];
      dfs(g, 0, (int node, int _) => visited.add(node));
      expect(visited.toSet(), <int>{0, 1, 2, 3});
      expect(visited, hasLength(4), reason: 'each node visited exactly once');
    });

    test('follows depth-first order on a chain with correct depths', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 3)], 4);
      final List<int> visited = <int>[];
      final Map<int, int> depthOf = <int, int>{};
      dfs(g, 0, (int node, int depth) {
        visited.add(node);
        depthOf[node] = depth;
      });
      expect(visited, <int>[0, 1, 2, 3]);
      expect(depthOf, <int, int>{0: 0, 1: 1, 2: 2, 3: 3});
    });

    test('does not visit unreachable nodes', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 4);
      final List<int> visited = <int>[];
      dfs(g, 0, (int node, int _) => visited.add(node));
      expect(visited.toSet(), <int>{0, 1});
    });

    test('maxDepth caps recursion depth', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 3)], 4);
      final List<int> visited = <int>[];
      dfs(g, 0, (int node, int _) => visited.add(node), maxDepth: 1);
      expect(visited, <int>[0, 1]);
    });

    test('handles a cycle without infinite recursion', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 0)], 3);
      final List<int> visited = <int>[];
      dfs(g, 0, (int node, int _) => visited.add(node));
      expect(visited, <int>[0, 1, 2]);
    });
  });
}
