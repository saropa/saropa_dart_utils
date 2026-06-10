/// Greedy bin packing (items into bins with capacities) — roadmap #475.
library;

/// Assigns each [itemWeights] to a bin; [capacity] per bin. Returns bin index per item (0-based).
List<int> firstFitBinPacking(List<num> itemWeights, num capacity) {
  // First-fit heuristic: place each item in the FIRST existing bin it fits;
  // if none fits, open a new bin. Not optimal (first-fit-decreasing does better
  // on pre-sorted input), but simple and order-preserving. `bins` holds each
  // bin's running load; `assign[i]` is item i's chosen bin index.
  final List<num> bins = <num>[];
  final List<int> assign = <int>[];
  for (final num w in itemWeights) {
    // Scan for the first bin with room; b lands past the end if none fits.
    int b = 0;
    while (b < bins.length && bins[b] + w > capacity) {
      b++;
    }
    if (b >= bins.length) bins.add(0);
    bins[b] = bins[b] + w;
    assign.add(b);
  }
  return assign;
}
