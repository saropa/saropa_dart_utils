/// Connected components (and optionally SCC) — roadmap #537.
library;

import 'graph_utils.dart';

/// Returns list of components (each component = list of node indices).
List<List<int>> connectedComponents(Adjacency graph) {
  final List<bool> seen = List.filled(graph.length, false);
  final List<List<int>> out = <List<int>>[];
  for (int s = 0; s < graph.length; s++) {
    if (seen[s]) continue;
    final List<int> comp = <int>[];
    final List<int> stack = <int>[s];
    seen[s] = true;
    while (stack.isNotEmpty) {
      final int u = stack.removeLast();
      comp.add(u);
      for (final int v in graph[u]) {
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
