/// Empirical CDF and cumulative histogram for numeric samples — roadmap #574.
///
/// Complements the bin-counting `histogramFixed`/`histogramQuantile` in
/// `collections/histogram_utils.dart` with the cumulative view: what fraction
/// of samples fall at or below a value. The cumulative histogram reuses
/// `histogramFixed` directly so the two stay consistent.
library;

import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/collections/histogram_utils.dart';

/// One step of an empirical CDF: a sample [value] and the cumulative
/// probability [p] = (count of samples ≤ value) / n, in `[0, 1]`.
@immutable
class CdfPoint {
  /// Creates a CDF step at [value] with cumulative probability [p].
  /// Audited: 2026-06-12 11:26 EDT
  const CdfPoint(this.value, this.p);

  /// A distinct sample value, ascending across the returned list.
  final num value;

  /// Fraction of all samples that are ≤ [value]; the last point's [p] is 1.0.
  final double p;

  @override
  bool operator ==(Object other) => other is CdfPoint && other.value == value && other.p == p;

  @override
  int get hashCode => Object.hash(value, p);

  @override
  String toString() => 'CdfPoint($value, $p)';
}

/// Builds the empirical CDF of [values]: one [CdfPoint] per DISTINCT value in
/// ascending order, with `p` the running fraction of samples ≤ that value.
/// Returns an empty list for no samples. Does not mutate [values].
///
/// Example:
/// ```dart
/// empiricalCdf(<num>[1, 2, 2, 3]);
/// // [CdfPoint(1, 0.25), CdfPoint(2, 0.75), CdfPoint(3, 1.0)]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<CdfPoint> empiricalCdf(List<num> values) {
  if (values.isEmpty) return <CdfPoint>[];
  final List<num> sorted = List<num>.of(values)..sort();
  final int n = sorted.length;
  final List<CdfPoint> points = <CdfPoint>[];
  int i = 0;
  while (i < n) {
    final num value = sorted[i];
    // Advance past every duplicate of this value so each distinct value yields a
    // single point whose p reflects all samples ≤ it.
    int j = i;
    while (j < n && sorted[j] == value) {
      j++;
    }
    points.add(CdfPoint(value, j / n));
    i = j;
  }
  return points;
}

/// The empirical CDF of [values] evaluated at [x]: the fraction of samples that
/// are ≤ [x], in `[0, 1]`. Returns 0 for no samples.
/// Audited: 2026-06-12 11:26 EDT
double cdfAt(List<num> values, num x) {
  if (values.isEmpty) return 0;
  int count = 0;
  for (final num v in values) {
    if (v <= x) count++;
  }
  return count / values.length;
}

/// Cumulative histogram: the running total of `histogramFixed(values, edges)`,
/// so bin `i` holds the count of samples in bins `0..i` — the CDF in bin form.
/// Returns an empty list when [edges] has fewer than two entries.
///
/// Example:
/// ```dart
/// cumulativeHistogram(<num>[1, 2, 3, 4], <num>[0, 2, 4, 6]); // [1, 3, 4]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> cumulativeHistogram(List<num> values, List<num> edges) {
  final List<int> counts = histogramFixed(values, edges);
  final List<int> cumulative = List<int>.filled(counts.length, 0);
  int running = 0;
  for (int i = 0; i < counts.length; i++) {
    running += counts[i];
    cumulative[i] = running;
  }
  return cumulative;
}
