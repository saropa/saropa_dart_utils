import 'dart:async'; // ignore: require_ios_deployment_target_consistency

/// Callback with no arguments.
typedef VoidCallback = void Function();

/// Debounce (time) — invokes [fn] after [delay] of no further calls. Roadmap #176.
///
/// The returned closure cannot be cancelled: a pending invocation still fires
/// after [delay] even if the owner (e.g. a widget) is disposed. Use
/// [debounceCancelable] when you need to drop a pending call on teardown.
/// Audited: 2026-06-12 11:26 EDT
VoidCallback debounce(VoidCallback fn, Duration delay) {
  Timer? timer;
  return () {
    timer?.cancel();
    final newTimer = Timer(
      delay,
      () {
        fn();
      },
    );
    timer = newTimer;
  };
}

/// A scheduled callback that is invoked like a function and can also be
/// cancelled.
///
/// Invoke it (`handle()`) to schedule the wrapped action per the
/// debounce/throttle policy; call [cancel] to drop any pending timer — e.g. when
/// the owning widget or controller is disposed — so the action does not fire
/// after teardown and the underlying `Timer` does not leak. The plain [debounce]
/// and `throttle` closures expose no such handle.
class CancelableCallback {
  /// Wraps the [_schedule] (invoke) and [_cancel] (drop-pending) actions.
  /// Audited: 2026-06-13
  CancelableCallback(this._schedule, this._cancel);

  final void Function() _schedule;
  final void Function() _cancel;

  /// Schedules the wrapped action per the debounce/throttle policy.
  /// Audited: 2026-06-13
  void call() => _schedule();

  /// Cancels any pending invocation. Safe to call more than once.
  /// Audited: 2026-06-13
  void cancel() => _cancel();
}

/// Like [debounce], but returns a [CancelableCallback] so a pending invocation
/// can be dropped via [CancelableCallback.cancel] — call it on dispose so [fn]
/// never fires after teardown and the `Timer` does not leak.
/// Audited: 2026-06-13
CancelableCallback debounceCancelable(VoidCallback fn, Duration delay) {
  Timer? timer;
  return CancelableCallback(
    () {
      timer?.cancel();
      timer = Timer(delay, fn);
    },
    () => timer?.cancel(),
  );
}
