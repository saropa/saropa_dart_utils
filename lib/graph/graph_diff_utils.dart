/// Graph diff (added/removed/changed edges) — roadmap #553.
library;

import 'graph_utils.dart';

/// Compares two adjacency lists; returns (added edges, removed edges). Edges are (from, to).
(List<(int, int)> added, List<(int, int)> removed) graphEdgeDiff(
  Adjacency before,
  Adjacency after,
) {
  final Set<(int, int)> b = <(int, int)>{};
  for (int i = 0; i < before.length; i++) {
    for (final int j in before[i]) b.add((i, j));
  }
  final Set<(int, int)> a = <(int, int)>{};
  for (int i = 0; i < after.length; i++) {
    for (final int j in after[i]) a.add((i, j));
  }
  return (a.difference(b).toList(), b.difference(a).toList());
}
