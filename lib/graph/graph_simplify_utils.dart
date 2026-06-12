/// Graph simplification: collapse degree-2 chains — roadmap #545.
///
/// Many graphs built from real geometry or pipelines contain long chains of
/// "pass-through" nodes: vertices with exactly two neighbors that add no
/// branching, only length. Routing, layout, and topology analysis usually care
/// about the *junctions* (degree != 2) and the connectivity between them, not
/// the intermediate beads. This utility contracts each maximal chain of
/// degree-2 nodes into a single edge between the junctions at its ends, on an
/// undirected graph given as a symmetric [Adjacency] list.
///
/// A component that is a pure cycle of degree-2 nodes has no junction to anchor
/// to; its original edges are preserved unchanged so connectivity is never
/// lost.
library;

import 'package:collection/collection.dart';

import 'graph_utils.dart';

/// Result of simplification: the surviving [edges] (undirected, each stored as
/// an ordered `(low, high)` pair) and the set of [removed] degree-2 node ids.
typedef SimplifiedGraph = ({Set<(int, int)> edges, Set<int> removed});

/// Contracts maximal chains of degree-2 nodes in undirected [graph].
///
/// [graph] must be symmetric (if `j` is in `graph[i]`, then `i` is in
/// `graph[j]`). Self-loops and duplicate neighbors are ignored.
///
/// Example:
/// ```dart
/// // 0 - 1 - 2 - 3, where 1 and 2 are degree-2 pass-throughs.
/// final Adjacency g = <List<int>>[<int>[1], <int>[0, 2], <int>[1, 3], <int>[2]];
/// simplifyDegree2Chains(g).edges; // {(0, 3)}
/// ```
/// Audited: 2026-06-12 11:26 EDT
SimplifiedGraph simplifyDegree2Chains(Adjacency graph) {
  final List<Set<int>> neighbors = _neighborSets(graph);
  final Set<int> removed = <int>{
    for (int n = 0; n < graph.length; n++)
      if (neighbors[n].length == 2) n,
  };
  final Set<(int, int)> edges = <(int, int)>{};
  // Tracks degree-2 nodes consumed while walking a chain, so leftover ones can
  // be detected as belonging to anchorless pure cycles afterwards.
  final Set<int> consumed = <int>{};

  /// Walks from a junction's neighbor through any degree-2 chain to the next
  /// junction (or back to a non-removed node), marking the beads consumed.
  /// Audited: 2026-06-12 11:26 EDT
  int walk(int fromPrev, int fromCur) {
    int prev = fromPrev;
    int cur = fromCur;
    while (removed.contains(cur)) {
      consumed.add(cur);
      // Step to the neighbor that is not where we came from; coinciding
      // neighbors (next == cur) mean a dead-end chain, so stop there.
      final int next = neighbors[cur].firstWhereOrNull((int x) => x != prev) ?? cur;
      if (next == cur) break;
      prev = cur;
      cur = next;
    }
    return cur;
  }

  // From every junction, emit one contracted edge per incident chain.
  for (int n = 0; n < graph.length; n++) {
    if (removed.contains(n)) continue;
    for (final int nb in neighbors[n]) {
      final int end = walk(n, nb);
      if (end != n) edges.add(n < end ? (n, end) : (end, n));
    }
  }
  // Preserve pure cycles: degree-2 nodes never reached from a junction.
  _preserveCycles(neighbors, removed, consumed, edges);
  return (edges: edges, removed: removed);
}

// Builds a deduplicated neighbor set per node, dropping self-loops.
List<Set<int>> _neighborSets(Adjacency graph) => <Set<int>>[
  for (int i = 0; i < graph.length; i++)
    <int>{
      for (final int j in graph[i])
        if (j != i) j,
    },
];

// Re-adds original edges for degree-2 nodes in anchorless cycles (a component
// with no junction). Without this their connectivity would vanish.
void _preserveCycles(
  List<Set<int>> neighbors,
  Set<int> removed,
  Set<int> consumed,
  Set<(int, int)> edges,
) {
  for (final int n in removed) {
    if (consumed.contains(n)) continue;
    for (final int nb in neighbors[n]) {
      edges.add(n < nb ? (n, nb) : (nb, n));
    }
  }
}
