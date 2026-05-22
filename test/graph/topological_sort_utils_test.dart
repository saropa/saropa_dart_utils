import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';
import 'package:saropa_dart_utils/graph/topological_sort_utils.dart';

/// Verifies [order] is a valid topological order of [graph]: every edge u->v
/// has u appearing before v, and all nodes are present exactly once.
void _expectValidTopoOrder(Adjacency graph, List<int> order) {
  expect(order.length, graph.length);
  expect(order.toSet().length, graph.length, reason: 'must contain each node once');
  final Map<int, int> position = <int, int>{
    for (int i = 0; i < order.length; i++) order[i]: i,
  };
  for (int u = 0; u < graph.length; u++) {
    for (final int v in graph[u]) {
      expect(position[u]!, lessThan(position[v]!), reason: 'edge $u->$v violated');
    }
  }
}

void main() {
  group('topologicalSort', () {
    test('linear chain returns the only valid order', () {
      // 0 -> 1 -> 2 -> 3 has exactly one topological order.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 3)], 4);
      expect(topologicalSort(g), <int>[0, 1, 2, 3]);
    });

    test('diamond DAG returns a valid order', () {
      // 0 -> 1, 0 -> 2, 1 -> 3, 2 -> 3
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (0, 2), (1, 3), (2, 3)], 4);
      final List<int>? order = topologicalSort(g);
      expect(order, isNotNull);
      _expectValidTopoOrder(g, order!);
    });

    test('detects a 2-cycle (returns null)', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 0)], 2);
      expect(topologicalSort(g), isNull);
    });

    test('detects a 3-cycle (returns null)', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 0)], 3);
      expect(topologicalSort(g), isNull);
    });

    test('detects a self-loop as a cycle (returns null)', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 0)], 1);
      expect(topologicalSort(g), isNull);
    });

    test('disconnected nodes (no edges) returns all nodes', () {
      final Adjacency g = buildGraph(<(int, int)>[], 3);
      final List<int>? order = topologicalSort(g);
      expect(order, isNotNull);
      expect(order!.toSet(), <int>{0, 1, 2});
    });

    test('single node returns that node', () {
      expect(topologicalSort(buildGraph(<(int, int)>[], 1)), <int>[0]);
    });

    test('empty graph returns empty list', () {
      expect(topologicalSort(<List<int>>[]), <int>[]);
    });

    test('partial cycle within larger graph returns null', () {
      // 0 -> 1, 1 -> 2, 2 -> 1 (cycle between 1 and 2)
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 1)], 3);
      expect(topologicalSort(g), isNull);
    });
  });
}
