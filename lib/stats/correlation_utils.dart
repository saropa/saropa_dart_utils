/// Correlation coefficients (Pearson) — roadmap #563.
library;

import 'dart:math' show pow, sqrt;

/// Pearson correlation between [x] and [y]. Returns value in [-1, 1] or NaN if insufficient data.
double pearsonCorrelation(List<num> x, List<num> y) {
  if (x.length != y.length || x.length < 2) return double.nan;
  final int n = x.length;
  double sumX = 0, sumY = 0, sumXX = 0, sumYY = 0, sumXY = 0;
  for (int i = 0; i < n; i++) {
    final double xVal = x[i].toDouble();
    final double yVal = y[i].toDouble();
    sumX += xVal;
    sumY += yVal;
    final double xValSq = pow(xVal, 2).toDouble();
    final double yValSq = pow(yVal, 2).toDouble();
    sumXX += xValSq;
    sumYY += yValSq;
    sumXY += xVal * yVal;
  }
  final double nDouble = n.toDouble();
  final double sumXSq = pow(sumX, 2).toDouble();
  final double sumYSq = pow(sumY, 2).toDouble();
  // Single-pass computational form: r = cov(x,y) / (sd(x)*sd(y)) rewritten in
  // terms of raw sums so the data is traversed only once. The numerator is the
  // unnormalized covariance; the denominator factors are the unnormalized variances.
  final double numerator = sumXY - sumX * sumY / nDouble;
  final double denominator = (sumXX - sumXSq / nDouble) * (sumYY - sumYSq / nDouble);
  // Zero or negative denominator means a constant series (zero variance) or
  // floating-point underflow; correlation is undefined, so return NaN.
  if (denominator <= 0) return double.nan;
  final double r = numerator / sqrt(denominator);
  // Rounding in the running sums can nudge r just past ±1; clamp to the valid range.
  return r.clamp(-1.0, 1.0);
}
