/// Run detection (equal or increasing sequences with metadata) — roadmap #472.
library;

/// One run: start index, length, constant value or null for increasing.
class RunDetectionUtils<T extends Object> {
  /// Creates a run beginning at [start], spanning [length] elements, with the
  /// shared [value] (or null for a non-constant run).
  /// Audited: 2026-06-12 11:26 EDT
  const RunDetectionUtils(int start, int length, T? value)
    : _start = start,
      _length = length,
      _value = value;
  final int _start;

  /// Start index in the source list.
  /// Audited: 2026-06-12 11:26 EDT
  int get start => _start;
  final int _length;

  /// Length of the run.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _length;
  final T? _value;

  /// Constant value for the run, or null for non-constant runs.
  /// Audited: 2026-06-12 11:26 EDT
  T? get value => _value;

  @override
  String toString() =>
      'RunDetectionUtils(start: $_start, length: $_length, value: ${_value ?? '-'})';
}

/// Detects runs of equal consecutive values in [list].
/// Audited: 2026-06-12 11:26 EDT
List<RunDetectionUtils<T>> runsEqual<T extends Object>(List<T> list) {
  final List<RunDetectionUtils<T>> out = <RunDetectionUtils<T>>[];
  int i = 0;
  while (i < list.length) {
    final T v = list[i];
    int j = i + 1;
    while (j < list.length && list[j] == v) {
      j++;
    }
    out.add(RunDetectionUtils<T>(i, j - i, v));
    i = j;
  }
  return out;
}
