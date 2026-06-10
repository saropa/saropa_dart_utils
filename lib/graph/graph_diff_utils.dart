/// Graph diff (added/removed/changed edges) — roadmap #553.
library;

import 'graph_utils.dart';

/// Compares two adjacency lists; returns (added edges, removed edges). Edges are (from, to).
(List<(int, int)> added, List<(int, int)> removed) graphEdgeDiff(
  Adjacency before,
  Adjacency after,
) {
  // Flatten each adjacency list into a set of directed (from, to) edge pairs so
  // the diff reduces to plain set subtraction, regardless of neighbor ordering.
  final Set<(int, int)> b = <(int, int)>{};
  for (int i = 0; i < before.length; i++) {
    for (final int j in before[i]) {
      b.add((i, j));
    }
  }
  final Set<(int, int)> a = <(int, int)>{};
  for (int i = 0; i < after.length; i++) {
    for (final int j in after[i]) {
      a.add((i, j));
    }
  }
  // Added = in after but not before; removed = in before but not after.
  return (a.difference(b).toList(), b.difference(a).toList());
}
