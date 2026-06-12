/// N-way merge of multiple sorted iterables — roadmap #457.
library;

/// Merges [iterables] (each sorted by natural order) into one sorted list.
/// Audited: 2026-06-12 11:26 EDT
List<T> nWayMerge<T extends Comparable<Object>>(List<Iterable<T>> iterables) {
  if (iterables.isEmpty) return <T>[];
  // Classic k-way merge: keep one live cursor per source plus a `head` array of
  // each cursor's current front element (null once a source is exhausted).
  // Because every source is already sorted, the global next element is always
  // the smallest current head.
  final List<Iterator<T>> iters = iterables.map((Iterable<T> i) => i.iterator).toList();
  final List<T?> head = List<T?>.filled(iters.length, null);
  // Prime each head with its source's first element; empty sources stay null.
  for (int i = 0; i < iters.length; i++) {
    if (iters[i].moveNext()) head[i] = iters[i].current;
  }
  final List<T> out = <T>[];
  while (true) {
    // Linear scan for the smallest non-null head — O(k) per emitted element,
    // so this suits a modest number of sources rather than thousands.
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
    // No non-null head remains: every source is drained, so the merge is done.
    if (best < 0) break;
    final nextVal = head[best];
    if (nextVal == null) break;
    // Emit the winner, then refill only that source's head by one step.
    out.add(nextVal);
    head[best] = iters[best].moveNext() ? iters[best].current : null;
  }
  return out;
}
