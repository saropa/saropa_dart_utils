/// Histogram builder with fixed and quantile-based bins — roadmap #473.
library;

/// Build histogram: [values] binned by [edges] (sorted). Returns count per bin; edges.length - 1 bins.
List<int> histogramFixed(List<num> values, List<num> edges) {
  // n edges define n-1 bins; counts[i] tallies values in [edges[i], edges[i+1]).
  if (edges.length < 2) return <int>[];
  final List<int> counts = List.filled(edges.length - 1, 0);
  for (final num v in values) {
    // Find the first bin the value falls in. Bins are half-open on the right
    // EXCEPT the last, which is closed so a value equal to the top edge still
    // lands in the final bin rather than being dropped.
    for (int i = 0; i < edges.length - 1; i++) {
      if (v >= edges[i] && (i == edges.length - 2 ? v <= edges[i + 1] : v < edges[i + 1])) {
        counts[i]++;
        break;
      }
    }
  }
  return counts;
}

/// Bin boundaries at quantiles (e.g. 0, 0.25, 0.5, 0.75, 1). [quantiles] in [0,1], sorted.
List<int> histogramQuantile(List<num> values, List<double> quantiles) {
  if (values.isEmpty || quantiles.length < 2) return <int>[];
  final List<num> sorted = List<num>.of(values)..sort();
  final List<num> edges = quantiles.map((double q) {
    final double idx = (sorted.length - 1) * q;
    final int i = idx.floor().clamp(0, sorted.length - 1);
    return sorted[i];
  }).toList();
  return histogramFixed(values, edges);
}
