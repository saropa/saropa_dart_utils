/// N-way merge of multiple sorted iterables — roadmap #457.
library;

/// Merges [iterables] (each sorted by natural order) into one sorted list.
List<T> nWayMerge<T extends Comparable<Object>>(List<Iterable<T>> iterables) {
  if (iterables.isEmpty) return <T>[];
  final List<Iterator<T>> iters = iterables.map((Iterable<T> i) => i.iterator).toList();
  final List<T?> head = List<T?>.filled(iters.length, null);
  for (int i = 0; i < iters.length; i++) {
    if (iters[i].moveNext()) head[i] = iters[i].current;
  }
  final List<T> out = <T>[];
  while (true) {
    int best = -1;
    for (int i = 0; i < head.length; i++) {
      final headAtI = head[i];
      if (headAtI == null) continue;
      if (best < 0) {
        best = i;
      } else {
        final headAtBest = head[best];
        if (headAtBest != null && headAtI.compareTo(headAtBest) < 0) best = i;
      }
    }
    if (best < 0) break;
    final nextVal = head[best];
    if (nextVal == null) break;
    out.add(nextVal);
    head[best] = iters[best].moveNext() ? iters[best].current : null;
  }
  return out;
}
