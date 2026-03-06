/// Greedy bin packing (items into bins with capacities) — roadmap #475.
library;

/// Assigns each [itemWeights] to a bin; [capacity] per bin. Returns bin index per item (0-based).
List<int> firstFitBinPacking(List<num> itemWeights, num capacity) {
  final List<num> bins = [];
  final List<int> assign = [];
  for (final num w in itemWeights) {
    int b = 0;
    while (b < bins.length && bins[b] + w > capacity) b++;
    if (b >= bins.length) bins.add(0);
    bins[b] = bins[b] + w;
    assign.add(b);
  }
  return assign;
}
