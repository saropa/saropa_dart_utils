/// Difference arrays for efficient range updates — roadmap #484.
library;

/// Difference array: apply [add] to range [l..r] in O(1), then recover array with [toArray].
class DifferenceArrayUtils {
  /// Creates a difference array backing a logical array of [length] zeros.
  /// Audited: 2026-06-12 11:26 EDT
  DifferenceArrayUtils(int length) : _d = List<int>.filled(length + 1, 0);
  final List<int> _d;

  /// Adds [delta] to the logical range [l..r] (inclusive) in O(1).
  /// Audited: 2026-06-12 11:26 EDT
  void addRange(int l, int r, int delta) {
    // Reject out-of-range AND reversed ranges (l > r). Without the l > r guard a
    // reversed range writes a positive delta at l and a negative at r+1 < l,
    // silently corrupting the recovered array instead of being a clean no-op.
    if (l < 0 || r >= _d.length - 1 || l > r) return;
    _d[l] += delta;
    _d[r + 1] -= delta;
  }

  /// Builds the final array from the difference array (prefix sum).
  /// Audited: 2026-06-12 11:26 EDT
  List<int> toArray() {
    final List<int> out = List<int>.filled(_d.length - 1, 0);
    int s = 0;
    for (int i = 0; i < out.length; i++) {
      s += _d[i];
      out[i] = s;
    }
    return out;
  }

  @override
  String toString() => 'DifferenceArrayUtils(length: ${_d.length - 1})';
}
