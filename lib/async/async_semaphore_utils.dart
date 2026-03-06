/// Async semaphore with permits (roadmap #651).
library;

import 'dart:async' show Completer; // ignore: require_ios_deployment_target_consistency
import 'dart:developer' show log;

/// Semaphore: at most [permits] concurrent acquisitions.
class AsyncSemaphoreUtils {
  AsyncSemaphoreUtils(int permits) : _permits = permits, _available = permits;
  final int _permits;

  /// Maximum number of concurrent acquisitions allowed.
  int get permits => _permits;
  int _available;
  final List<void Function()> _waiters = [];

  /// Acquires a permit, runs [fn], then releases; ensures release on exception.
  Future<T> run<T>(Future<T> Function() fn) async {
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
      log('AsyncSemaphoreUtils.acquire', error: e, stackTrace: st);
      if (!c.isCompleted) c.completeError(e, st);
      rethrow;
    }
    _available--;
  }

  /// Releases one permit (increments available count); unblocks one waiter if any.
  void release() {
    _available++;
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0)();
    }
  }

  @override
  String toString() => 'AsyncSemaphoreUtils(permits: $_permits, available: $_available)';
}
