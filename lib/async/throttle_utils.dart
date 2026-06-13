import 'dart:async';

import 'package:saropa_dart_utils/async/debounce_utils.dart' show CancelableCallback;

/// Callback with no arguments.
typedef VoidCallback = void Function();

/// Throttle (time) — max one call per interval. Roadmap #177.
///
/// The returned closure cannot be cancelled: a pending trailing invocation still
/// fires after [interval] even if the owner is disposed. Use
/// [throttleCancelable] when you need to drop a pending call on teardown.
/// Audited: 2026-06-12 11:26 EDT
VoidCallback throttle(VoidCallback fn, Duration interval) {
  DateTime? lastCall;
  Timer? timer;
  return () {
    final DateTime now = DateTime.now();
    final last = lastCall;
    if (last == null || now.difference(last) >= interval) {
      lastCall = now; // ignore: avoid_unused_assignment - used on next invocation
      fn();
      return;
    }
    if (timer?.isActive ?? false) return;
    final newTimer = Timer(
      interval,
      () {
        lastCall = DateTime.now();
        fn();
      },
    );
    timer = newTimer;
  };
}

/// Like [throttle], but returns a [CancelableCallback] so a pending trailing
/// invocation can be dropped via [CancelableCallback.cancel] — call it on dispose
/// so [fn] never fires after teardown and the `Timer` does not leak.
/// Audited: 2026-06-13
CancelableCallback throttleCancelable(VoidCallback fn, Duration interval) {
  DateTime? lastCall;
  Timer? timer;
  return CancelableCallback(
    () {
      final DateTime now = DateTime.now();
      final last = lastCall;
      if (last == null || now.difference(last) >= interval) {
        lastCall = now; // ignore: avoid_unused_assignment - used on next invocation
        fn();
        return;
      }
      if (timer?.isActive ?? false) return;
      timer = Timer(interval, () {
        lastCall = DateTime.now();
        fn();
      });
    },
    () => timer?.cancel(),
  );
}
