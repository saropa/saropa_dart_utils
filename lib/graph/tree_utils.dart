/// Tree utilities (LCA, depth, subtree size) — roadmap #555.
library;

/// Parent array: entry at index i is the parent of node i; root has -1.
/// Audited: 2026-06-12 11:26 EDT
int lowestCommonAncestor(List<int> parent, int u, int v) {
  // Record every ancestor of u up to the root (a node is its own ancestor here),
  // following the parent links until -1 signals the root.
  final Set<int> path = <int>{};
  int nodeU = u;
  while (nodeU >= 0) {
    path.add(nodeU);
    nodeU = parent[nodeU];
  }
  // Walk v upward and return the first node already on u's path — by ascending
  // from v, that first hit is the deepest shared ancestor (the LCA). Reaching
  // the root without a match means u and v live in disjoint trees of a forest,
  // reported as -1.
  int nodeV = v;
  while (nodeV >= 0) {
    if (path.contains(nodeV)) return nodeV;
    nodeV = parent[nodeV];
  }
  return -1;
}

/// Returns depth of each node (root = 0). [parent] at index i is the parent of node i.
/// Audited: 2026-06-12 11:26 EDT
List<int> treeDepths(List<int> parent) {
  final List<int> depth = List.filled(parent.length, 0);
  for (int i = 0; i < parent.length; i++) {
    int d = 0;
    int p = parent[i];
    while (p >= 0) {
      d++;
      p = parent[p];
    }
    depth[i] = d;
  }
  return depth;
}
