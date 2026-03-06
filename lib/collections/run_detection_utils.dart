/// Run detection (equal or increasing sequences with metadata) — roadmap #472.
library;

/// One run: start index, length, constant value or null for increasing.
class Run<T extends Object> {
  const Run(int start, int length, T? value) : _start = start, _length = length, _value = value;
  final int _start;

  /// Start index in the source list.
  int get start => _start;
  final int _length;

  /// Length of the run.
  int get length => _length;
  final T? _value;

  /// Constant value for the run, or null for non-constant runs.
  T? get value => _value;

  @override
  String toString() => 'Run(start: $_start, length: $_length, value: ${_value ?? "-"})';
}

/// Detects runs of equal consecutive values in [list].
List<Run<T>> runsEqual<T extends Object>(List<T> list) {
  final List<Run<T>> out = [];
  int i = 0;
  while (i < list.length) {
    final T v = list[i];
    int j = i + 1;
    while (j < list.length && list[j] == v) j++;
    out.add(Run<T>(i, j - i, v));
    i = j;
  }
  return out;
}
