/// Confidence interval for mean (normal approximation) — roadmap #562.
library;

import 'dart:math' show pow, sqrt;

/// Approximate 95% CI for mean: (lower, upper). [values] sample, [z] e.g. 1.96 for 95%.
(double lower, double upper) confidenceInterval95(List<num> values, {double z = 1.96}) {
  if (values.length < 2) return (double.nan, double.nan);
  final double mean = values.fold<double>(0, (s, x) => s + x.toDouble()) / values.length;
  final double variance =
      values.fold<double>(0, (s, x) {
        final d = x.toDouble() - mean;
        return s + pow(d, 2).toDouble();
      }) /
      (values.length - 1);
  final double se = sqrt(variance / values.length);
  return (mean - z * se, mean + z * se);
}
