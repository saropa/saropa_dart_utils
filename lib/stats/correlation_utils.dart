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
  final double numerator = sumXY - sumX * sumY / nDouble;
  final double denominator = (sumXX - sumXSq / nDouble) * (sumYY - sumYSq / nDouble);
  if (denominator <= 0) return double.nan;
  final double r = numerator / sqrt(denominator);
  return r.clamp(-1.0, 1.0);
}
