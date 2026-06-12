/// Moving averages: simple, exponential (roadmap #565).
library;

/// Simple moving average of [values] over window [size].
/// Audited: 2026-06-12 11:26 EDT
List<double> simpleMovingAverage(List<num> values, int size) {
  // No window fits when size is non-positive or larger than the data, so there
  // are no averages to emit — return empty rather than a partial/garbage window.
  if (size < 1 || values.length < size) return <double>[];
  final List<double> out = <double>[];
  // Seed the running sum with the first full window.
  double sum = 0;
  for (int i = 0; i < size; i++) {
    sum += values[i].toDouble();
  }
  out.add(sum / size);
  // Slide the window by adjusting the running sum — subtract the element leaving
  // the window, add the one entering — so each step is constant-time;
  // recomputing the whole window sum at every position would instead make the
  // total cost grow with the window size.
  for (int i = size; i < values.length; i++) {
    sum = sum - values[i - size].toDouble() + values[i].toDouble();
    out.add(sum / size);
  }
  return out;
}

/// Exponential moving average: [alpha] in (0,1]; first value = first input.
/// Audited: 2026-06-12 11:26 EDT
List<double> exponentialMovingAverage(List<num> values, double alpha) {
  if (values.isEmpty) return <double>[];
  // Out-of-range alpha (outside 0..1) is treated as "no smoothing": return the
  // raw values so a bad parameter degrades gracefully instead of distorting.
  if (alpha <= 0 || alpha > 1) return values.map((num x) => x.toDouble()).toList();
  final List<double> out = <double>[];
  // Seed with the first value (nothing earlier to blend), then each output is a
  // weighted blend: alpha of the new value plus (1-alpha) of the prior average.
  double prev = values[0].toDouble();
  out.add(prev);
  for (int i = 1; i < values.length; i++) {
    prev = alpha * values[i].toDouble() + (1 - alpha) * prev;
    out.add(prev);
  }
  return out;
}
