import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/dag_scheduler_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('dagSchedule', () {
    test('linear chain without priority returns topological order', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 2)], 3);
      expect(dagSchedule(g), <int>[0, 1, 2]);
    });

    test('cyclic graph returns empty schedule', () {
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (1, 0)], 2);
      expect(dagSchedule(g), <int>[]);
    });

    test('empty graph returns empty schedule', () {
      expect(dagSchedule(<List<int>>[]), <int>[]);
    });

    test('single node returns that node', () {
      expect(dagSchedule(buildGraph(<(int, int)>[], 1)), <int>[0]);
    });

    test('priority reorders independent (edge-free) nodes ascending', () {
      // No edges, so any order is topologically valid; priority then sorts ascending.
      final Adjacency g = buildGraph(<(int, int)>[], 3);
      // Assign priorities: node 0 -> 2, node 1 -> 0, node 2 -> 1
      final List<int> priorities = <int>[2, 0, 1];
      expect(dagSchedule(g, (int n) => priorities[n]), <int>[1, 2, 0]);
    });

    test('priority is a stable comparator-based sort over the topo order', () {
      // No edges; equal priorities preserve the topological (ascending index) order.
      final Adjacency g = buildGraph(<(int, int)>[], 3);
      expect(dagSchedule(g, (int _) => 5), <int>[0, 1, 2]);
    });

    test('topology wins when priority conflicts with a dependency edge', () {
      // 0 must precede 1, but node 1 has the lower (earlier) priority. Priority
      // must NOT pull 1 ahead of its dependency 0: the result stays [0, 1].
      final Adjacency g = buildGraph(<(int, int)>[(0, 1)], 2);
      final List<int> priorities = <int>[10, 1];
      expect(dagSchedule(g, (int n) => priorities[n]), <int>[0, 1]);
    });

    test('priority orders only nodes that are ready together', () {
      // 0 -> {1, 2}; once 0 is emitted, 1 and 2 are both ready and priority
      // decides their order (node 2 has the lower priority, so it comes first).
      final Adjacency g = buildGraph(<(int, int)>[(0, 1), (0, 2)], 3);
      final List<int> priorities = <int>[0, 5, 1];
      expect(dagSchedule(g, (int n) => priorities[n]), <int>[0, 2, 1]);
    });
  });
}
