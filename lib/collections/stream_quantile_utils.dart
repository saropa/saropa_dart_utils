/// Stream quantile estimation (P²-style approximate) — roadmap #453.
library;

/// Approximate percentile from a stream of values (single pass, fixed memory).
class StreamQuantileUtils {
  StreamQuantileUtils(double p) : _p = p;
  final double _p;

  double get p => _p;
  final List<double> _buffer = [];
  static const int _maxSize = 100;

  void add(num value) {
    _buffer.add(value.toDouble());
    if (_buffer.length > _maxSize) _buffer.sort();
  }

  /// Current approximate quantile at [p] (e.g. median when p is 0.5).
  double get quantile {
    if (_buffer.isEmpty) return double.nan;
    final List<double> sorted = List<double>.of(_buffer)..sort();
    final int i = (_p * (sorted.length - 1)).round().clamp(0, sorted.length - 1);
    return sorted[i];
  }

  @override
  String toString() => 'StreamQuantileUtils(p: $_p, count: ${_buffer.length})';
}
