/// BFS/DFS traversal with hooks (roadmap #532).
library;

import 'graph_utils.dart';

/// BFS from [start]; calls [visit](node, depth) for each node. [maxDepth] caps depth (-1 = no limit).
void bfs(
  Adjacency graph,
  int start,
  void Function(int node, int depth) visit, {
  int maxDepth = -1,
}) {
  final List<bool> seen = List.filled(graph.length, false);
  final List<(int, int)> queue = <(int, int)>[(start, 0)];
  seen[start] = true;
  while (queue.isNotEmpty) {
    final (int u, int d) = queue.removeAt(0);
    visit(u, d);
    if (maxDepth >= 0 && d >= maxDepth) continue;
    for (final int v in graph[u]) {
      if (!seen[v]) {
        seen[v] = true;
        queue.add((v, d + 1));
      }
    }
  }
}

/// DFS from [start]; calls [visit](node, depth). [maxDepth] caps depth (-1 = no limit).
void dfs(
  Adjacency graph,
  int start,
  void Function(int node, int depth) visit, {
  int maxDepth = -1,
}) {
  final List<bool> seen = List.filled(graph.length, false);
  void go(int u, int d) {
    if (seen[u]) return;
    seen[u] = true;
    visit(u, d);
    if (maxDepth >= 0 && d >= maxDepth) return;
    for (final int v in graph[u]) go(v, d + 1);
  }

  go(start, 0);
}
