/// Data normalization (z-score, min-max scaling) — roadmap #576.
library;

import 'dart:math' show pow, sqrt;

/// Z-score: (x - mean) / stdDev. Returns new list.
List<double> zScoreNormalize(List<num> values) {
  if (values.isEmpty) return <double>[];
  final double mean = values.fold<double>(0, (s, x) => s + x.toDouble()) / values.length;
  final double variance =
      values.fold<double>(0, (s, x) {
        final d = x.toDouble() - mean;
        return s + pow(d, 2).toDouble();
      }) /
      values.length;
  final double std = variance > 0 ? sqrt(variance) : 1.0;
  return values.map((num x) => (x.toDouble() - mean) / std).toList();
}

/// Min-max scale to [low, high]. Returns new list.
List<double> minMaxScale(List<num> values, {double low = 0.0, double high = 1.0}) {
  if (values.isEmpty) return <double>[];
  final doubles = values.map((num x) => x.toDouble()).toList();
  final double minV = doubles.fold(double.infinity, (a, b) => a < b ? a : b);
  final double maxV = doubles.fold(double.negativeInfinity, (a, b) => a > b ? a : b);
  if (maxV == minV) return List.filled(values.length, (low + high) / 2);
  return values.map((num x) => low + (x.toDouble() - minV) / (maxV - minV) * (high - low)).toList();
}
