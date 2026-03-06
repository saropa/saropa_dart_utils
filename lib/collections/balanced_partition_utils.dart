/// Balanced partitioning (K partitions with similar sums) — roadmap #474.
library;

/// Greedy: assign each element of [values] to current smallest partition. Returns partition indices per element.
List<int> balancedPartitionIndices(List<num> values, int k) {
  if (k < 1 || values.isEmpty) return [];
  final List<double> sums = List.filled(k, 0.0);
  final List<int> assign = List.filled(values.length, 0);
  for (int i = 0; i < values.length; i++) {
    int best = 0;
    for (int j = 1; j < k; j++) {
      if (sums[j] < sums[best]) best = j;
    }
    assign[i] = best;
    sums[best] += values[i].toDouble();
  }
  return assign;
}
