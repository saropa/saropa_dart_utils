/// Transitive closure / reachability of a directed graph (roadmap #551).
///
/// Answers "which nodes can node i eventually get to" by running a traversal
/// from every node. A node appears in its OWN reachable set only when it lies
/// on a cycle (there is a non-trivial path leading back to itself), since
/// reachability here means "via one or more edges", never the trivial zero-hop.
library;

import 'graph_utils.dart';

/// For each node, the set of nodes reachable from it via one or more edges.
///
/// `result[i]` excludes `i` unless `i` can return to itself through a cycle, so
/// a self-loop or any back-path puts `i` in its own set. The traversal explores
/// each node's descendants with BFS, so even cyclic graphs terminate.
///
/// Example:
/// ```dart
/// final Adjacency g = buildGraph([(0, 1), (1, 2)], 3);
/// reachabilitySets(g); // [{1, 2}, {2}, {}]
/// ```
List<Set<int>> reachabilitySets(Adjacency graph) => <Set<int>>[
  for (int i = 0; i < graph.length; i++) _reachableFrom(graph, i),
];

/// Boolean reachability matrix consistent with [reachabilitySets].
///
/// `matrix[i][j]` is true exactly when node j is reachable from node i via one
/// or more edges, so the diagonal is true only for nodes on a cycle.
List<List<bool>> reachabilityMatrix(Adjacency graph) {
  final int n = graph.length;
  final List<Set<int>> sets = reachabilitySets(graph);
  // Project each reachable set onto a dense row so callers can index by (i, j).
  return <List<bool>>[
    for (int i = 0; i < n; i++) <bool>[for (int j = 0; j < n; j++) sets[i].contains(j)],
  ];
}

/// Whether node [to] is reachable from node [from] via one or more edges.
///
/// Returns false for out-of-range endpoints. `from == to` is true only when a
/// genuine path leads back, never trivially, matching [reachabilitySets].
bool canReach(Adjacency graph, int from, int to) {
  // Validate endpoints before traversing so an out-of-range query is a clean
  // false rather than a range error inside the BFS.
  if (from < 0 || from >= graph.length) return false;
  if (to < 0 || to >= graph.length) return false;
  return _reachableFrom(graph, from).contains(to);
}

/// BFS collecting every node reachable from [source] (source excluded unless on
/// a cycle that leads back to it).
Set<int> _reachableFrom(Adjacency graph, int source) {
  final Set<int> reached = <int>{};
  // Seed the queue with source's direct successors, NOT source itself, so source
  // only enters `reached` if a path actually loops back to it.
  final List<int> queue = List<int>.of(graph[source]);
  while (queue.isNotEmpty) {
    final int u = queue.removeLast();
    // add returns false when u was already present, which prevents re-queuing
    // and guarantees termination on cyclic graphs.
    if (reached.add(u)) {
      // Push u's successors onto the frontier one at a time; the visited check
      // above keeps the queue finite even when the graph contains cycles.
      for (final int v in graph[u]) {
        queue.add(v);
      }
    }
  }
  return reached;
}
