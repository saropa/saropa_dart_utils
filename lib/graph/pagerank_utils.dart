/// PageRank via power iteration on a directed graph (roadmap #541).
///
/// Computes the stationary distribution of a random surfer who follows an
/// out-edge with probability [damping] and teleports to a uniformly random
/// node otherwise. Dangling nodes (no out-edges) would leak probability mass,
/// so their rank is redistributed across all nodes every iteration.
library;

import 'graph_utils.dart';

/// PageRank scores for every node, summing to approximately `1.0`.
///
/// [damping] is the follow-a-link probability (the classic value is `0.85`).
/// [iterations] caps the power-iteration passes; [tolerance] stops early once
/// the total absolute change (L1 norm) between passes drops below it, which is
/// the normal exit for well-connected graphs. An empty graph yields `[]`.
///
/// Example:
/// ```dart
/// final Adjacency g = buildGraph([(0, 1), (1, 2), (2, 0)], 3);
/// pageRank(g); // ~[0.333, 0.333, 0.333]
/// ```
List<double> pageRank(
  Adjacency graph, {
  double damping = 0.85,
  int iterations = 100,
  double tolerance = 1e-9,
}) {
  final int n = graph.length;
  // Empty graph has no ranks to distribute; bail before dividing by zero.
  if (n == 0) return <double>[];
  // Start from the uniform distribution so every node has equal initial mass.
  List<double> rank = List<double>.filled(n, 1.0 / n);
  for (int it = 0; it < iterations; it++) {
    final List<double> next = _pageRankStep(graph, rank, damping);
    // L1 change measures how far the distribution moved; once it settles below
    // tolerance further passes are wasted, so stop early.
    double delta = 0;
    for (int i = 0; i < n; i++) {
      delta += (next[i] - rank[i]).abs();
    }
    rank = next;
    if (delta < tolerance) break;
  }
  return rank;
}

/// One power-iteration pass: teleport mass plus damped inbound contributions.
List<double> _pageRankStep(Adjacency graph, List<double> rank, double damping) {
  final int n = graph.length;
  // Dangling nodes (no out-edges) keep no link to spread their mass; pool it
  // and hand it back uniformly so total probability is conserved each pass.
  double danglingMass = 0;
  for (int u = 0; u < n; u++) {
    if (graph[u].isEmpty) danglingMass += rank[u];
  }
  // Base rank: teleport term + the dangling mass shared evenly over all nodes.
  final double base = (1 - damping) / n + damping * danglingMass / n;
  final List<double> next = List<double>.filled(n, base);
  // Push each node's damped rank along its out-edges, split evenly per edge.
  for (int u = 0; u < n; u++) {
    if (graph[u].isEmpty) continue;
    final double share = damping * rank[u] / graph[u].length;
    for (final int v in graph[u]) {
      next[v] += share;
    }
  }
  return next;
}
