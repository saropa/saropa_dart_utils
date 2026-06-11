/// Token-bucket rate limiter — roadmap #670.
///
/// Smooths a burst of work to a sustainable average rate: tokens refill
/// continuously at `tokensPerSecond` up to a `capacity` (the burst ceiling), and
/// each unit of work spends tokens. This is the non-blocking core primitive —
/// `tryAcquire` returns allow/deny immediately and `timeUntilAvailable` says how
/// long until a denied request would succeed, so the caller decides whether to
/// drop, queue, or delay. No `Timer` and no wall-clock coupling: time is read
/// through an injectable `now` closure, making refill behavior fully
/// deterministic under test.
library;

import 'dart:math' as math;

/// A token bucket: `capacity` tokens max, refilling at `tokensPerSecond`.
///
/// Starts full, so an initial burst up to `capacity` is allowed before the
/// steady rate takes over.
class TokenBucketRateLimiter {
  /// Creates a limiter refilling at [tokensPerSecond] (> 0) up to [capacity]
  /// (≥ 1) tokens. [now] supplies the current time for refill accrual; it
  /// defaults to `DateTime.now` and can be overridden in tests to advance a
  /// virtual clock.
  TokenBucketRateLimiter({
    required this.tokensPerSecond,
    required this.capacity,
    // ignore: saropa_lints/prefer_correct_callback_field_name -- injected clock source, not an event callback; an "on" prefix would misname it
    DateTime Function()? now,
  }) : assert(tokensPerSecond > 0, 'tokensPerSecond must be > 0'),
       assert(capacity >= 1, 'capacity must be >= 1'),
       _now = now ?? DateTime.now,
       _tokens = capacity.toDouble(),
       // Seed the accrual baseline from the same clock source the bucket reads,
       // so the first refill measures elapsed time from construction.
       _lastRefill = (now ?? DateTime.now)();

  /// Steady-state refill rate (tokens added per second of elapsed time).
  final double tokensPerSecond;

  /// Maximum tokens the bucket can hold — the largest single burst allowed.
  final int capacity;

  final DateTime Function() _now;

  /// Current token count (fractional between whole tokens). Accrues lazily on
  /// each call rather than on a timer.
  double _tokens;

  /// Time of the most recent accrual; the base for the next elapsed-time refill.
  DateTime _lastRefill;

  /// Tries to spend [tokens] (default 1). Returns true and deducts them if
  /// enough have accrued, false otherwise (no partial spend). Throws
  /// [ArgumentError] if [tokens] is below 1 or above [capacity] — a request
  /// larger than the bucket can ever hold is a programming error, not a denial.
  bool tryAcquire([int tokens = 1]) {
    _validate(tokens);
    _refill();
    if (_tokens >= tokens) {
      _tokens -= tokens;
      return true;
    }
    return false;
  }

  /// How long until [tokens] (default 1) would be available, or [Duration.zero]
  /// if they are available now. Pairs with [tryAcquire] so a caller can schedule
  /// a retry instead of busy-polling. Throws [ArgumentError] on an impossible
  /// request (see [tryAcquire]).
  Duration timeUntilAvailable([int tokens = 1]) {
    _validate(tokens);
    _refill();
    if (_tokens >= tokens) {
      return Duration.zero;
    }
    // Convert the token deficit to wait time at the refill rate, rounding up so
    // the returned instant is the first moment the request can actually succeed.
    final double deficit = tokens - _tokens;
    final int micros = (deficit / tokensPerSecond * Duration.microsecondsPerSecond).ceil();
    return Duration(microseconds: micros);
  }

  /// The tokens currently available (after accrual), as a fractional count.
  double availableTokens() {
    _refill();
    return _tokens;
  }

  void _validate(int tokens) {
    if (tokens < 1 || tokens > capacity) {
      throw ArgumentError.value(tokens, 'tokens', 'must be between 1 and capacity ($capacity)');
    }
  }

  /// Adds the tokens accrued since [_lastRefill], capped at [capacity]. A clock
  /// that did not advance (or stepped backward) accrues nothing and leaves the
  /// baseline untouched, so a later forward step still measures the full gap.
  void _refill() {
    final DateTime current = _now();
    final int elapsedMicros = current.difference(_lastRefill).inMicroseconds;
    if (elapsedMicros <= 0) {
      return;
    }
    final double gained = elapsedMicros / Duration.microsecondsPerSecond * tokensPerSecond;
    _tokens = math.min(capacity.toDouble(), _tokens + gained);
    _lastRefill = current;
  }

  @override
  String toString() =>
      'TokenBucketRateLimiter(tokensPerSecond: $tokensPerSecond, capacity: $capacity)';
}
