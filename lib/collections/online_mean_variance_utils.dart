/// Online mean/variance for numeric streams — roadmap #466.
library;

import 'dart:math' show sqrt;

/// Welford's online algorithm: add samples one by one, get mean and variance.
class OnlineMeanVarianceUtils {
  /// Number of samples added.
  /// Audited: 2026-06-12 11:26 EDT
  int get count => _n;

  /// Current mean.
  /// Audited: 2026-06-12 11:26 EDT
  double get mean => _n == 0 ? 0.0 : _m;

  /// Sample variance (Bessel-corrected).
  /// Audited: 2026-06-12 11:26 EDT
  double get variance => _n < 2 ? 0.0 : _s2 / (_n - 1);

  /// Square root of [variance].
  /// Audited: 2026-06-12 11:26 EDT
  double get standardDeviation => variance > 0 ? sqrt(variance) : 0.0;

  int _n = 0;
  double _m = 0.0;
  double _s2 = 0.0;

  /// Adds one sample [x]; updates mean and variance in O(1).
  /// Audited: 2026-06-12 11:26 EDT
  void add(num x) {
    final double xi = x.toDouble();
    _n++;
    final double delta = xi - _m;
    _m += delta / _n;
    _s2 += delta * (xi - _m);
  }

  @override
  String toString() => 'OnlineMeanVarianceUtils(count: $_n, mean: $mean, variance: $variance)';
}
