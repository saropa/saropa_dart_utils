/// Async barrier: wait for N events — roadmap #676.
library;

import 'dart:async' show Completer; // ignore: require_ios_deployment_target_consistency

/// Barrier that completes when [count] signals received.
class AsyncBarrier {
  static const String _kErrCountAtLeastOne = 'count >= 1';

  factory AsyncBarrier(int count) {
    if (count < 1) throw ArgumentError(_kErrCountAtLeastOne);
    return AsyncBarrier._(count);
  }

  AsyncBarrier._(int count) : _count = count, _remaining = count;
  final int _count;

  /// Total number of signals required for the barrier to complete.
  int get count => _count;
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
    if (_remaining <= 0) c.complete();
    return c.future;
  }

  @override
  String toString() => 'AsyncBarrier(count: $_count, remaining: $_remaining)';
}
