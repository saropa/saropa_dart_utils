/// Async barrier: wait for N events — roadmap #676.
library;

import 'dart:async' show Completer; // ignore: require_ios_deployment_target_consistency

/// Barrier that completes when [count] signals received.
final class AsyncBarrierUtils {
  static const String _kErrCountAtLeastOne = 'count >= 1';

  factory AsyncBarrierUtils(int count) {
    if (count < 1) throw ArgumentError(_kErrCountAtLeastOne);
    return AsyncBarrierUtils._(count);
  }

  AsyncBarrierUtils._(this.count) : _remaining = count;

  /// Total number of signals required for the barrier to complete.
  final int count;
  int _remaining;
  Completer<void>? _completer;

  /// Decrements the remaining count; completes the barrier when count reaches zero.
  void signal() {
    _remaining--;
    if (_remaining <= 0) _completer?.complete();
  }

  /// Future that completes when the barrier has received [count] signals.
  Future<void> get future {
    final c = _completer ??= Completer<void>();
    if (_remaining <= 0 && !c.isCompleted) c.complete();
    return c.future;
  }

  @override
  String toString() => 'AsyncBarrierUtils(count: $count, remaining: $_remaining)';
}
