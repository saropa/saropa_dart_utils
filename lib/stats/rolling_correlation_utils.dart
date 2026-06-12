/// Rolling (sliding-window) Pearson correlation (roadmap #577).
///
/// Computes the Pearson correlation between two series within each window of
/// a fixed size as it slides one step at a time, revealing how the strength
/// of the relationship changes over the course of the data.
library;

import 'dart:math' show sqrt;

/// Pearson correlation of [x] and [y] over each sliding window of [window].
///
/// [x] and [y] must be the same length and [window] must be at least 2 (a
/// single point has no variance); both are enforced by assertions. The output
/// has length `x.length - window + 1`, and is empty when the series is shorter
/// than one window. Each entry is the correlation of the corresponding window,
/// or NaN where a window has zero variance (a constant run) and correlation is
/// undefined.
///
/// Example:
/// ```dart
/// rollingCorrelation(<num>[1, 2, 3, 4], <num>[2, 4, 6, 8], 3); // [1.0, 1.0]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<double> rollingCorrelation(List<num> x, List<num> y, int window) {
  assert(x.length == y.length, 'rollingCorrelation requires equal-length series');
  assert(window >= 2, 'rollingCorrelation requires window >= 2');
  // No full window fits, so there are no correlations to emit.
  if (x.length < window) return <double>[];
  final List<double> out = <double>[];
  for (int start = 0; start + window <= x.length; start++) {
    out.add(_windowCorrelation(x, y, start, window));
  }
  return out;
}

/// Single-pass Pearson correlation over `[start, start + window)`.
/// Audited: 2026-06-12 11:26 EDT
double _windowCorrelation(List<num> x, List<num> y, int start, int window) {
  double sumX = 0, sumY = 0, sumXX = 0, sumYY = 0, sumXY = 0;
  for (int i = start; i < start + window; i++) {
    final double xVal = x[i].toDouble();
    final double yVal = y[i].toDouble();
    sumX += xVal;
    sumY += yVal;
    sumXX += xVal * xVal;
    sumYY += yVal * yVal;
    sumXY += xVal * yVal;
  }
  final double n = window.toDouble();
  // Raw-sum form of cov / (sd*sd): the denominator factors are the
  // unnormalized variances of each window.
  final double numerator = sumXY - sumX * sumY / n;
  final double denominator = (sumXX - sumX * sumX / n) * (sumYY - sumY * sumY / n);
  // Zero/negative denominator means a constant window (zero variance) or
  // underflow; correlation is undefined.
  if (denominator <= 0) return double.nan;
  // Rounding can nudge the ratio just past +/-1; clamp to the valid range.
  return (numerator / sqrt(denominator)).clamp(-1.0, 1.0);
}
