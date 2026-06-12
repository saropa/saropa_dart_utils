/// Multi-source breadth-first search on unweighted graphs (roadmap #535).
///
/// Seeds the BFS frontier with several start nodes at once so every node learns
/// its hop distance to the NEAREST seed in a single linear-time sweep, which is
/// far cheaper than running a separate BFS per source and taking the minimum.
library;

import 'graph_utils.dart';

/// Hop distance from each node to the nearest of [sources].
///
/// Index i holds the fewest edges between node i and any seed in [sources].
/// Nodes that cannot be reached from any seed are marked with the sentinel
/// `-1` (a valid distance is always `>= 0`). A node that is itself a source
/// has distance `0`. Out-of-range source indices are ignored.
///
/// Example:
/// ```dart
/// final Adjacency g = buildGraph([(0, 1), (1, 2), (3, 4)], 5);
/// multiSourceBfsDistances(g, [0, 3]); // [0, 1, 2, 0, 1]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> multiSourceBfsDistances(Adjacency graph, Iterable<int> sources) {
  // Distances are the first element of the (dist, nearest) pair; the nearest
  // bookkeeping is computed regardless but discarded here to keep callers that
  // only want distances from depending on the richer return shape.
  final (List<int> dist, List<int> _) = multiSourceBfsNearest(graph, sources);
  return dist;
}

/// Distances plus, for each node, which seed in [sources] is closest.
///
/// `dist[i]` is the hop distance to the nearest seed (or `-1` if unreachable);
/// `nearestSource[i]` is the node index of that seed (or `-1` if unreachable).
/// When several seeds tie for nearest, the one enqueued first (earliest in
/// [sources]) wins, because BFS settles each node exactly once on first reach.
/// Audited: 2026-06-12 11:26 EDT
(List<int> dist, List<int> nearestSource) multiSourceBfsNearest(
  Adjacency graph,
  Iterable<int> sources,
) {
  // -1 doubles as "unreached" for both arrays; BFS overwrites a node's entry
  // exactly once (on its first dequeue), so the first seed to reach it wins ties.
  final List<int> dist = List<int>.filled(graph.length, -1);
  final List<int> nearestSource = List<int>.filled(graph.length, -1);
  final List<(int node, int seed)> queue = <(int, int)>[];
  // Seed the frontier: every valid source starts at distance 0 owning itself.
  // Mark on enqueue (not dequeue) so a node is never queued twice.
  for (final int s in sources) {
    if (s >= 0 && s < graph.length && dist[s] == -1) {
      dist[s] = 0;
      nearestSource[s] = s;
      queue.add((s, s));
    }
  }
  int head = 0;
  // Standard BFS; `head` indexes the front so we avoid O(n) removeAt(0) churn.
  while (head < queue.length) {
    final (int u, int seed) = queue[head++];
    for (final int v in graph[u]) {
      if (dist[v] == -1) {
        dist[v] = dist[u] + 1;
        nearestSource[v] = seed;
        queue.add((v, seed));
      }
    }
  }
  return (dist, nearestSource);
}
