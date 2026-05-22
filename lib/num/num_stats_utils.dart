import 'dart:math' as math;

/// Variance, standard deviation, median, percentile. Roadmap #122–125.
double variance(Iterable<num> values, {bool isPopulation = false}) {
  final List<num> list = values.toList();
  if (list.isEmpty) return 0;
  final double mean = list.fold<double>(0, (double s, num v) => s + v.toDouble()) / list.length;
  final double sumSq = list.fold<double>(0, (double s, num v) {
    final double d = v.toDouble() - mean;
    final double dSq = math.pow(d, 2).toDouble();
    return s + dSq;
  });
  final int n = isPopulation ? list.length : list.length - 1;
  return n <= 0 ? 0 : sumSq / n;
}

/// Standard deviation (square root of variance).
double standardDeviation(Iterable<num> values, {bool isPopulation = false}) {
  final double v = variance(values, isPopulation: isPopulation);
  if (!v.isFinite || v <= 0) return 0;
  return math.sqrt(v);
}

/// Returns the median of [values], or `null` if the collection is empty.
///
/// For an even count, returns the average of the two middle values. Does not
/// mutate the caller's input.
///
/// Example:
/// ```dart
/// median([3, 1, 2]); // 2.0
/// median([4, 1, 2, 3]); // 2.5
/// ```
double? median(Iterable<num> values) {
  // ignore: saropa_lints/avoid_large_list_copy -- needs an independent copy to sort without mutating the caller's input
  final List<double> list = values.map((num n) => n.toDouble()).toList()..sort();
  if (list.isEmpty) return null;
  final int mid = list.length ~/ 2;
  if (list.length.isOdd) return list[mid];
  return (list[mid - 1] + list[mid]) / 2;
}

/// Returns the [p]th percentile of [values] using linear interpolation.
///
/// [p] is a fraction in `0.0`–`1.0` (e.g. `0.5` for the median). Returns
/// `null` if [p] is out of range or [values] is empty. Does not mutate the
/// caller's input.
///
/// Example:
/// ```dart
/// percentile([1, 2, 3, 4], 0.5); // 2.5
/// ```
double? percentile(Iterable<num> values, double p) {
  if (p < 0 || p > 1) return null;
  // ignore: saropa_lints/avoid_large_list_copy -- needs an independent copy to sort without mutating the caller's input
  final List<double> list = values.map((num n) => n.toDouble()).toList()..sort();
  if (list.isEmpty) return null;
  if (list.length == 1) return list[0];
  // Linear-interpolation method (R's "type 7"): the percentile maps to a
  // fractional rank p*(n-1), so p=0 hits the first element and p=1 the last.
  final double index = p * (list.length - 1);
  // Bracket that fractional rank with its floor (i) and next (j) integer ranks;
  // both are clamped so the top of the range (i == n-1) does not read past end.
  final int i = index.floor().clamp(0, list.length - 1);
  final int j = (i + 1).clamp(0, list.length - 1);
  // t is the fractional offset between ranks i and j; blend them proportionally.
  final double t = index - i;
  return list[i] + t * (list[j] - list[i]);
}
