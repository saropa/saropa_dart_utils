/// Exponential time-decay counter with configurable half-life — roadmap #479.
library;

import 'dart:math' show exp, ln2;

/// O(1)-memory counter whose contributions decay exponentially over time.
///
/// Why: trending/recency scores (popularity, rate limiting, "hot" ranking) need
/// recent events to outweigh old ones without storing every event. Lazy decay
/// keeps a single accumulated value plus the last-updated time, decaying it on
/// each read/write, so memory is O(1) regardless of how many events arrive.
///
/// Time is injected as explicit epoch-millis parameters — there are no
/// wall-clock reads — so behavior is fully deterministic and testable.
///
/// Example:
/// ```dart
/// // Half-life of 1000 ms: a contribution loses half its weight every second.
/// final c = TimeDecayCounter(halfLifeMillis: 1000)
///   ..add(8, atTimeMillis: 0);
/// c.value(asOfTimeMillis: 1000); // 4.0 (one half-life elapsed)
/// c.value(asOfTimeMillis: 2000); // 2.0 (two half-lives elapsed)
/// ```
class TimeDecayCounter {
  /// Creates a counter that halves accumulated weight every [halfLifeMillis].
  ///
  /// Why: lambda is derived from the half-life (lambda = ln2 / halfLife) so
  /// callers reason in the intuitive "time to halve" unit, not a raw rate.
  /// A non-positive half-life is meaningless (infinite/instant decay) and is
  /// rejected up front rather than producing NaN/Infinity later.
  ///
  /// Example:
  /// ```dart
  /// final c = TimeDecayCounter(halfLifeMillis: 500);
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  TimeDecayCounter({required this.halfLifeMillis}) : _lambda = _validatedLambda(halfLifeMillis);

  // Validates before dividing: a zero/negative half-life would make `_lambda`
  // Infinity/NaN and poison every later `value(t) = stored * exp(-lambda*dt)`.
  // The division is in the initializer, so the guard must run before it — an
  // assert (stripped in release) cannot; a static helper can.
  static double _validatedLambda(double halfLifeMillis) {
    if (halfLifeMillis <= 0) {
      throw ArgumentError.value(halfLifeMillis, 'halfLifeMillis', 'must be > 0');
    }
    return ln2 / halfLifeMillis;
  }

  /// Time, in milliseconds, for any contribution to lose half its weight.
  final double halfLifeMillis;

  // Decay rate derived once from the half-life; value(t) = stored * exp(-lambda*dt).
  final double _lambda;

  // Lazy-decay state: the accumulated value as of [_lastMillis]. Decaying only
  // on read/write (rather than per event) is what keeps memory O(1).
  double _value = 0.0;
  int? _lastMillis;

  /// Accumulated value decayed forward to [asOfTimeMillis].
  ///
  /// Why: reading does not mutate state, so repeated reads at different times are
  /// consistent. Timestamps before the last update clamp to zero elapsed time
  /// (dt >= 0) so out-of-order reads never amplify the value.
  ///
  /// Example:
  /// ```dart
  /// final c = TimeDecayCounter(halfLifeMillis: 1000)..add(10, atTimeMillis: 0);
  /// c.value(asOfTimeMillis: 1000); // 5.0
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  double value({required int asOfTimeMillis}) => _decayedTo(asOfTimeMillis);

  /// Adds [weight] at [atTimeMillis], decaying any prior value to that instant.
  ///
  /// Why: the stored value is first decayed forward to [atTimeMillis] so the new
  /// weight combines with the correctly-aged prior total. Out-of-order adds clamp
  /// to dt >= 0, and [_lastMillis] only ever advances, so a late event cannot
  /// rewind the clock and inflate older contributions.
  ///
  /// Example:
  /// ```dart
  /// final c = TimeDecayCounter(halfLifeMillis: 1000)
  ///   ..add(4, atTimeMillis: 0)
  ///   ..add(4, atTimeMillis: 1000);
  /// c.value(asOfTimeMillis: 1000); // 6.0 (2.0 decayed + 4.0 fresh)
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  void add(double weight, {required int atTimeMillis}) {
    _value = _decayedTo(atTimeMillis) + weight;
    // Never move the reference time backwards; a late add ages to "now", not past.
    final int? last = _lastMillis;
    _lastMillis = (last == null || atTimeMillis > last) ? atTimeMillis : last;
  }

  /// Resets the counter to empty, forgetting all accumulated weight and time.
  ///
  /// Why: lets a counter be reused without reallocation (e.g. per-window rollups).
  ///
  /// Example:
  /// ```dart
  /// final c = TimeDecayCounter(halfLifeMillis: 1000)..add(5, atTimeMillis: 0)..reset();
  /// c.value(asOfTimeMillis: 0); // 0.0
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  void reset() {
    _value = 0.0;
    _lastMillis = null;
  }

  // Decays the stored value to [millis], clamping elapsed time to >= 0 so
  // out-of-order timestamps cannot grow (exp of a positive exponent) the value.
  double _decayedTo(int millis) {
    final int? last = _lastMillis;
    if (last == null) return _value;
    final int dt = millis - last;
    if (dt <= 0) return _value;
    return _value * exp(-_lambda * dt);
  }

  @override
  String toString() =>
      'TimeDecayCounter(halfLifeMillis: $halfLifeMillis, lastMillis: ${_lastMillis ?? 'none'})';
}
