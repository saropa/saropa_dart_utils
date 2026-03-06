/// Dijkstra shortest path on weighted graphs (roadmap #533).
library;

import 'graph_utils.dart';

/// Returns shortest distances from [source] to all nodes; unreachable = infinity.
List<double> dijkstraDistances(WeightedAdjacency graph, int source) {
  final List<double> dist = List.filled(graph.length, double.infinity);
  dist[source] = 0;
  final List<int> heap = <int>[source];
  while (heap.isNotEmpty) {
    heap.sort((int a, int b) => dist[a].compareTo(dist[b]));
    final int u = heap.removeAt(0);
    for (final (int v, double w) in graph[u]) {
      final double d = dist[u] + w;
      if (d < dist[v]) {
        dist[v] = d;
        if (!heap.contains(v)) heap.add(v);
      }
    }
  }
  return dist;
}

/// Returns (distances, parent array). The parent list entry at index i is the predecessor on shortest path from source.
(List<double> dist, List<int?> parent) dijkstraWithParents(WeightedAdjacency graph, int source) {
  final List<double> dist = List.filled(graph.length, double.infinity);
  final List<int?> parent = List.filled(graph.length, null);
  dist[source] = 0;
  final List<int> heap = <int>[source];
  while (heap.isNotEmpty) {
    heap.sort((int a, int b) => dist[a].compareTo(dist[b]));
    final int u = heap.removeAt(0);
    for (final (int v, double w) in graph[u]) {
      final double d = dist[u] + w;
      if (d < dist[v]) {
        dist[v] = d;
        parent[v] = u;
        if (!heap.contains(v)) heap.add(v);
      }
    }
  }
  return (dist, parent);
}
