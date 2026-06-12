/// K-means clustering (small K, small N) — roadmap #449.
library;

import 'dart:math' show pow;

/// Runs up to [maxIterations] of K-means; [points] are 2D, returns cluster index per point.
/// Audited: 2026-06-12 11:26 EDT
List<int> kmeans2D(List<(double, double)> points, int k, {int maxIterations = 100}) {
  if (points.isEmpty || k < 1) return <int>[];
  const int coordX = 0;
  const int coordY = 1;
  final List<int> assign = List.filled(points.length, 0);
  // Seed centroids spread across the data (maximin / greedy k-means++) so the
  // clusters can actually separate. Seeding all k at points[0] (the previous
  // behavior) collapsed the output to at most two clusters: identical centroids
  // never diverge under Lloyd's algorithm because every tie breaks to the
  // lowest index, so clusters 1..k-1 stayed pinned at the seed forever.
  final List<List<double>> centroids = _seedCentroids(points, k);
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

/// Squared distance from point [p] to its NEAREST seed in [seeds].
double _nearestSeedDist2((double, double) p, List<List<double>> seeds) {
  const int coordX = 0;
  const int coordY = 1;
  double nearest = double.infinity;
  for (final List<double> s in seeds) {
    final double d = _dist2(p, (s[coordX], s[coordY]));
    if (d < nearest) nearest = d;
  }
  return nearest;
}

/// Maximin (greedy k-means++) seeding: start at the first point, then
/// repeatedly add the point FARTHEST from all chosen seeds. Spreading the
/// initial centroids across the data lets genuinely separate groups each claim
/// a seed; naive "first k distinct points" can drop two seeds inside one tight
/// cluster and split it. Deterministic (no randomness). When fewer than [k]
/// distinct points exist, the array is padded with the first point.
/// Audited: 2026-06-12 11:26 EDT
List<List<double>> _seedCentroids(List<(double, double)> points, int k) {
  // Hoist points[0] so the fallback below is not a constant-index read in a loop.
  final (double, double) firstPoint = points[0];
  final List<List<double>> seeds = <List<double>>[
    <double>[firstPoint.$1, firstPoint.$2],
  ];
  while (seeds.length < k) {
    int bestIdx = -1;
    double bestDist = -1;
    for (int i = 0; i < points.length; i++) {
      final double nearest = _nearestSeedDist2(points[i], seeds);
      if (nearest > bestDist) {
        bestDist = nearest;
        bestIdx = i;
      }
    }
    // bestDist == 0 means every remaining point coincides with an existing
    // seed (fewer distinct points than k); pad with the first point.
    final (double, double) pick = bestDist > 0 ? points[bestIdx] : firstPoint;
    seeds.add(<double>[pick.$1, pick.$2]);
  }
  return seeds;
}

double _dist2((double, double) a, (double, double) b) {
  final double deltaX = a.$1 - b.$1;
  final double deltaY = a.$2 - b.$2;
  final double dx2 = pow(deltaX, 2).toDouble();
  final double dy2 = pow(deltaY, 2).toDouble();
  return dx2 + dy2;
}
