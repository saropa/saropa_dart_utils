/// Sliding-window-log rate limiter — roadmap #685.
///
/// Enforces "no more than [limit] events in any trailing [window]" exactly, by
/// keeping the timestamps of recent events and counting those still inside the
/// window. This is the precise counterpart to the token-bucket limiter (#670):
/// the bucket smooths to an average rate with O(1) memory and allows bursts up
/// to its capacity; this gives an exact rolling-window count with O(limit)
/// memory and no burst beyond the limit. Time is read through an injectable
/// `now` closure so behavior is deterministic under test.
///
/// The event log is in-memory; a distributed limiter would swap it for shared
/// storage, but that abstraction is intentionally not built here (single
/// process is the common case).
library;

import 'dart:collection' show ListQueue;

import 'package:collection/collection.dart' show IterableExtension;

/// Allows at most [limit] events per trailing [window] (a half-open
/// `(now - window, now]` interval).
class SlidingWindowRateLimiter {
  /// Creates a limiter permitting [limit] (≥ 1) events per [window] (> 0).
  /// [now] supplies the current time (defaults to `DateTime.now`); tests pass a
  /// virtual clock to advance time deterministically.
  /// Audited: 2026-06-12 11:26 EDT
  SlidingWindowRateLimiter({
    required this.limit,
    required this.window,
    // ignore: saropa_lints/prefer_correct_callback_field_name -- injected clock source, not an event callback
    DateTime Function()? now,
  }) : assert(limit >= 1, 'limit must be >= 1'),
       assert(window > Duration.zero, 'window must be positive'),
       _now = now ?? DateTime.now;

  /// Maximum events permitted within any single trailing [window].
  final int limit;

  /// The trailing window width.
  final Duration window;

  final DateTime Function() _now;

  /// Timestamps of events still inside the window, oldest first.
  /// Audited: 2026-06-12 11:26 EDT
  final ListQueue<DateTime> _events = ListQueue<DateTime>();

  /// Tries to record one event now: returns true and logs it if fewer than
  /// [limit] events fall in the current window, false otherwise (not logged).
  /// Audited: 2026-06-12 11:26 EDT
  bool tryAcquire() {
    final DateTime now = _now();
    _prune(now);
    if (_events.length < limit) {
      _events.add(now);
      return true;
    }
    return false;
  }

  /// The number of events currently inside the window (after pruning expired
  /// ones).
  /// Audited: 2026-06-12 11:26 EDT
  int currentCount() {
    _prune(_now());
    return _events.length;
  }

  /// How long until the next event would be admitted, or [Duration.zero] if one
  /// is admissible now. When at the limit, that is when the oldest in-window
  /// event ages out (`oldest + window`).
  /// Audited: 2026-06-12 11:26 EDT
  Duration timeUntilAvailable() {
    final DateTime now = _now();
    _prune(now);
    final DateTime? oldest = _events.firstOrNull;
    // Below the limit (or empty) → admissible now. Otherwise the oldest event
    // ages out at `oldest + window`, freeing the next slot.
    if (oldest == null || _events.length < limit) {
      return Duration.zero;
    }
    final Duration wait = oldest.add(window).difference(now);
    return wait.isNegative ? Duration.zero : wait;
  }

  /// Drops events that have aged out of the trailing window. An event exactly
  /// [window] old is expired (the window's lower bound is exclusive), so a
  /// timestamp at or before `now - window` is removed.
  /// Audited: 2026-06-12 11:26 EDT
  void _prune(DateTime now) {
    final DateTime threshold = now.subtract(window);
    while (true) {
      final DateTime? oldest = _events.firstOrNull;
      if (oldest == null || oldest.isAfter(threshold)) {
        break;
      }
      // ignore: saropa_lints/avoid_ignoring_return_values -- the removed element was already read via firstOrNull above; the discard is intentional
      _events.removeFirst();
    }
  }

  @override
  String toString() => 'SlidingWindowRateLimiter(limit: $limit, window: $window)';
}
