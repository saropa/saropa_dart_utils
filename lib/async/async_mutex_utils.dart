/// Async mutex with tryLock — roadmap #652.
library;

import 'dart:async' show Completer; // ignore: require_ios_deployment_target_consistency
import 'dart:developer' show log;

/// Async mutex: only one holder at a time.
class AsyncMutexUtils {
  bool _isLocked = false;
  final List<Completer<void>> _waiters = [];

  /// Waits until the mutex is available, then acquires it.
  /// Completes when the mutex is acquired.
  /// Throws [Object] if the underlying future completes with an error.
  Future<void> acquire() async {
    if (!_isLocked) {
      _isLocked = true;
      return;
    }
    final Completer<void> c = Completer<void>();
    _waiters.add(c);
    try {
      await c.future;
    } on Object catch (e, st) {
      log('AsyncMutexUtils.acquire', error: e, stackTrace: st);
      if (!c.isCompleted) c.completeError(e, st);
      rethrow;
    }
  }

  /// Acquires the mutex immediately if not locked; returns false if already held.
  bool tryLock() {
    if (_isLocked) return false;
    _isLocked = true;
    return true;
  }

  /// Releases the mutex; unblocks one waiter if any.
  void release() {
    if (_waiters.isEmpty) {
      _isLocked = false;
      return;
    }
    _waiters.removeAt(0).complete();
  }

  /// Acquires the mutex, runs [fn], then releases; ensures release on exception.
  Future<T> run<T>(Future<T> Function() fn) async {
    await acquire();
    try {
      return await fn();
    } finally {
      release();
    }
  }

  @override
  String toString() => 'AsyncMutexUtils(locked: $_isLocked, waiters: ${_waiters.length})';
}
