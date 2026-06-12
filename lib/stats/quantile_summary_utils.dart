/// Quantile summary (percentiles, median, quartiles) — roadmap #572.
library;

import 'package:collection/collection.dart';

/// Pre-computed quantile summary for a list of numbers.
class QuantileSummaryUtils {
  /// Builds a summary from [values], sorting a copy once for repeated queries.
  /// Audited: 2026-06-12 11:26 EDT
  QuantileSummaryUtils(List<num> values)
    : _sorted = List<double>.of(values.map((num x) => x.toDouble()))..sort();

  final List<double> _sorted;

  /// Returns the value at quantile [p] (0.0–1.0).
  ///
  /// Uses nearest-rank selection on the sorted data. Values of [p] outside the
  /// range are clamped to the min ([p] <= 0) or max ([p] >= 1). Returns
  /// [double.nan] when there are no values.
  ///
  /// Example:
  /// ```dart
  /// QuantileSummaryUtils([1, 2, 3, 4]).quantile(0.5); // 2.0
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  double quantile(double p) {
    if (_sorted.isEmpty) return double.nan;
    if (p <= 0) return _sorted.firstOrNull ?? double.nan;
    if (p >= 1) return _sorted.lastOrNull ?? double.nan;
    final double idx = (_sorted.length - 1) * p;
    final int i = idx.floor().clamp(0, _sorted.length - 1);
    return _sorted[i];
  }

  /// Smallest value, or [double.nan] when there are no values.
  /// Audited: 2026-06-12 11:26 EDT
  double get min => _sorted.isEmpty ? double.nan : _sorted.first;

  /// Largest value, or [double.nan] when there are no values.
  /// Audited: 2026-06-12 11:26 EDT
  double get max => _sorted.isEmpty ? double.nan : _sorted.last;

  /// The median (50th percentile).
  /// Audited: 2026-06-12 11:26 EDT
  double get median => quantile(0.5);

  /// The first quartile (25th percentile).
  /// Audited: 2026-06-12 11:26 EDT
  double get q1 => quantile(0.25);

  /// The third quartile (75th percentile).
  /// Audited: 2026-06-12 11:26 EDT
  double get q3 => quantile(0.75);

  @override
  String toString() => 'QuantileSummaryUtils(count: ${_sorted.length}, min: $min, max: $max)';
}
