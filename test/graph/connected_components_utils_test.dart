import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/connected_components_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

/// Normalizes components into a set of sorted node-sets so component order and
/// intra-component order do not affect equality.
Set<Set<int>> _asNodeSets(List<List<int>> components) =>
    components.map((List<int> c) => c.toSet()).toSet();

void main() {
  group('connectedComponents', () {
    test('two disjoint pairs return two components', () {
      // 0-1 (via 0->1) and 2-3 (via 2->3); reachability-based DFS groups each pair
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (2, 3)], 4);
      final List<List<int>> result = connectedComponents(g);
      expect(result, hasLength(2));
      expect(_asNodeSets(result), <Set<int>>{
        <int>{0, 1},
        <int>{2, 3},
      });
    });

    test('fully connected chain is a single component', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 3)], 4);
      final List<List<int>> result = connectedComponents(g);
      expect(result, hasLength(1));
      expect(result.first.toSet(), <int>{0, 1, 2, 3});
    });

    test('all isolated nodes return one component each', () {
      final Adjacency g = buildGraph(<(int, int)>[], 3);
      final List<List<int>> result = connectedComponents(g);
      expect(result, hasLength(3));
      expect(_asNodeSets(result), <Set<int>>{
        <int>{0},
        <int>{1},
        <int>{2},
      });
    });

    test('single node returns one component', () {
      final List<List<int>> result = connectedComponents(buildGraph(<(int, int)>[], 1));
      expect(result, <List<int>>[<int>[0]]);
    });

    test('empty graph returns no components', () {
      expect(connectedComponents(<List<int>>[]), <List<int>>[]);
    });

    test('cycle forms a single component', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2), (2, 0)], 3);
      final List<List<int>> result = connectedComponents(g);
      expect(result, hasLength(1));
      expect(result.first.toSet(), <int>{0, 1, 2});
    });
  });
}
