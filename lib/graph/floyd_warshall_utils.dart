/// All-pairs shortest paths (Floyd–Warshall) — roadmap #536.
library;

import 'graph_utils.dart';

/// Returns distance matrix where row i, column j gives shortest path i→j (infinity if none).
List<List<double>> floydWarshall(WeightedAdjacency graph) {
  final int n = graph.length;
  // Seed the distance matrix: 0 on the diagonal (a vertex to itself), infinity
  // everywhere else (no path known yet).
  final List<List<double>> dist = List.generate(
    n,
    (int i) => List.generate(n, (int j) => i == j ? 0.0 : double.infinity),
  );
  // Lay in the direct edge weights as the initial known distances.
  for (int i = 0; i < n; i++) {
    for (final (int j, double w) in graph[i]) {
      dist[i][j] = w;
    }
  }
  // Floyd–Warshall: for each candidate intermediate vertex k, relax every pair
  // (i, j) by routing through k. k MUST be the outermost loop — it is the DP
  // dimension ("paths using only intermediates <= k"); swapping the loop order
  // would compute wrong distances.
  for (int k = 0; k < n; k++) {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (dist[i][k] + dist[k][j] < dist[i][j]) {
          dist[i][j] = dist[i][k] + dist[k][j];
        }
      }
    }
  }
  return dist;
}
