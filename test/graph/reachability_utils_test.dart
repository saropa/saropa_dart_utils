import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';
import 'package:saropa_dart_utils/graph/reachability_utils.dart';

void main() {
  group('reachabilitySets', () {
    test('should reach all downstream nodes in a chain', () {
      // 0 -> 1 -> 2: 0 reaches {1,2}, 1 reaches {2}, 2 reaches nothing.
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);

      expect(
        reachabilitySets(g),
        equals(<Set<int>>[
          <int>{1, 2},
          <int>{2},
          <int>{},
        ]),
      );
    });

    test('should make every node reach every node in a full cycle', () {
      // 0 -> 1 -> 2 -> 0: each node loops back to itself, so all sets are full.
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (1, 2), (2, 0)],
        3,
      );

      for (final Set<int> s in reachabilitySets(g)) {
        expect(s, equals(<int>{0, 1, 2}));
      }
    });

    test('should exclude a node from its own set in an acyclic graph', () {
      // Diamond 0->1, 0->2, 1->3, 2->3: no node has a path back to itself.
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (0, 2), (1, 3), (2, 3)],
        4,
      );
      final List<Set<int>> sets = reachabilitySets(g);

      expect(sets[0], equals(<int>{1, 2, 3}));
      expect(sets[1], equals(<int>{3}));
      expect(sets[3], isEmpty);
      // No diagonal membership: acyclic means nobody reaches itself.
      for (int i = 0; i < sets.length; i++) {
        expect(sets[i].contains(i), isFalse);
      }
    });

    test('should put a self-looping node in its own set', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 0), (0, 1)], 2);

      expect(reachabilitySets(g)[0], equals(<int>{0, 1}));
    });
  });

  group('reachabilityMatrix', () {
    test('should agree cell-for-cell with reachabilitySets', () {
      final Adjacency g = buildGraph(
        <(int, int)>[(0, 1), (1, 2), (2, 0), (3, 2)],
        4,
      );
      final List<Set<int>> sets = reachabilitySets(g);
      final List<List<bool>> matrix = reachabilityMatrix(g);

      for (int i = 0; i < g.length; i++) {
        for (int j = 0; j < g.length; j++) {
          expect(matrix[i][j], equals(sets[i].contains(j)), reason: '($i, $j)');
        }
      }
    });
  });

  group('canReach', () {
    final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);

    test('should be true for a downstream node', () {
      expect(canReach(g, 0, 2), isTrue);
    });

    test('should be false against the edge direction', () {
      expect(canReach(g, 2, 0), isFalse);
    });

    test('should be false for self in an acyclic graph', () {
      expect(canReach(g, 0, 0), isFalse);
    });

    test('should be true for self on a cycle', () {
      final Adjacency cyclic = buildGraph(
        <(int, int)>[(0, 1), (1, 0)],
        2,
      );

      expect(canReach(cyclic, 0, 0), isTrue);
    });

    test('should be false for out-of-range endpoints', () {
      expect(canReach(g, 0, 9), isFalse);
      expect(canReach(g, -1, 0), isFalse);
    });
  });
}
