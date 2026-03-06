/// Moving averages: simple, exponential (roadmap #565).
library;

/// Simple moving average of [values] over window [size].
List<double> simpleMovingAverage(List<num> values, int size) {
  if (size < 1 || values.length < size) return <double>[];
  final List<double> out = <double>[];
  double sum = 0;
  for (int i = 0; i < size; i++) sum += values[i].toDouble();
  out.add(sum / size);
  for (int i = size; i < values.length; i++) {
    sum = sum - values[i - size].toDouble() + values[i].toDouble();
    out.add(sum / size);
  }
  return out;
}

/// Exponential moving average: [alpha] in (0,1]; first value = first input.
List<double> exponentialMovingAverage(List<num> values, double alpha) {
  if (values.isEmpty) return <double>[];
  if (alpha <= 0 || alpha > 1) return values.map((num x) => x.toDouble()).toList();
  final List<double> out = <double>[];
  double prev = values[0].toDouble();
  out.add(prev);
  for (int i = 1; i < values.length; i++) {
    prev = alpha * values[i].toDouble() + (1 - alpha) * prev;
    out.add(prev);
  }
  return out;
}
