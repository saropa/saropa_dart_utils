import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_diff_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('graphEdgeDiff', () {
    test('detects added and removed edges', () {
      // before: 0->1, 1->2 ; after: 0->1, 0->2
      final Adjacency before = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);
      final Adjacency after = buildGraph(<(int, int)>[(0, 1), (0, 2)], 3);
      final (List<(int, int)> added, List<(int, int)> removed) result = graphEdgeDiff(
        before,
        after,
      );
      expect(result.$1.toSet(), <(int, int)>{(0, 2)});
      expect(result.$2.toSet(), <(int, int)>{(1, 2)});
    });

    test('identical graphs produce no diff', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);
      final (List<(int, int)> added, List<(int, int)> removed) result = graphEdgeDiff(
        g,
        buildGraph(<(int, int)>[(0, 1), (1, 2)], 3),
      );
      expect(result.$1, <(int, int)>[]);
      expect(result.$2, <(int, int)>[]);
    });

    test('all edges added when before is empty', () {
      final Adjacency before = buildGraph(<(int, int)>[], 3);
      final Adjacency after = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);
      final (List<(int, int)> added, List<(int, int)> removed) result = graphEdgeDiff(
        before,
        after,
      );
      expect(result.$1.toSet(), <(int, int)>{(0, 1), (1, 2)});
      expect(result.$2, <(int, int)>[]);
    });

    test('all edges removed when after is empty', () {
      final Adjacency before = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);
      final Adjacency after = buildGraph(<(int, int)>[], 3);
      final (List<(int, int)> added, List<(int, int)> removed) result = graphEdgeDiff(
        before,
        after,
      );
      expect(result.$1, <(int, int)>[]);
      expect(result.$2.toSet(), <(int, int)>{(0, 1), (1, 2)});
    });

    test('two empty graphs produce no diff', () {
      final (List<(int, int)> added, List<(int, int)> removed) result = graphEdgeDiff(
        <List<int>>[],
        <List<int>>[],
      );
      expect(result.$1, <(int, int)>[]);
      expect(result.$2, <(int, int)>[]);
    });

    test('direction matters: 0->1 and 1->0 are distinct edges', () {
      final Adjacency before = buildGraph(<(int, int)>[(0, 1)], 2);
      final Adjacency after = buildGraph(<(int, int)>[(1, 0)], 2);
      final (List<(int, int)> added, List<(int, int)> removed) result = graphEdgeDiff(
        before,
        after,
      );
      expect(result.$1.toSet(), <(int, int)>{(1, 0)});
      expect(result.$2.toSet(), <(int, int)>{(0, 1)});
    });
  });
}
