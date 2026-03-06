/// Min/max of two or N numbers. Roadmap #136. NumUtils already has maxOf(a,b).
num minOf(num a, num b) => a < b ? a : b;

/// Max of two numbers (NumUtils has maxOf with null handling).
num maxOf(num a, num b) => a > b ? a : b;

/// Min of iterable; null if empty.
num? minOfMany(Iterable<num> values) {
  num? m;
  for (final num v in values) {
    if (m == null || v < m) m = v;
  }
  return m;
}

/// Max of iterable; null if empty.
num? maxOfMany(Iterable<num> values) {
  num? m;
  for (final num v in values) {
    if (m == null || v > m) m = v;
  }
  return m;
}
