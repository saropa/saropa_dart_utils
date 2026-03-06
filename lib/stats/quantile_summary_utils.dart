/// Quantile summary (percentiles, median, quartiles) — roadmap #572.
library;

import 'package:collection/collection.dart';

/// Pre-computed quantile summary for a list of numbers.
class QuantileSummaryUtils {
  QuantileSummaryUtils(List<num> values)
    : _sorted = List<double>.of(values.map((num x) => x.toDouble()))..sort();

  final List<double> _sorted;

  double quantile(double p) {
    if (_sorted.isEmpty) return double.nan;
    if (p <= 0) return _sorted.firstOrNull ?? double.nan;
    if (p >= 1) return _sorted.lastOrNull ?? double.nan;
    final double idx = (_sorted.length - 1) * p;
    final int i = idx.floor().clamp(0, _sorted.length - 1);
    return _sorted[i];
  }

  double get min => _sorted.isEmpty ? double.nan : _sorted.first;

  double get max => _sorted.isEmpty ? double.nan : _sorted.last;

  double get median => quantile(0.5);

  double get q1 => quantile(0.25);

  double get q3 => quantile(0.75);

  @override
  String toString() => 'QuantileSummaryUtils(count: ${_sorted.length}, min: $min, max: $max)';
}
