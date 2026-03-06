/// Window functions (lag, lead, row_number) over ordered data — roadmap #471.
library;

/// Lag: value at index [i - offset]; null if out of range.
T? lag<T>(List<T> values, int index, int offset) {
  final int j = index - offset;
  return j >= 0 && j < values.length ? values[j] : null;
}

/// Lead: value at index [i + offset]; null if out of range.
T? lead<T>(List<T> values, int index, int offset) {
  final int j = index + offset;
  return j >= 0 && j < values.length ? values[j] : null;
}

/// Row number (1-based index).
int rowNumber(int index) => index + 1;

/// Rank: 1-based rank; equal values get same rank, next rank skips.
List<int> rank(List<num> values) {
  final List<int> out = List.filled(values.length, 0);
  for (int i = 0; i < values.length; i++) {
    int r = 1;
    for (int j = 0; j < values.length; j++) {
      if (values[j] > values[i]) r++;
    }
    out[i] = r;
  }
  return out;
}
