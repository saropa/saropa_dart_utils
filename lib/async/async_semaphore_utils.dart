/// Async semaphore with permits (roadmap #651).
library;

// ignore: require_ios_deployment_target_consistency
import 'dart:async' show Completer;

/// Callback that produces a future result.
typedef AsyncAction<T> = Future<T> Function();

/// Semaphore: at most [permits] concurrent acquisitions.
class AsyncSemaphoreUtils {
  AsyncSemaphoreUtils(this.permits) : _available = permits;

  /// Maximum number of concurrent acquisitions allowed.
  final int permits;
  int _available;
  final List<void Function()> _waiters = [];

  /// Acquires a permit, runs [fn], then releases;
  /// ensures release on exception.
  ///
  /// Returns the result of [fn].
  Future<T> run<T>(AsyncAction<T> fn) async {
    await acquire();
    try {
      return await fn();
    } finally {
      release();
    }
  }

  /// Waits for a permit, then acquires it (decrements available count).
  /// Completes when a permit is available.
  /// Throws [Object] if the underlying future completes with an error.
  Future<void> acquire() async {
    if (_available > 0) {
      _available--;
      return;
    }
    final Completer<void> c = Completer<void>();

    _waiters.add(() => c.complete());
    try {
      await c.future;
    } on Object catch (e, st) {
      if (!c.isCompleted) c.completeError(e, st);
      rethrow;
    }
    _available--;
  }

  /// Releases one permit (increments available
  /// count); unblocks one waiter if any.
  void release() {
    _available++;
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0)();
    }
  }

  @override
  String toString() =>
      'AsyncSemaphoreUtils('
      'permits: $permits, '
      'available: $_available)';
}
