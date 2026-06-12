/// DAG-based task scheduler (topological + priorities) — roadmap #558.
library;

import 'graph_utils.dart';

/// Returns a schedule (list of node indices) respecting topology; among nodes
/// that are simultaneously ready (all dependencies done), [priority] lower =
/// earlier. Returns an empty list when [graph] has a cycle.
///
/// Priority is applied ONLY as a tiebreaker within each ready set, never across
/// the whole order — sorting the full topological order by priority (the old
/// behavior) could place a dependency after its dependent and break topology.
/// This runs Kahn's algorithm and, when [priority] is given, picks the
/// lowest-priority node among those currently ready at each step.
/// Audited: 2026-06-12 11:26 EDT
List<int> dagSchedule(Adjacency graph, [int Function(int)? priority]) {
  final int n = graph.length;
  final List<int> inDegree = List<int>.filled(n, 0);
  for (final List<int> successors in graph) {
    for (final int v in successors) {
      inDegree[v]++;
    }
  }
  // `ready` holds every node whose dependencies are all emitted; it is the only
  // place a topologically-valid next pick can come from.
  final List<int> ready = <int>[
    for (int i = 0; i < n; i++)
      if (inDegree[i] == 0) i,
  ];
  final List<int> schedule = <int>[];
  while (ready.isNotEmpty) {
    // Pick the lowest-priority ready node next. Dart's List.sort is NOT stable,
    // so break ties on the node index explicitly to keep a deterministic
    // ascending-index order among equal priorities (what callers expect).
    if (priority != null) {
      ready.sort((int a, int b) {
        final int byPriority = priority(a).compareTo(priority(b));
        return byPriority != 0 ? byPriority : a.compareTo(b);
      });
    }
    final int u = ready.removeAt(0);
    schedule.add(u);
    for (final int v in graph[u]) {
      if (--inDegree[v] == 0) ready.add(v);
    }
  }
  // A short schedule means some nodes never became ready: the graph has a cycle.
  return schedule.length == n ? schedule : <int>[];
}
