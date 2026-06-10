/// A* shortest path with pluggable heuristic — roadmap #534.
library;

import 'graph_utils.dart';

/// A* from [start] to [goal]. [heuristic](node) must be admissible (never overestimate).
/// Returns path from start to goal (empty if not found), or null if no path.
List<int>? astar(
  WeightedAdjacency graph,
  int start,
  int goal,
  double Function(int node) heuristic,
) {
  if (start == goal) return <int>[start];
  // g = best known cost from start to each node; f = g + heuristic estimate to
  // goal (A*'s priority); parent threads the path back for reconstruction.
  final List<double> g = List.filled(graph.length, double.infinity);
  g[start] = 0;
  final List<int?> parent = List.filled(graph.length, null);
  final List<double> f = List.filled(graph.length, double.infinity);
  f[start] = heuristic(start);
  final List<int> open = <int>[start];
  while (open.isNotEmpty) {
    // Expand the lowest-f frontier node. Sorting the list each pass is a simple
    // stand-in for a priority queue — fine for modest graphs, O(n log n)/pop.
    open.sort((int a, int b) => f[a].compareTo(f[b]));
    final int u = open.removeAt(0);
    if (u == goal) {
      // Reached the goal: walk parent links back to start, then reverse.
      final List<int> path = <int>[];
      for (int? p = goal; p != null; p = parent[p]) {
        path.add(p);
      }
      return path.reversed.toList();
    }
    // Relax each edge: if going through u is cheaper, record it and (re)queue v.
    for (final (int v, double w) in graph[u]) {
      final double gNew = g[u] + w;
      if (gNew < g[v]) {
        g[v] = gNew;
        parent[v] = u;
        f[v] = gNew + heuristic(v);
        if (!open.contains(v)) open.add(v);
      }
    }
  }
  return null;
}
