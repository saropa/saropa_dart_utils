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

double? median(Iterable<num> values) {
  final List<double> list = values.map((num n) => n.toDouble()).toList()..sort();
  if (list.isEmpty) return null;
  final int mid = list.length ~/ 2;
  if (list.length.isOdd) return list[mid];
  return (list[mid - 1] + list[mid]) / 2;
}

double? percentile(Iterable<num> values, double p) {
  if (p < 0 || p > 1) return null;
  final List<double> list = values.map((num n) => n.toDouble()).toList()..sort();
  if (list.isEmpty) return null;
  if (list.length == 1) return list[0];
  final double index = p * (list.length - 1);
  final int i = index.floor().clamp(0, list.length - 1);
  final int j = (i + 1).clamp(0, list.length - 1);
  final double t = index - i;
  return list[i] + t * (list[j] - list[i]);
}
