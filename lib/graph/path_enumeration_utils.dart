/// Enumerate all simple paths between two nodes (roadmap #543).
///
/// A simple path visits no node more than once, so even cyclic graphs yield a
/// finite set of paths and the DFS can never loop forever. Beware: the number
/// of simple paths can grow exponentially, so bound dense graphs with
/// [enumeratePaths]'s `maxDepth`.
library;

import 'graph_utils.dart';

/// Every simple path from [start] to [target], each path a node-index list.
///
/// A simple path repeats no node, so cycles in [graph] cannot cause infinite
/// recursion. `maxDepth`, when set, caps the number of EDGES in a path (a path
/// of k nodes has k-1 edges); paths needing more edges are pruned. When
/// `start == target` the single zero-edge path `[[start]]` is returned. Out-of-
/// range [start] or [target] yields an empty list.
///
/// Example:
/// ```dart
/// final Adjacency g = buildGraph([(0, 1), (0, 2), (1, 2)], 3);
/// enumeratePaths(g, 0, 2); // [[0, 2], [0, 1, 2]]
/// ```
List<List<int>> enumeratePaths(
  Adjacency graph,
  int start,
  int target, {
  int? maxDepth,
}) {
  // Guard out-of-range endpoints up front so the DFS can index graph safely.
  if (start < 0 || start >= graph.length) return <List<int>>[];
  if (target < 0 || target >= graph.length) return <List<int>>[];
  final List<List<int>> paths = <List<int>>[];
  final List<bool> onPath = List<bool>.filled(graph.length, false);
  final List<int> current = <int>[];
  _walk(graph, start, target, maxDepth, onPath, current, paths);
  return paths;
}

/// DFS that records [current] whenever it reaches [target] as a simple path.
void _walk(
  Adjacency graph,
  int node,
  int target,
  int? maxDepth,
  List<bool> onPath,
  List<int> current,
  List<List<int>> paths,
) {
  // Push node onto the active path; onPath marks it so we never revisit it,
  // which is what keeps every enumerated path simple and the recursion finite.
  onPath[node] = true;
  current.add(node);
  // Reaching the target completes a path; snapshot it (current is mutated later).
  if (node == target) {
    paths.add(List<int>.of(current));
  } else if (maxDepth == null || current.length - 1 < maxDepth) {
    // Only descend while we still have edge budget; current.length-1 is the
    // edges used so far, so this caps the path at maxDepth edges.
    for (final int v in graph[node]) {
      if (!onPath[v]) {
        _walk(graph, v, target, maxDepth, onPath, current, paths);
      }
    }
  }
  // Backtrack: free node for sibling branches that may legitimately reuse it.
  onPath[node] = false;
  current.removeLast();
}
