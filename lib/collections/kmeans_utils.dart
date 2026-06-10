/// K-means clustering (small K, small N) — roadmap #449.
library;

import 'dart:math' show pow;

/// Runs up to [maxIterations] of K-means; [points] are 2D, returns cluster index per point.
List<int> kmeans2D(List<(double, double)> points, int k, {int maxIterations = 100}) {
  if (points.isEmpty || k < 1) return <int>[];
  const int coordX = 0;
  const int coordY = 1;
  final List<int> assign = List.filled(points.length, 0);
  // All centroids start at the first point. They diverge on the first iteration
  // because empty clusters keep their seed while the populated one moves to its
  // mean — a simple, deterministic seeding (no randomness to make tests vary).
  final double firstX = points[0].$1;
  final double firstY = points[0].$2;
  final List<List<double>> centroids = List.generate(k, (_) => [firstX, firstY]);
  // Lloyd's algorithm: alternate assign-to-nearest and recompute-means until the
  // centroids stop moving or the iteration cap is hit (the cap bounds runtime if
  // it never fully settles).
  for (int iter = 0; iter < maxIterations; iter++) {
    final List<List<double>> sum = List.generate(k, (_) => [0.0, 0.0]);
    final List<int> count = List.filled(k, 0);
    final List<double> centroid0 = centroids[coordX];
    // Assignment step: put each point in its nearest centroid's cluster and
    // accumulate that cluster's coordinate sums for the upcoming mean.
    for (int i = 0; i < points.length; i++) {
      int bestCluster = 0;
      double bestDistSq = _dist2(points[i], (centroid0[coordX], centroid0[coordY]));
      for (int c = 1; c < k; c++) {
        final List<double> centroidC = centroids[c];
        final double d = _dist2(points[i], (centroidC[coordX], centroidC[coordY]));
        if (d < bestDistSq) {
          bestDistSq = d;
          bestCluster = c;
        }
      }
      assign[i] = bestCluster;
      final List<double> sumForBest = sum[bestCluster];
      sumForBest[coordX] += points[i].$1;
      sumForBest[coordY] += points[i].$2;
      count[bestCluster]++;
    }
    // Update step: move each non-empty cluster's centroid to the mean of its
    // members. Empty clusters are left untouched (no members to average).
    bool hasConverged = true;
    for (int c = 0; c < k; c++) {
      final int clusterCount = count[c];
      if (clusterCount == 0) continue;
      final List<double> clusterSum = sum[c];
      final double newCenterX = clusterSum[coordX] / clusterCount;
      final double newCenterY = clusterSum[coordY] / clusterCount;
      final List<double> centroidC = centroids[c];
      // Any centroid that actually moved means we have not converged yet.
      if (centroidC[coordX] != newCenterX || centroidC[coordY] != newCenterY) hasConverged = false;
      centroids[c] = [newCenterX, newCenterY];
    }
    if (hasConverged) break;
  }
  return assign;
}

double _dist2((double, double) a, (double, double) b) {
  final double deltaX = a.$1 - b.$1;
  final double deltaY = a.$2 - b.$2;
  final double dx2 = pow(deltaX, 2).toDouble();
  final double dy2 = pow(deltaY, 2).toDouble();
  return dx2 + dy2;
}
