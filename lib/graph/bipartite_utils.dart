/// Bipartite graph check and partitioning — roadmap #546.
library;

import 'graph_utils.dart';

/// Returns (true, left, right) if bipartite, else (false, [], []).
/// Audited: 2026-06-12 11:26 EDT
(bool isBipartite, List<int> left, List<int> right) bipartitePartition(Adjacency graph) {
  // A graph is bipartite iff it is 2-colorable. BFS-color each vertex: -1 means
  // unvisited, 0 and 1 are the two sides. An edge whose endpoints share a color
  // proves an odd cycle, so the graph is not bipartite.
  final List<int> color = List.filled(graph.length, -1);
  // Outer loop over every vertex so disconnected components are all colored
  // (BFS from one start only reaches its own component).
  for (int s = 0; s < graph.length; s++) {
    if (color[s] >= 0) continue;
    final List<int> queue = [s];
    color[s] = 0;
    while (queue.isNotEmpty) {
      final int u = queue.removeAt(0);
      for (final int v in graph[u]) {
        if (color[v] == -1) {
          // Unseen neighbor: must take the opposite color (1 - u's color).
          color[v] = 1 - color[u];
          queue.add(v);
        } else if (color[v] == color[u]) {
          // Same-colored neighbor across an edge -> odd cycle -> not bipartite.
          return (false, <int>[], <int>[]);
        }
      }
    }
  }
  final List<int> leftPart = [
    for (int i = 0; i < graph.length; i++)
      if (color[i] == 0) i,
  ];
  final List<int> rightPart = [
    for (int j = 0; j < graph.length; j++)
      if (color[j] == 1) j,
  ];
  return (true, leftPart, rightPart);
}
