/// Async barrier: wait for N events — roadmap #676.
library;

import 'dart:async' show Completer;

/// Barrier that completes when [count] signals received.
final class AsyncBarrierUtils {
  static const String _kErrCountAtLeastOne = 'count >= 1';

  /// Creates a barrier that completes after [count] calls to [signal].
  /// Throws an [ArgumentError] when [count] is less than 1.
  factory AsyncBarrierUtils(int count) {
    if (count < 1) throw ArgumentError(_kErrCountAtLeastOne);
    return AsyncBarrierUtils._(count);
  }

  AsyncBarrierUtils._(this.count) : _remaining = count;

  /// Total number of signals required for the barrier to complete.
  final int count;
  int _remaining;
  Completer<void>? _completer;

  /// Decrements the remaining count; completes
  /// the barrier when count reaches zero.
  void signal() {
    _remaining--;
    // Guard isCompleted: signalling more than [count] times must be a no-op, not
    // a "Future already completed" throw from completing the same completer twice.
    final Completer<void>? c = _completer;
    if (_remaining <= 0 && c != null && !c.isCompleted) c.complete();
  }

  /// Future that completes when the barrier has received [count] signals.
  Future<void> get future {
    final c = _completer ??= Completer<void>();

    if (_remaining <= 0 && !c.isCompleted) c.complete();
    return c.future;
  }

  @override
  String toString() =>
      'AsyncBarrierUtils('
      'count: $count, remaining: $_remaining)';
}
