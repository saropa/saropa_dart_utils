/// Robust statistics: MAD, trimmed mean (roadmap #561).
library;

/// Median of [values] (assumes non-empty; sorts a copy).
double median(List<num> values) {
  if (values.isEmpty) return double.nan;
  final List<num> sorted = List<num>.of(values)..sort();
  final int n = sorted.length;
  if (n.isOdd) return sorted[n ~/ 2].toDouble();
  return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
}

/// Median absolute deviation: median of |x_i - median(x)|.
double medianAbsoluteDeviation(List<num> values) {
  if (values.isEmpty) return double.nan;
  final double m = median(values);
  final List<double> abs = values.map((num x) => (x - m).abs().toDouble()).toList();
  return median(abs);
}

/// Trimmed mean: drop [trim] fraction from each tail (0..0.5), then average.
double trimmedMean(List<num> values, double trim) {
  if (values.isEmpty) return double.nan;
  if (trim <= 0) {
    return values.fold<double>(0, (double s, num v) => s + v.toDouble()) / values.length;
  }
  final List<num> sorted = List<num>.of(values)..sort();
  final int k = (sorted.length * trim.clamp(0.0, 0.5)).round();
  final int start = k;
  final int end = sorted.length - k;
  if (start >= end) return double.nan;
  double sum = 0;
  for (int i = start; i < end; i++) sum += sorted[i].toDouble();
  return sum / (end - start);
}
