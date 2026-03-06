/// Minimum spanning tree (Kruskal) — roadmap #538.
library;

import 'package:saropa_dart_utils/collections/disjoint_set_utils.dart';
import 'graph_utils.dart';

/// MST from [edges] (GraphUtils); returns (mst edges, total cost).
(List<GraphUtils> edges, double cost) kruskalMST(int nodeCount, List<GraphUtils> edges) {
  final List<GraphUtils> sorted = List<GraphUtils>.of(edges)..sort((a, b) => a.weight.compareTo(b.weight));
  final DisjointSetUtils ds = DisjointSetUtils(nodeCount);
  final List<GraphUtils> mst = [];
  double cost = 0;
  for (final GraphUtils e in sorted) {
    if (ds.connected(e.from, e.to)) continue;
    ds.union(e.from, e.to);
    mst.add(e);
    cost += e.weight;
  }
  return (mst, cost);
}
