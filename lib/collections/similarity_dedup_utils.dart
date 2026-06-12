/// Single-link similarity clustering and dedup — roadmap #461.
///
/// Groups items by TRANSITIVE similarity: if `a` is similar to `b` and `b` is
/// similar to `c`, then `a`, `b`, and `c` land in one cluster even when `a` and
/// `c` are NOT directly similar (single-link / connected-components semantics).
/// This is the right model for fuzzy deduplication — near-duplicate contacts,
/// almost-identical strings, photos within a distance threshold — where a chain
/// of pairwise matches should collapse into one group.
///
/// The pairwise predicate is compared for every pair, so this is `O(n^2)` in
/// the number of items (plus the cost of `areSimilar`); acceptable for the
/// modest batch sizes dedup runs on, not for very large inputs. A union-find
/// merges the connected pairs; first-seen order of items and of clusters is
/// preserved so output is stable and deterministic.
library;

import 'package:collection/collection.dart';

/// Internal union-find over list indices `0 .. n-1` with path compression and
/// union-by-size, used to merge transitively-similar items.
class _IndexUnionFind {
  _IndexUnionFind(int n)
    : _parent = List<int>.generate(n, (int i) => i),
      _size = List<int>.filled(n, 1);

  final List<int> _parent;
  final List<int> _size;

  /// Root of [x], compressing the path so later lookups are near-constant time.
  int find(int x) {
    int root = x;
    // Walk up to the root first (no recursion: inputs can be large).
    while (_parent[root] != root) {
      root = _parent[root];
    }
    // Second pass points every node on the path straight at the root.
    int node = x;
    while (_parent[node] != root) {
      final int next = _parent[node];
      _parent[node] = root;
      node = next;
    }
    return root;
  }

  /// Merges the sets of [a] and [b], attaching the smaller tree under the larger.
  void union(int a, int b) {
    final int rootA = find(a);
    final int rootB = find(b);
    if (rootA == rootB) return;
    // Union by size keeps trees shallow so find stays fast.
    if (_size[rootA] < _size[rootB]) {
      _parent[rootA] = rootB;
      _size[rootB] += _size[rootA];
    } else {
      _parent[rootB] = rootA;
      _size[rootA] += _size[rootB];
    }
  }
}

/// Groups [items] into clusters by single-link (transitive) similarity using
/// [areSimilar]. Two items share a cluster when connected by a chain of similar
/// pairs, even if not directly similar themselves.
///
/// Runs in `O(n^2)` similarity comparisons. The order of items within a cluster,
/// and the order of clusters in the result, both follow first-seen order, so the
/// output is stable for a given input and predicate.
///
/// Example:
/// ```dart
/// // a~b and b~c (but not a~c) still form one cluster via the chain.
/// final List<List<int>> groups = clusterBySimilarity<int>(
///   <int>[1, 2, 3, 9],
///   areSimilar: (int x, int y) => (x - y).abs() == 1,
/// );
/// // groups == [[1, 2, 3], [9]]
/// ```
List<List<T>> clusterBySimilarity<T>(
  List<T> items, {
  required bool Function(T, T) areSimilar,
}) {
  // Nothing to compare: return an empty list of clusters.
  if (items.isEmpty) return <List<T>>[];
  final _IndexUnionFind uf = _IndexUnionFind(items.length);
  // Union every directly-similar pair; transitivity falls out of the union-find.
  for (int i = 0; i < items.length; i++) {
    for (int j = i + 1; j < items.length; j++) {
      if (areSimilar(items[i], items[j])) uf.union(i, j);
    }
  }
  return _groupByRoot(items, uf);
}

/// Reduces [items] to one representative per similarity cluster: the FIRST item
/// (in input order) of each cluster, with clusters ordered by first appearance.
/// Same `O(n^2)` cost and semantics as [clusterBySimilarity].
///
/// Example:
/// ```dart
/// final List<int> reps = dedupBySimilarity<int>(
///   <int>[1, 2, 3, 9],
///   areSimilar: (int x, int y) => (x - y).abs() == 1,
/// );
/// // reps == [1, 9]
/// ```
List<T> dedupBySimilarity<T>(
  List<T> items, {
  required bool Function(T, T) areSimilar,
}) {
  final List<List<T>> clusters = clusterBySimilarity<T>(items, areSimilar: areSimilar);
  // Each cluster is non-empty by construction (built via putIfAbsent + add), so
  // firstOrNull never yields null here; the null filter is a defensive no-op.
  return <T>[
    for (final List<T> cluster in clusters)
      if (cluster.firstOrNull case final T rep) rep,
  ];
}

/// Buckets [items] by their union-find root, preserving first-seen order of both
/// items (within a cluster) and clusters (by the index where each root first
/// appears). A linked map keyed by root index gives that ordering directly.
List<List<T>> _groupByRoot<T>(List<T> items, _IndexUnionFind uf) {
  final Map<int, List<T>> byRoot = <int, List<T>>{};
  // Iterating in index order means each root's list is built first-seen first,
  // and the map preserves insertion order of roots for stable cluster ordering.
  for (int i = 0; i < items.length; i++) {
    byRoot.putIfAbsent(uf.find(i), () => <T>[]).add(items[i]);
  }
  return byRoot.values.toList();
}
