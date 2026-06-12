/// Min/max of two or N numbers. Roadmap #136. NumUtils already has maxOf(a,b).
/// Audited: 2026-06-12 11:26 EDT
num minOf(num a, num b) => a < b ? a : b;

/// Max of two numbers (NumUtils has maxOf with null handling).
/// Audited: 2026-06-12 11:26 EDT
num maxOf(num a, num b) => a > b ? a : b;

/// Min of iterable; null if empty.
/// Audited: 2026-06-12 11:26 EDT
num? minOfMany(Iterable<num> values) {
  num? m;
  for (final num v in values) {
    if (m == null || v < m) m = v;
  }
  return m;
}

/// Max of iterable; null if empty.
/// Audited: 2026-06-12 11:26 EDT
num? maxOfMany(Iterable<num> values) {
  num? m;
  for (final num v in values) {
    if (m == null || v > m) m = v;
  }
  return m;
}
