/// Percentile rank and inverse percentile — roadmap #583.
library;

/// Percentile rank of [value] in [sorted] (0..1). Assumes [sorted] is sorted ascending.
double percentileRank(List<num> sorted, num value) {
  if (sorted.isEmpty) return double.nan;
  int count = 0;
  for (final num x in sorted) {
    if (x < value)
      count++;
    else
      break;
  }
  return count / sorted.length;
}

/// Value at percentile [p] (0..1) in [sorted].
double percentile(List<num> sorted, double p) {
  if (sorted.isEmpty) return double.nan;
  final int i = (p * (sorted.length - 1)).round().clamp(0, sorted.length - 1);
  return sorted[i].toDouble();
}
