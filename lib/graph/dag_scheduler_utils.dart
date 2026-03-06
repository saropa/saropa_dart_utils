/// DAG-based task scheduler (topological + priorities) — roadmap #558.
library;

import 'graph_utils.dart';
import 'topological_sort_utils.dart';

/// Returns schedule (list of node indices) respecting topology; [priority] lower = earlier.
List<int> dagSchedule(Adjacency graph, [int Function(int)? priority]) {
  final List<int>? order = topologicalSort(graph);
  if (order == null) return [];
  if (priority != null) {
    order.sort((int a, int b) => priority(a).compareTo(priority(b)));
  }
  return order;
}
