/// Critical path (longest path in DAG) — roadmap #550.
library;

import 'graph_utils.dart';

/// Longest path from [start] to each node (DAG). Returns distances.
List<double> criticalPathDistances(WeightedAdjacency graph, int start) {
  final List<double> dist = List.filled(graph.length, double.negativeInfinity);
  dist[start] = 0;
  final List<int> order = _topoOrder(graph);
  for (final int u in order) {
    if (dist[u] == double.negativeInfinity) continue;
    for (final (int v, double w) in graph[u]) {
      if (dist[u] + w > dist[v]) dist[v] = dist[u] + w;
    }
  }
  return dist;
}

List<int> _topoOrder(WeightedAdjacency graph) {
  final List<int> inDeg = List.filled(graph.length, 0);
  for (final List<(int, double)> adj in graph) {
    for (final (int v, _) in adj) inDeg[v]++;
  }
  final List<int> queue = [
    for (int i = 0; i < graph.length; i++)
      if (inDeg[i] == 0) i,
  ];
  final List<int> out = [];
  while (queue.isNotEmpty) {
    final int u = queue.removeAt(0);
    out.add(u);
    for (final (int v, _) in graph[u]) {
      inDeg[v]--;
      if (inDeg[v] == 0) queue.add(v);
    }
  }
  return out;
}
