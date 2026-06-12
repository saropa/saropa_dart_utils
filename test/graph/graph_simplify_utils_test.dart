import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_simplify_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('simplifyDegree2Chains', () {
    test('should collapse a single degree-2 chain into one edge', () {
      // 0 - 1 - 2 - 3, with 1 and 2 as pass-through nodes.
      final Adjacency g = <List<int>>[
        <int>[1],
        <int>[0, 2],
        <int>[1, 3],
        <int>[2],
      ];

      final SimplifiedGraph r = simplifyDegree2Chains(g);

      expect(r.edges, equals(<(int, int)>{(0, 3)}));
      expect(r.removed, equals(<int>{1, 2}));
    });

    test('should keep a junction with degree 3', () {
      // 1 is a junction (degree 3): 0-1, 1-2, 1-3. Nothing collapses.
      final Adjacency g = <List<int>>[
        <int>[1],
        <int>[0, 2, 3],
        <int>[1],
        <int>[1],
      ];

      final SimplifiedGraph r = simplifyDegree2Chains(g);

      expect(r.removed, isEmpty);
      expect(r.edges, equals(<(int, int)>{(0, 1), (1, 2), (1, 3)}));
    });

    test('should collapse two chains meeting at a junction', () {
      // 0 - 1 - 2(junction) - 3 - 4, plus 2 - 5. Nodes 1, 3 are pass-throughs.
      final Adjacency g = <List<int>>[
        <int>[1], // 0
        <int>[0, 2], // 1
        <int>[1, 3, 5], // 2 (degree 3 -> junction)
        <int>[2, 4], // 3
        <int>[3], // 4
        <int>[2], // 5
      ];

      final SimplifiedGraph r = simplifyDegree2Chains(g);

      expect(r.removed, equals(<int>{1, 3}));
      expect(r.edges, equals(<(int, int)>{(0, 2), (2, 4), (2, 5)}));
    });

    test('should preserve a pure degree-2 cycle (no junction to anchor)', () {
      // Triangle 0-1-2-0: every node has degree 2 but the cycle must survive.
      final Adjacency g = <List<int>>[
        <int>[1, 2],
        <int>[0, 2],
        <int>[0, 1],
      ];

      final SimplifiedGraph r = simplifyDegree2Chains(g);

      expect(r.removed, equals(<int>{0, 1, 2}));
      expect(r.edges, equals(<(int, int)>{(0, 1), (0, 2), (1, 2)}));
    });

    test('should ignore self-loops and duplicate neighbors', () {
      // Node 1 lists a self-loop and a duplicate; its real degree is 2.
      final Adjacency g = <List<int>>[
        <int>[1],
        <int>[0, 1, 2, 2],
        <int>[1, 3],
        <int>[2],
      ];

      final SimplifiedGraph r = simplifyDegree2Chains(g);

      expect(r.removed, equals(<int>{1, 2}));
      expect(r.edges, equals(<(int, int)>{(0, 3)}));
    });

    test('should leave a leaf attached to a junction untouched', () {
      // 0 is a leaf (degree 1), so the edge to junction-ish 1 stays.
      final Adjacency g = <List<int>>[
        <int>[1],
        <int>[0],
      ];

      final SimplifiedGraph r = simplifyDegree2Chains(g);

      expect(r.removed, isEmpty);
      expect(r.edges, equals(<(int, int)>{(0, 1)}));
    });
  });
}
