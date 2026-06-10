/// Critical path (longest path in DAG) — roadmap #550.
library;

import 'graph_utils.dart';

/// Longest path from [start] to each node (DAG). Returns distances.
List<double> criticalPathDistances(WeightedAdjacency graph, int start) {
  // Longest-path (critical path) in a DAG. Seed distances to -infinity so only
  // nodes actually reachable from start get a finite value; start itself is 0.
  final List<double> dist = List.filled(graph.length, double.negativeInfinity);
  dist[start] = 0;
  // Relax edges in topological order so a node's longest distance is final
  // before its successors are processed — what makes one pass correct.
  final List<int> order = _topoOrder(graph);
  for (final int u in order) {
    // Skip unreachable nodes; relaxing from -infinity would be meaningless.
    if (dist[u] == double.negativeInfinity) continue;
    for (final (int v, double w) in graph[u]) {
      if (dist[u] + w > dist[v]) dist[v] = dist[u] + w;
    }
  }
  return dist;
}

List<int> _topoOrder(WeightedAdjacency graph) {
  // Kahn's algorithm: order nodes so every edge points forward. Relaxing edges in
  // this order guarantees each node's distance is finalized before its successors
  // are reached, which is what makes the single-pass longest-path relaxation correct.
  final List<int> inDeg = List.filled(graph.length, 0);
  for (final List<(int, double)> adj in graph) {
    for (final (int v, _) in adj) {
      inDeg[v]++;
    }
  }
  // Sources (no incoming edges) are the only nodes that can come first.
  final List<int> queue = [
    for (int i = 0; i < graph.length; i++)
      if (inDeg[i] == 0) i,
  ];
  final List<int> out = <int>[];
  while (queue.isNotEmpty) {
    final int u = queue.removeAt(0);
    out.add(u);
    // Emitting u "removes" its outgoing edges; a successor becomes a new source
    // once its last remaining predecessor has been emitted.
    for (final (int v, _) in graph[u]) {
      inDeg[v]--;
      if (inDeg[v] == 0) queue.add(v);
    }
  }
  return out;
}
