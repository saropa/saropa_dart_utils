/// Cooperative cancellation tokens — roadmap #674.
///
/// A [CancellationToken] is a one-shot signal a long-running task polls to stop
/// early. Cancellation is cooperative: the token never interrupts running code,
/// so the task must still check [CancellationToken.throwIfCancelled] (or await
/// [CancellationToken.whenCancelled]) at safe points. [runCancellable] only
/// stops *awaiting* a future when the token cancels; it cannot abort the work
/// the future represents.
library;

import 'dart:async' show Completer, Future, scheduleMicrotask, unawaited;

// ignore_for_file: saropa_lints/prefer_await_over_then -- runCancellable deliberately uses .then to race task completion against cancellation; awaiting the task would block until it finishes and defeat the early-out on cancel

/// Thrown when work is abandoned because its [CancellationToken] was cancelled.
class CancellationException implements Exception {
  /// Creates a cancellation exception carrying an optional [reason].
  const CancellationException([this.reason]);

  /// Optional caller-supplied explanation for the cancellation.
  final Object? reason;

  @override
  String toString() {
    final Object? capturedReason = reason;
    if (capturedReason == null) {
      return 'CancellationException';
    }
    // capturedReason is provably non-null here, so its toString() is safe and
    // never renders the literal 'null'.
    return 'CancellationException: ${capturedReason.toString()}';
  }
}

/// A one-shot cooperative cancellation signal.
///
/// Cancellation is idempotent and irreversible: the first [cancel] latches the
/// state and records the reason; later calls are no-ops. Consumers poll
/// [throwIfCancelled], await [whenCancelled], or register an [onCancel]
/// callback. The token never preempts running code — see the library doc.
class CancellationToken {
  final Completer<void> _completer = Completer<void>();
  final List<void Function()> _callbacks = <void Function()>[];
  bool _isCancelled = false;
  Object? _reason;

  /// Whether [cancel] has been called.
  bool get isCancelled => _isCancelled;

  /// The reason passed to [cancel], or `null` if none was supplied / not yet
  /// cancelled.
  Object? get reason => _reason;

  /// Completes once the token is cancelled; never completes with an error.
  Future<void> get whenCancelled => _completer.future;

  /// Cancels the token with an optional [reason]; a second call is a no-op.
  void cancel([Object? reason]) {
    // Idempotent: only the first cancel latches state and fires callbacks.
    if (_isCancelled) {
      return;
    }
    _isCancelled = true;
    _reason = reason;
    _completer.complete();
    // Drain registered callbacks once; clear so each fires exactly once.
    final List<void Function()> pending = List<void Function()>.of(_callbacks);
    _callbacks.clear();
    for (final void Function() callback in pending) {
      callback();
    }
  }

  /// Throws a [CancellationException] (carrying [reason]) if already cancelled.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancellationException(_reason);
    }
  }

  /// Registers [callback] to fire exactly once when the token is cancelled.
  ///
  /// If the token is already cancelled, [callback] is scheduled on a microtask
  /// so registration is always asynchronous and never re-enters the caller.
  void onCancel(void Function() callback) {
    // Already cancelled: schedule immediately rather than queueing forever.
    if (_isCancelled) {
      scheduleMicrotask(callback);
      return;
    }
    _callbacks.add(callback);
  }
}

/// Awaits [task] but stops waiting if [token] cancels first.
///
/// Returns the task's value on normal completion. If [token] cancels before the
/// task completes, throws a [CancellationException] carrying the token's reason.
/// Cooperative only: the task keeps running after a cancel — this helper merely
/// stops awaiting it, so the task should also check [token] at safe points.
///
/// Example:
/// ```dart
/// final CancellationToken token = CancellationToken();
/// final int value = await runCancellable(token, () async => 42);
/// ```
Future<T> runCancellable<T>(
  CancellationToken token,
  Future<T> Function() task,
) {
  final Completer<T> completer = Completer<T>();

  // Cancellation wins the race: surface the token's reason as an exception.
  // Capture the stack at registration so the async error chain points back here
  // rather than to the bare completeError call site.
  final StackTrace cancelStack = StackTrace.current;
  token.onCancel(() {
    if (!completer.isCompleted) {
      completer.completeError(CancellationException(token.reason), cancelStack);
    }
  });

  // Task completion wins the race: forward its value or error if still pending.
  unawaited(
    task().then(
      (T value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    ),
  );

  return completer.future;
}
