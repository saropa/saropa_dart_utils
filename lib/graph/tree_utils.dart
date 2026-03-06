/// Tree utilities (LCA, depth, subtree size) — roadmap #555.
library;

/// Parent array: entry at index i is the parent of node i; root has -1.
int lowestCommonAncestor(List<int> parent, int u, int v) {
  final Set<int> path = <int>{};
  int nodeU = u;
  while (nodeU >= 0) {
    path.add(nodeU);
    nodeU = parent[nodeU];
  }
  int nodeV = v;
  while (nodeV >= 0) {
    if (path.contains(nodeV)) return nodeV;
    nodeV = parent[nodeV];
  }
  return -1;
}

/// Returns depth of each node (root = 0). [parent] at index i is the parent of node i.
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
