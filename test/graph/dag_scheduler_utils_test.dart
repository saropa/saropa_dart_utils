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
  });
}
