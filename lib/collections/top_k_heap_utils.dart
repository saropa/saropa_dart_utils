/// Top-K by key via min-heap — roadmap #459.
library;

import 'package:collection/collection.dart';

/// Returns indices of top [k] elements in [values] by [keyOf] (largest first).
List<int> topKIndices<T>(List<T> values, int k, num Function(T) keyOf) {
  if (values.isEmpty || k < 1) return <int>[];
  // Everything qualifies when there are at most k elements — return all indices.
  if (values.length <= k) return List.generate(values.length, (i) => i);
  // Keep a bounded buffer of the k best (index, key) pairs seen so far, sorted
  // ascending so its front is the current k-th best (the eviction threshold).
  // Holding only k entries keeps memory O(k) rather than sorting all values.
  final List<(int, num)> heap = <(int, num)>[];
  const int rootIndex = 0;
  for (int i = 0; i < values.length; i++) {
    final num key = keyOf(values[i]);
    final (int, num)? heapMin = heap.firstOrNull;
    if (heap.length < k) {
      // Still filling: accept freely, and sort once it first reaches size k so
      // the smallest sits at the front for the eviction comparisons below.
      heap.add((i, key));
      if (heap.length == k) heap.sort((a, b) => a.$2.compareTo(b.$2));
    } else if (heapMin != null && key > heapMin.$2) {
      // Full and this beats the weakest kept: replace the front and re-sort to
      // restore the smallest-first invariant.
      heap[rootIndex] = (i, key);
      heap.sort((a, b) => a.$2.compareTo(b.$2));
    }
  }
  return heap.map((e) => e.$1).toList();
}
