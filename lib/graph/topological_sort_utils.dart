/// Topological sort with cycle detection — roadmap #539.
library;

import 'graph_utils.dart';

/// Returns sorted node indices, or null if cycle detected.
List<int>? topologicalSort(Adjacency graph) {
  final List<int> inDeg = List.filled(graph.length, 0);
  for (final List<int> adj in graph) {
    for (final int v in adj) inDeg[v]++;
  }
  final List<int> queue = [];
  for (int i = 0; i < graph.length; i++) {
    if (inDeg[i] == 0) queue.add(i);
  }
  final List<int> out = [];
  while (queue.isNotEmpty) {
    final int u = queue.removeAt(0);
    out.add(u);
    for (final int v in graph[u]) {
      inDeg[v]--;
      if (inDeg[v] == 0) queue.add(v);
    }
  }
  return out.length == graph.length ? out : null;
}
