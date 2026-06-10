/// Per-key descriptive statistics over an iterable — roadmap #571.
///
/// Where `aggregateByKeys` (collections) takes a custom reducer, this computes
/// the common numeric bundle — count, sum, min, max, mean — for every group in
/// a single pass. The frequent "totals and averages per category" report
/// without writing the reducer each time.
library;

import 'package:meta/meta.dart';

/// Descriptive statistics for one group of numeric values.
@immutable
class NumericStats {
  /// Creates a stat bundle. Built by [groupedStats]; every field is derived
  /// from at least one value, so [count] is always ≥ 1.
  const NumericStats({
    required this.count,
    required this.sum,
    required this.min,
    required this.max,
    required this.mean,
  });

  /// Number of values in the group (≥ 1).
  final int count;

  /// Sum of the values.
  final double sum;

  /// Smallest value.
  final num min;

  /// Largest value.
  final num max;

  /// Arithmetic mean (`sum / count`).
  final double mean;

  @override
  bool operator ==(Object other) =>
      other is NumericStats &&
      other.count == count &&
      other.sum == sum &&
      other.min == min &&
      other.max == max &&
      other.mean == mean;

  @override
  int get hashCode => Object.hash(count, sum, min, max, mean);

  @override
  String toString() => 'NumericStats(count: $count, sum: $sum, min: $min, max: $max, mean: $mean)';
}

/// Mutable single-group accumulator. [min]/[max] are seeded to 0 only to
/// satisfy non-null typing; the first [add] overwrites both before they are
/// ever read, so the seed is never observed.
class _Acc {
  int count = 0;
  double sum = 0;
  num min = 0;
  num max = 0;

  void add(num value) {
    // Streaming accumulation (one pass, no stored values). The first value seeds
    // min and max directly — they start at 0, which would be wrong for an all-
    // negative or all-positive series, so the count==0 case must not compare.
    if (count == 0) {
      min = value;
      max = value;
    } else {
      if (value < min) min = value;
      if (value > max) max = value;
    }
    count++;
    sum += value;
  }

  NumericStats toStats() =>
      NumericStats(count: count, sum: sum, min: min, max: max, mean: sum / count);
}

/// Groups [items] by [keyOf] and computes a [NumericStats] bundle over
/// [valueOf] for each group, in a single pass. A key appears only if at least
/// one item maps to it, so every returned [NumericStats] has `count ≥ 1` (no
/// divide-by-zero in `mean`). Insertion order of first-seen keys is preserved.
///
/// Example:
/// ```dart
/// groupedStats(rows, keyOf: (r) => r.country, valueOf: (r) => r.sales);
/// // {US: NumericStats(count: 2, sum: 15, min: 5, max: 10, mean: 7.5), ...}
/// ```
Map<K, NumericStats> groupedStats<T, K>(
  Iterable<T> items, {
  required K Function(T) keyOf,
  required num Function(T) valueOf,
}) {
  final Map<K, _Acc> accumulators = <K, _Acc>{};
  for (final T item in items) {
    accumulators.putIfAbsent(keyOf(item), () => _Acc()).add(valueOf(item));
  }
  return accumulators.map(
    (K key, _Acc acc) => MapEntry<K, NumericStats>(key, acc.toStats()),
  );
}
