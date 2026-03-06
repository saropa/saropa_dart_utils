/// Graph representation helpers: adjacency list / weighted edges (roadmap #531).
library;

/// Weighted directed edge.
class Edge {
  const Edge(int from, int to, [double weight = 1.0]) : _from = from, _to = to, _weight = weight;
  final int _from;

  /// Source node index.
  int get from => _from;
  final int _to;

  /// Target node index.
  int get to => _to;
  final double _weight;

  /// Edge weight (cost).
  double get weight => _weight;

  @override
  String toString() => 'Edge(from: $_from, to: $_to, weight: $_weight)';
}

/// Adjacency list: for each node, list of (neighbor, weight).
typedef WeightedAdjacency = List<List<(int, double)>>;

/// Builds [WeightedAdjacency] from [edges]; [nodeCount] = max node index + 1.
WeightedAdjacency buildWeightedGraph(List<Edge> edges, int nodeCount) {
  final WeightedAdjacency adj = List.generate(nodeCount, (_) => <(int, double)>[]);
  for (final Edge e in edges) {
    if (e.from >= 0 && e.from < nodeCount && e.to >= 0 && e.to < nodeCount) {
      adj[e.from].add((e.to, e.weight));
    }
  }
  return adj;
}

/// Unweighted: list of neighbors per node.
typedef Adjacency = List<List<int>>;

Adjacency buildGraph(List<(int, int)> edges, int nodeCount) {
  final Adjacency adj = List.generate(nodeCount, (_) => <int>[]);
  for (final (int u, int v) in edges) {
    if (u >= 0 && u < nodeCount && v >= 0 && v < nodeCount) {
      adj[u].add(v);
    }
  }
  return adj;
}
