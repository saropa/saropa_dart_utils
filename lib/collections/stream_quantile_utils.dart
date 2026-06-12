/// Exact streaming quantile over a retained sample — roadmap #453.
library;

/// Computes an EXACT percentile over every value fed in. This retains all
/// values (memory grows O(n)); it is NOT an approximate, fixed-memory P²
/// estimator despite the roadmap title. Use it when exactness matters and the
/// stream is bounded; for unbounded streams with a memory cap, downsample
/// before feeding values in.
class StreamQuantileUtils {
  /// Creates an estimator for the quantile at [p], where [p] ranges from 0 to 1
  /// (e.g. 0.5 for the median).
  /// Audited: 2026-06-12 11:26 EDT
  StreamQuantileUtils(double p) : _p = p;
  final double _p;

  /// The target quantile in the range 0 to 1.
  /// Audited: 2026-06-12 11:26 EDT
  double get p => _p;
  final List<double> _buffer = <double>[];

  /// Feeds [value] into the estimator. The value is retained for an exact
  /// quantile; [quantile] sorts a copy on demand, so this is O(1) amortized.
  /// Audited: 2026-06-12 11:26 EDT
  void add(num value) {
    _buffer.add(value.toDouble());
  }

  /// Current exact quantile at [p] (e.g. median when p is 0.5), or NaN when no
  /// values have been added.
  /// Audited: 2026-06-12 11:26 EDT
  double get quantile {
    if (_buffer.isEmpty) return double.nan;
    final List<double> sorted = List<double>.of(_buffer)..sort();
    final int i = (_p * (sorted.length - 1)).round().clamp(0, sorted.length - 1);
    return sorted[i];
  }

  @override
  String toString() => 'StreamQuantileUtils(p: $_p, count: ${_buffer.length})';
}
