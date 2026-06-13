/// Async semaphore with permits (roadmap #651).
library;

import 'dart:async' show Completer;

/// Callback that produces a future result.
typedef AsyncAction<T> = Future<T> Function();

/// Semaphore: at most [permits] concurrent acquisitions.
class AsyncSemaphoreUtils {
  /// Creates a semaphore allowing at most [permits] concurrent acquisitions.
  /// Audited: 2026-06-12 11:26 EDT
  AsyncSemaphoreUtils(this.permits) : _available = permits;

  /// Maximum number of concurrent acquisitions allowed.
  final int permits;
  int _available;
  final List<void Function()> _waiters = <void Function()>[];

  /// Acquires a permit, runs [fn], then releases;
  /// ensures release on exception.
  ///
  /// Returns the result of [fn].
  /// Audited: 2026-06-12 11:26 EDT
  Future<T> run<T>(AsyncAction<T> fn) async {
    await acquire();
    try {
      return await fn();
    } finally {
      release();
    }
  }

  /// Waits for a permit, then acquires it. Completes immediately when a permit
  /// is free, otherwise queues until [release] hands one over.
  /// Audited: 2026-06-12 11:26 EDT
  Future<void> acquire() async {
    if (_available > 0) {
      _available--;
      return;
    }
    final Completer<void> c = Completer<void>();
    _waiters.add(c.complete);
    // The woken waiter does NOT decrement `_available`: [release] transfers the
    // permit DIRECTLY to it (without incrementing), so the permit count is
    // already correct. Decrementing here would double-count and, combined with
    // an increment in release, let a fast-path acquirer steal the permit in the
    // wake-up gap — admitting two holders and driving the count negative.
    await c.future;
  }

  /// Releases one permit; hands it directly to the next waiter if any, otherwise
  /// returns it to the available pool.
  /// Audited: 2026-06-12 11:26 EDT
  void release() {
    // Direct hand-off: when a waiter is queued the permit transfers to it
    // WITHOUT touching `_available` (the slot was never freed to the pool). Only
    // increment when there is no waiter to take the permit.
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0)();
    } else {
      // Guard the permit invariant: with no waiter and the pool already full,
      // this release has no matching acquire. Incrementing would push
      // `_available` above `permits` and let the semaphore admit more than
      // `permits` concurrent holders forever. Fail loud instead of silently
      // corrupting the count.
      if (_available >= permits) {
        throw StateError('release() called without a matching acquire() (permits: $permits)');
      }
      _available++;
    }
  }

  @override
  String toString() =>
      'AsyncSemaphoreUtils('
      'permits: $permits, '
      'available: $_available)';
}
