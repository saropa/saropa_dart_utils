/// Top-K by key via min-heap — roadmap #459.
library;

import 'package:collection/collection.dart';

/// Returns indices of top [k] elements in [values] by [keyOf] (largest first).
List<int> topKIndices<T>(List<T> values, int k, num Function(T) keyOf) {
  if (values.isEmpty || k < 1) return [];
  if (values.length <= k) return List.generate(values.length, (i) => i);
  final List<(int, num)> heap = [];
  const int rootIndex = 0;
  for (int i = 0; i < values.length; i++) {
    final num key = keyOf(values[i]);
    final (int, num)? heapMin = heap.firstOrNull;
    if (heap.length < k) {
      heap.add((i, key));
      if (heap.length == k) heap.sort((a, b) => a.$2.compareTo(b.$2));
    } else if (heapMin != null && key > heapMin.$2) {
      heap[rootIndex] = (i, key);
      heap.sort((a, b) => a.$2.compareTo(b.$2));
    }
  }
  return heap.map((e) => e.$1).toList();
}
