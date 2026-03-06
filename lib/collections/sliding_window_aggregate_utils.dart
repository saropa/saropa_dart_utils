/// Sliding window aggregations (min/max/sum/avg over moving window) — roadmap #451.
library;

/// Aggregation kind for a sliding window.
enum WindowAggregate { min, max, sum, avg }

/// Returns a list where each element is the [agg] of [values] over a window of length [size].
/// If [size] > length, returns empty list.
List<double> slidingWindow(List<num> values, int size, WindowAggregate agg) {
  if (size < 1 || values.length < size) return <double>[];
  final List<double> out = <double>[];
  for (int i = 0; i <= values.length - size; i++) {
    final List<num> window = values.sublist(i, i + size);
    switch (agg) {
      case WindowAggregate.min:
        out.add(
          window.fold<double>(double.infinity, (double a, num b) => a < b ? a : b.toDouble()),
        );
        break;
      case WindowAggregate.max:
        out.add(
          window.fold<double>(
            double.negativeInfinity,
            (double a, num b) => a > b ? a : b.toDouble(),
          ),
        );
        break;
      case WindowAggregate.sum:
        out.add(window.fold<double>(0, (double s, num v) => s + v.toDouble()));
        break;
      case WindowAggregate.avg:
        final double sum = window.fold<double>(0, (double s, num v) => s + v.toDouble());
        out.add(sum / window.length);
        break;
    }
  }
  return out;
}
