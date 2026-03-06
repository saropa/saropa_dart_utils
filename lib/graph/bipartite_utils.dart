/// Bipartite graph check and partitioning — roadmap #546.
library;

import 'graph_utils.dart';

/// Returns (true, left, right) if bipartite, else (false, [], []).
(bool isBipartite, List<int> left, List<int> right) bipartitePartition(Adjacency graph) {
  final List<int> color = List.filled(graph.length, -1);
  for (int s = 0; s < graph.length; s++) {
    if (color[s] >= 0) continue;
    final List<int> queue = [s];
    color[s] = 0;
    while (queue.isNotEmpty) {
      final int u = queue.removeAt(0);
      for (final int v in graph[u]) {
        if (color[v] == -1) {
          color[v] = 1 - color[u];
          queue.add(v);
        } else if (color[v] == color[u]) {
          return (false, [], []);
        }
      }
    }
  }
  final List<int> leftPart = [
    for (int i = 0; i < graph.length; i++)
      if (color[i] == 0) i,
  ];
  final List<int> rightPart = [
    for (int i = 0; i < graph.length; i++)
      if (color[i] == 1) i,
  ];
  return (true, leftPart, rightPart);
}
