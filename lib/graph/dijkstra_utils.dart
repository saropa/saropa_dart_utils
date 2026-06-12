/// Dijkstra shortest path on weighted graphs (roadmap #533).
library;

import 'graph_utils.dart';

/// Returns shortest distances from [source] to all nodes; unreachable = infinity.
/// Audited: 2026-06-12 11:26 EDT
List<double> dijkstraDistances(WeightedAdjacency graph, int source) {
  // Dijkstra from a single source; assumes non-negative edge weights.
  final List<double> dist = List.filled(graph.length, double.infinity);
  // An empty graph or out-of-range source has nothing reachable; return the
  // all-infinity distances (empty list for an empty graph) rather than letting
  // `dist[source] = 0` throw a RangeError on a bad index.
  if (source < 0 || source >= graph.length) return dist;
  dist[source] = 0;
  // `heap` is the frontier; sorting it each pass to pop the nearest node is a
  // simple stand-in for a real priority queue (fine for modest graphs).
  final List<int> heap = <int>[source];
  while (heap.isNotEmpty) {
    heap.sort((int a, int b) => dist[a].compareTo(dist[b]));
    final int u = heap.removeAt(0);
    // Relax each outgoing edge; only enqueue v if this gives a shorter path.
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
/// Audited: 2026-06-12 11:26 EDT
(List<double> dist, List<int?> parent) dijkstraWithParents(WeightedAdjacency graph, int source) {
  // Same as dijkstraDistances, but also records each node's predecessor so the
  // actual shortest path (not just its length) can be reconstructed.
  final List<double> dist = List.filled(graph.length, double.infinity);
  final List<int?> parent = List.filled(graph.length, null);
  // Guard a bad/empty source before indexing, matching dijkstraDistances.
  if (source < 0 || source >= graph.length) return (dist, parent);
  dist[source] = 0;
  final List<int> heap = <int>[source];
  while (heap.isNotEmpty) {
    heap.sort((int a, int b) => dist[a].compareTo(dist[b]));
    final int u = heap.removeAt(0);
    for (final (int v, double w) in graph[u]) {
      final double d = dist[u] + w;
      if (d < dist[v]) {
        dist[v] = d;
        // Record how we reached v so the path back to source can be traced.
        parent[v] = u;
        if (!heap.contains(v)) heap.add(v);
      }
    }
  }
  return (dist, parent);
}
