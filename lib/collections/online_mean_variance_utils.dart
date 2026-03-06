/// Online mean/variance for numeric streams — roadmap #466.
library;

import 'dart:math' show sqrt;

/// Welford's online algorithm: add samples one by one, get mean and variance.
class OnlineMeanVariance {
  /// Number of samples added.
  int get count => _n;

  /// Current mean.
  double get mean => _n == 0 ? 0.0 : _m;

  /// Sample variance (Bessel-corrected).
  double get variance => _n < 2 ? 0.0 : _s2 / (_n - 1);

  /// Square root of [variance].
  double get standardDeviation => variance > 0 ? sqrt(variance) : 0.0;

  int _n = 0;
  double _m = 0.0;
  double _s2 = 0.0;

  /// Adds one sample [x]; updates mean and variance in O(1).
  void add(num x) {
    final double xi = x.toDouble();
    _n++;
    final double delta = xi - _m;
    _m += delta / _n;
    _s2 += delta * (xi - _m);
  }

  @override
  String toString() => 'OnlineMeanVariance(count: $_n, mean: $mean, variance: $variance)';
}
