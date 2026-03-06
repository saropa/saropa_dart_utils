/// Disjoint-set / union-find with path compression (roadmap #496).
library;

/// Union-find over integer elements 0 .. n-1.
class DisjointSet {
  DisjointSet(int n)
    : _parent = List<int>.generate(n, (int i) => i),
      _rank = List<int>.filled(n, 0);

  final List<int> _parent;
  final List<int> _rank;

  /// Representative (root) of the set containing [x].
  int find(int x) {
    if (_parent[x] != x) _parent[x] = find(_parent[x]);
    return _parent[x];
  }

  void union(int x, int y) {
    final int rootX = find(x);
    final int rootY = find(y);
    if (rootX == rootY) return;
    if (_rank[rootX] < _rank[rootY]) {
      _parent[rootX] = rootY;
    } else if (_rank[rootX] > _rank[rootY]) {
      _parent[rootY] = rootX;
    } else {
      _parent[rootY] = rootX;
      _rank[rootX]++;
    }
  }

  /// True if [x] and [y] are in the same set.
  bool connected(int x, int y) => find(x) == find(y);

  @override
  String toString() => 'DisjointSet(size: ${_parent.length})';
}
