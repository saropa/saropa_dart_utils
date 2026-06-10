/// Balanced partitioning (K partitions with similar sums) — roadmap #474.
library;

/// Greedy: assign each element of [values] to current smallest partition. Returns partition indices per element.
List<int> balancedPartitionIndices(List<num> values, int k) {
  if (k < 1 || values.isEmpty) return <int>[];
  // Greedy multiway partition: track each bucket's running total and drop every
  // value into the currently-lightest bucket. This is a fast heuristic (not
  // guaranteed optimal), and it is order-sensitive — sort values descending
  // first for the standard "longest processing time" quality.
  final List<double> sums = List.filled(k, 0.0);
  final List<int> assign = List.filled(values.length, 0);
  for (int i = 0; i < values.length; i++) {
    // Pick the bucket with the smallest current sum.
    int best = 0;
    for (int j = 1; j < k; j++) {
      if (sums[j] < sums[best]) best = j;
    }
    assign[i] = best;
    sums[best] += values[i].toDouble();
  }
  return assign;
}
