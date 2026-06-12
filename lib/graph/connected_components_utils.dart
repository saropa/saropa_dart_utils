/// Connected components (and optionally SCC) — roadmap #537.
library;

import 'graph_utils.dart';

/// Returns list of components (each component = list of node indices).
/// Audited: 2026-06-12 11:26 EDT
List<List<int>> connectedComponents(Adjacency graph) {
  final List<bool> seen = List.filled(graph.length, false);
  final List<List<int>> out = <List<int>>[];
  // Each unvisited node seeds a new component; the inner DFS drains everything
  // reachable from it before the outer loop advances to the next unseen seed.
  for (int s = 0; s < graph.length; s++) {
    if (seen[s]) continue;
    final List<int> comp = <int>[];
    final List<int> stack = <int>[s];
    seen[s] = true;
    while (stack.isNotEmpty) {
      final int u = stack.removeLast();
      comp.add(u);
      for (final int v in graph[u]) {
        // Mark on push, not on pop: this keeps each node out of the stack more
        // than once and bounds total work, but it means `seen` denotes "queued",
        // not yet "processed".
        if (!seen[v]) {
          seen[v] = true;
          stack.add(v);
        }
      }
    }
    out.add(comp);
  }
  return out;
}
