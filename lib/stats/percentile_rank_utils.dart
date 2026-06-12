/// Percentile rank and inverse percentile — roadmap #583.
library;

/// Percentile rank of [value] in [sorted] (0..1). Assumes [sorted] is sorted ascending.
/// Audited: 2026-06-12 11:26 EDT
double percentileRank(List<num> sorted, num value) {
  if (sorted.isEmpty) return double.nan;
  // Fraction of values strictly below `value`. Relies on the input being sorted
  // ascending: once an element is >= value, all later ones are too, so the scan
  // can stop early. Result is in 0..1 (count of smaller elements over total).
  int count = 0;
  for (final num x in sorted) {
    if (x < value) {
      count++;
    } else {
      break;
    }
  }
  return count / sorted.length;
}

/// Value at percentile [p] (0..1) in [sorted].
/// Audited: 2026-06-12 11:26 EDT
double percentile(List<num> sorted, double p) {
  if (sorted.isEmpty) return double.nan;
  final int i = (p * (sorted.length - 1)).round().clamp(0, sorted.length - 1);
  return sorted[i].toDouble();
}
