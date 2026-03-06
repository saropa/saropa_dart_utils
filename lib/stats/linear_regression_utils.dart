/// Simple linear regression — roadmap #564.
library;

import 'dart:math' show pow;

/// Simple linear regression y ~ x. Returns (slope, intercept).
(double slope, double intercept) linearRegression(List<num> x, List<num> y) {
  if (x.length != y.length || x.length < 2) return (double.nan, double.nan);
  final int n = x.length;
  double sumX = 0, sumY = 0, sumXX = 0, sumXY = 0;
  for (int i = 0; i < n; i++) {
    final double xVal = x[i].toDouble();
    final double yVal = y[i].toDouble();
    sumX += xVal;
    sumY += yVal;
    sumXX += pow(xVal, 2).toDouble();
    sumXY += xVal * yVal;
  }
  final double nDouble = n.toDouble();
  final double denom = n * sumXX - pow(sumX, 2).toDouble();
  if (denom == 0) return (double.nan, double.nan);
  final double slope = (n * sumXY - sumX * sumY) / denom;
  final double intercept = (sumY - slope * sumX) / nDouble;
  return (slope, intercept);
}
