/// Graph representation helpers: adjacency list / weighted edges (roadmap #531).
library;

/// Weighted directed edge.
class GraphUtils {
  /// Creates a directed edge from node [from] to node [to] with optional
  /// [weight] (defaults to 1.0).
  /// Audited: 2026-06-12 11:26 EDT
  const GraphUtils(int from, int to, [double weight = 1.0])
    : _from = from,
      _to = to,
      _weight = weight;
  final int _from;

  /// Source node index.
  /// Audited: 2026-06-12 11:26 EDT
  int get from => _from;
  final int _to;

  /// Target node index.
  /// Audited: 2026-06-12 11:26 EDT
  int get to => _to;
  final double _weight;

  /// Edge weight (cost).
  /// Audited: 2026-06-12 11:26 EDT
  double get weight => _weight;

  @override
  String toString() => 'GraphUtils(from: $_from, to: $_to, weight: $_weight)';
}

/// Adjacency list: for each node, list of (neighbor, weight).
typedef WeightedAdjacency = List<List<(int, double)>>;

/// Builds [WeightedAdjacency] from [edges]; [nodeCount] = max node index + 1.
/// Audited: 2026-06-12 11:26 EDT
WeightedAdjacency buildWeightedGraph(List<GraphUtils> edges, int nodeCount) {
  final WeightedAdjacency adj = List.generate(nodeCount, (_) => <(int, double)>[]);
  for (final GraphUtils e in edges) {
    if (e.from >= 0 && e.from < nodeCount && e.to >= 0 && e.to < nodeCount) {
      adj[e.from].add((e.to, e.weight));
    }
  }
  return adj;
}

/// Unweighted: list of neighbors per node.
typedef Adjacency = List<List<int>>;

/// Builds an unweighted [Adjacency] list from [edges], where [nodeCount] is the
/// max node index + 1. Edges referencing out-of-range nodes are skipped.
///
/// Example:
/// ```dart
/// buildGraph([(0, 1), (1, 2)], 3); // [[1], [2], []]
/// ```
/// Audited: 2026-06-12 11:26 EDT
Adjacency buildGraph(List<(int, int)> edges, int nodeCount) {
  final Adjacency adj = List.generate(nodeCount, (_) => <int>[]);
  for (final (int u, int v) in edges) {
    if (u >= 0 && u < nodeCount && v >= 0 && v < nodeCount) {
      adj[u].add(v);
    }
  }
  return adj;
}
