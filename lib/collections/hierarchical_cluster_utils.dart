/// Agglomerative hierarchical clustering (small N) — roadmap #450.
library;

import 'dart:math' show sqrt;

/// Distance between two numeric vectors. Must be symmetric and non-negative.
typedef VectorDistance = double Function(List<double> a, List<double> b);

/// Euclidean (L2) distance; the default metric for [hierarchicalCluster].
///
/// Returns 0 for identical points. Extra coordinates on the longer vector are
/// ignored so ragged input cannot throw (we iterate the shorter length).
///
/// Example:
/// ```dart
/// euclideanDistance([0, 0], [3, 4]); // 5.0
/// ```
/// Audited: 2026-06-12 11:26 EDT
double euclideanDistance(List<double> a, List<double> b) {
  final int n = a.length < b.length ? a.length : b.length;
  double sumSq = 0;
  for (int i = 0; i < n; i++) {
    final double d = a[i] - b[i];
    sumSq += d * d;
  }
  return sqrt(sumSq);
}

/// How inter-cluster distance is derived from member pairwise distances.
///
/// [single] is the nearest pair (chaining), [complete] the farthest pair
/// (compact), [average] the mean over all cross pairs (a balance of the two).
enum ClusterLinkage { single, complete, average }

/// One dendrogram merge: cluster ids [a] and [b] joined at [distance].
///
/// Leaves are ids 0..n-1; each merge mints a fresh id n, n+1, ... — recording
/// ids (not point lists) keeps each step O(1) and lets a cut walk the tree
/// without copying members. [size] is the merged member count.
///
/// Example:
/// ```dart
/// const MergeStep(a: 0, b: 1, distance: 2.0, size: 2);
/// ```
class MergeStep {
  /// Creates an immutable dendrogram merge record.
  /// Audited: 2026-06-12 11:26 EDT
  const MergeStep({required this.a, required this.b, required this.distance, required this.size});

  /// First merged cluster id.
  final int a;

  /// Second merged cluster id.
  final int b;

  /// Linkage distance at the merge (monotonic for single/complete linkage).
  final double distance;

  /// Member count of the resulting cluster.
  final int size;
}

/// Builds the agglomerative dendrogram for [points] under [linkage].
///
/// Naive O(n^3) (full pairwise matrix, rescanned per merge) — intended for
/// small N (hundreds, not millions); a heap/NN-chain version would not fit the
/// file budget. Handles N=0 and N=1 (empty result) and identical points
/// (distance 0). Returns n-1 [MergeStep]s in merge order.
///
/// Example:
/// ```dart
/// hierarchicalCluster([[0], [0.1], [9]]).length; // 2
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<MergeStep> hierarchicalCluster(
  List<List<double>> points, {
  ClusterLinkage linkage = ClusterLinkage.average,
  VectorDistance distance = euclideanDistance,
}) {
  if (points.length < 2) return const <MergeStep>[];
  final _ClusterState state = _ClusterState.seed(points, distance);
  final List<MergeStep> steps = <MergeStep>[];
  // Each pass fuses the closest pair and recomputes its distance to the rest;
  // every merge removes one active cluster, so this runs exactly n-1 times.
  while (state.activeCount > 1) {
    steps.add(state.mergeClosest(linkage));
  }
  return steps;
}

/// Labels each of [n] points into [k] clusters by cutting [steps].
///
/// Applies the cheapest merges until k components remain — a dendrogram cut at
/// the k-cluster level. [k] is clamped to 1..n. Returns per-point labels in
/// 0..k-1, densely numbered in first-appearance order for gap-free ids.
///
/// Example:
/// ```dart
/// cutClustersByCount(hierarchicalCluster(pts), pts.length, 2);
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> cutClustersByCount(List<MergeStep> steps, int n, int k) {
  if (n <= 0) return <int>[];
  final int wanted = k < 1 ? 1 : (k > n ? n : k);
  final _UnionFind uf = _UnionFind(n);
  // Stop once k components remain; merge id is n+i (ids minted in step order).
  for (int i = 0; i < steps.length; i++) {
    if (uf.components <= wanted) break;
    uf.unionMerge(steps[i].a, steps[i].b, n + i);
  }
  return uf.denseLabels();
}

/// Labels each of [n] points by cutting [steps] below [threshold].
///
/// Applies every merge whose distance is strictly less than [threshold], so
/// points closer than it share a cluster. Strict-less-than treats a merge
/// exactly at the threshold as not-yet-joined (a stable inclusive bound).
/// Returns dense per-point labels in 0..m-1.
///
/// Example:
/// ```dart
/// cutClustersByDistance(hierarchicalCluster(pts), pts.length, 0.5);
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> cutClustersByDistance(List<MergeStep> steps, int n, double threshold) {
  if (n <= 0) return <int>[];
  final _UnionFind uf = _UnionFind(n);
  // Per-step distance test keeps this correct even for average linkage, whose
  // merge distances are only near-monotonic.
  for (int i = 0; i < steps.length; i++) {
    if (steps[i].distance < threshold) uf.unionMerge(steps[i].a, steps[i].b, n + i);
  }
  return uf.denseLabels();
}

/// Mutable active-cluster set plus a cached upper-triangular distance map.
class _ClusterState {
  _ClusterState._(this._dist, this._size, this._nextId);

  factory _ClusterState.seed(List<List<double>> points, VectorDistance distance) {
    final int n = points.length;
    final Map<int, int> size = <int, int>{for (int i = 0; i < n; i++) i: 1};
    final Map<int, Map<int, double>> dist = <int, Map<int, double>>{};
    for (int i = 0; i < n; i++) {
      dist[i] = <int, double>{for (int j = i + 1; j < n; j++) j: distance(points[i], points[j])};
    }
    return _ClusterState._(dist, size, n);
  }

  final Map<int, Map<int, double>> _dist;
  final Map<int, int> _size;
  int _nextId;

  int get activeCount => _size.length;

  // Active clusters always have a size; absent means a logic error, so fall
  // back to 1 (singleton) rather than crash mid-merge.
  int _sizeOf(int id) => _size[id] ?? 1;

  double _between(int x, int y) {
    final int lo = x < y ? x : y;
    final int hi = x < y ? y : x;
    return _dist[lo]?[hi] ?? double.infinity;
  }

  MergeStep mergeClosest(ClusterLinkage linkage) {
    final (int a, int b, double d) = _closestPair();
    final int newId = _nextId++;
    // Compute the new cluster's distance to each survivor before removing a/b,
    // because average linkage weights by the old member counts.
    final Map<int, double> row = <int, double>{};
    for (final int other in _size.keys.toList()) {
      if (other != a && other != b) row[other] = _linkDistance(linkage, a, b, other);
    }
    final int mergedSize = _sizeOf(a) + _sizeOf(b);
    _replace(a, b, newId, row, mergedSize);
    return MergeStep(a: a, b: b, distance: d, size: mergedSize);
  }

  double _linkDistance(ClusterLinkage linkage, int a, int b, int other) {
    final double da = _between(a, other);
    final double db = _between(b, other);
    // Lance-Williams update: average weights each side by its size so the
    // result equals the mean over all cross pairs without rescanning members.
    switch (linkage) {
      case ClusterLinkage.single:
        return da < db ? da : db;
      case ClusterLinkage.complete:
        return da > db ? da : db;
      case ClusterLinkage.average:
        final int sa = _sizeOf(a);
        final int sb = _sizeOf(b);
        return (da * sa + db * sb) / (sa + sb);
    }
  }

  void _replace(int a, int b, int newId, Map<int, double> row, int mergedSize) {
    _dropCluster(a);
    _dropCluster(b);
    _size[newId] = mergedSize;
    _dist[newId] = <int, double>{};
    // Store each new edge in canonical (lower-id keyed) upper-triangular form.
    for (final MapEntry<int, double> e in row.entries) {
      final int lo = newId < e.key ? newId : e.key;
      final int hi = newId < e.key ? e.key : newId;
      final Map<int, double> targetRow = _dist[lo] ??= <int, double>{};
      targetRow[hi] = e.value;
    }
  }

  void _dropCluster(int id) {
    _size.remove(id);
    _dist.remove(id);
    for (final Map<int, double> r in _dist.values) {
      r.remove(id);
    }
  }

  (int, int, double) _closestPair() {
    int bestA = -1;
    int bestB = -1;
    double best = double.infinity;
    // Scan the cached upper triangle; the first strict minimum wins, so ties
    // resolve to the earliest id pair encountered.
    for (final int i in _size.keys) {
      for (final MapEntry<int, double> e in (_dist[i] ?? const <int, double>{}).entries) {
        if (_size.containsKey(e.key) && e.value < best) {
          best = e.value;
          bestA = i;
          bestB = e.key;
        }
      }
    }
    return (bestA, bestB, best);
  }
}

/// Union-find over the full id space (leaves 0..n-1 plus merge ids n..2n-2).
///
/// Allocating every possible node lets [unionMerge] join real ids directly
/// (no fragile modulo mapping); [denseLabels] reads only the n leaves.
class _UnionFind {
  _UnionFind(this._n)
    : _parent = List<int>.generate(_n < 2 ? _n : 2 * _n - 1, (int i) => i),
      components = _n;

  final int _n;
  final List<int> _parent;

  /// Distinct leaf components remaining.
  int components;

  int _find(int x) {
    int root = x;
    // Path-halving flattens the tree so repeated lookups stay near O(1).
    while (_parent[root] != root) {
      _parent[root] = _parent[_parent[root]];
      root = _parent[root];
    }
    return root;
  }

  /// Joins child ids [a] and [b] and binds parent [mergeId] to that set.
  ///
  /// Binding [mergeId] is essential: a later step may reference it as a child,
  /// and without the link its subtree's leaves would be orphaned. Only the a/b
  /// join changes the leaf component count.
  /// Audited: 2026-06-12 11:26 EDT
  void unionMerge(int a, int b, int mergeId) {
    final int ra = _find(a);
    final int rb = _find(b);
    if (ra != rb) {
      _parent[ra] = rb;
      components--;
    }
    _parent[_find(mergeId)] = _find(rb);
  }

  /// Per-leaf labels in 0..components-1, numbered in first-appearance order.
  /// Audited: 2026-06-12 11:26 EDT
  List<int> denseLabels() {
    final Map<int, int> seen = <int, int>{};
    return List<int>.generate(_n, (int i) => seen.putIfAbsent(_find(i), () => seen.length));
  }
}
