/// Topological sort with cycle detection — roadmap #539.
library;

import 'graph_utils.dart';

/// Returns sorted node indices, or null if cycle detected.
List<int>? topologicalSort(Adjacency graph) {
  // Kahn's algorithm: repeatedly emit a node with in-degree 0 and decrement its
  // successors' in-degrees, queuing each one once it reaches 0.
  final List<int> inDeg = List.filled(graph.length, 0);
  for (final List<int> adj in graph) {
    for (final int v in adj) {
      inDeg[v]++;
    }
  }
  final List<int> queue = <int>[];
  for (int i = 0; i < graph.length; i++) {
    if (inDeg[i] == 0) queue.add(i);
  }
  final List<int> out = <int>[];
  while (queue.isNotEmpty) {
    final int u = queue.removeAt(0);
    out.add(u);
    for (final int v in graph[u]) {
      inDeg[v]--;
      if (inDeg[v] == 0) queue.add(v);
    }
  }
  // Nodes inside a cycle never reach in-degree 0, so they are never emitted; a
  // short output is the signal that the graph is not a DAG.
  return out.length == graph.length ? out : null;
}
