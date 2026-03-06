import 'dart:async';

/// Callback with no arguments.
typedef VoidCallback = void Function();

/// Throttle (time) — max one call per interval. Roadmap #177.
VoidCallback throttle(VoidCallback fn, Duration interval) {
  DateTime? lastCall;
  Timer? timer;
  return () {
    final DateTime now = DateTime.now();
    final last = lastCall;
    if (last == null || now.difference(last) >= interval) {
      lastCall = now;
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
