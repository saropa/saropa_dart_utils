/// Dijkstra shortest path on weighted graphs (roadmap #533).
library;

import 'graph_utils.dart';

/// Returns shortest distances from [source] to all nodes; unreachable = infinity.
///
/// Requires non-negative edge weights (Dijkstra's precondition). With a negative
/// edge the result may be incorrect; with a reachable negative-weight CYCLE the
/// distances would otherwise decrease without bound — the `settled` set bounds
/// each node to one finalization so the call always TERMINATES rather than
/// hanging (it does not, however, detect the cycle).
/// Audited: 2026-06-12 11:26 EDT
List<double> dijkstraDistances(WeightedAdjacency graph, int source) {
  final List<double> dist = List.filled(graph.length, double.infinity);
  // An empty graph or out-of-range source has nothing reachable; return the
  // all-infinity distances (empty list for an empty graph) rather than letting
  // `dist[source] = 0` throw a RangeError on a bad index.
  if (source < 0 || source >= graph.length) return dist;
  dist[source] = 0;
  // Once a node is popped its distance is final (non-negative weights); marking
  // it settled and never relaxing into/out of it again is what guarantees
  // termination even on a negative cycle.
  final List<bool> settled = List<bool>.filled(graph.length, false);
  // `heap` is the frontier; sorting it each pass to pop the nearest node is a
  // simple stand-in for a real priority queue (fine for modest graphs).
  final List<int> heap = <int>[source];
  while (heap.isNotEmpty) {
    heap.sort((int a, int b) => dist[a].compareTo(dist[b]));
    final int u = heap.removeAt(0);
    if (settled[u]) continue;
    settled[u] = true;
    // Relax each outgoing edge; only enqueue v if this gives a shorter path and
    // v is not already finalized (the settled skip also stops a negative cycle
    // from re-relaxing forever).
    for (final (int v, double w) in graph[u]) {
      if (settled[v]) continue;
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
  // Settled set guarantees termination (see dijkstraDistances); requires
  // non-negative weights for correct results.
  final List<bool> settled = List<bool>.filled(graph.length, false);
  final List<int> heap = <int>[source];
  while (heap.isNotEmpty) {
    heap.sort((int a, int b) => dist[a].compareTo(dist[b]));
    final int u = heap.removeAt(0);
    if (settled[u]) continue;
    settled[u] = true;
    for (final (int v, double w) in graph[u]) {
      if (settled[v]) continue;
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
