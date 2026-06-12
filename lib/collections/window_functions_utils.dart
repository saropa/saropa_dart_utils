/// Window functions (lag, lead, row_number) over ordered data — roadmap #471.
library;

/// Lag: value at index [i - offset]; null if out of range.
/// Audited: 2026-06-12 11:26 EDT
T? lag<T>(List<T> values, int index, int offset) {
  final int j = index - offset;
  return j >= 0 && j < values.length ? values[j] : null;
}

/// Lead: value at index [i + offset]; null if out of range.
/// Audited: 2026-06-12 11:26 EDT
T? lead<T>(List<T> values, int index, int offset) {
  final int j = index + offset;
  return j >= 0 && j < values.length ? values[j] : null;
}

/// Row number (1-based index).
/// Audited: 2026-06-12 11:26 EDT
int rowNumber(int index) => index + 1;

/// Rank: 1-based rank; equal values get same rank, next rank skips.
/// Audited: 2026-06-12 11:26 EDT
List<int> rank(List<num> values) {
  final List<int> out = List.filled(values.length, 0);
  // Standard competition ranking ("1224" style): a value's rank is one plus the
  // count of strictly-greater values. Using strict greater-than (not >=) means
  // equal values land on the same rank, and the next distinct value skips the
  // ranks the tie consumed. The quadratic nested scan is acceptable for the
  // small ordered result sets these window functions operate on.
  for (int i = 0; i < values.length; i++) {
    int r = 1;
    for (int j = 0; j < values.length; j++) {
      if (values[j] > values[i]) r++;
    }
    out[i] = r;
  }
  return out;
}
