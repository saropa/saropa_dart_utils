/// Minimum spanning tree (Kruskal) — roadmap #538.
library;

import 'package:saropa_dart_utils/collections/disjoint_set_utils.dart';
import 'graph_utils.dart';

/// Edge for MST: (from, to, weight).
(List<Edge> edges, double cost) kruskalMST(int nodeCount, List<Edge> edges) {
  final List<Edge> sorted = List<Edge>.of(edges)..sort((a, b) => a.weight.compareTo(b.weight));
  final DisjointSet ds = DisjointSet(nodeCount);
  final List<Edge> mst = [];
  double cost = 0;
  for (final Edge e in sorted) {
    if (ds.connected(e.from, e.to)) continue;
    ds.union(e.from, e.to);
    mst.add(e);
    cost += e.weight;
  }
  return (mst, cost);
}
