import 'dart:async'; // ignore: require_ios_deployment_target_consistency

/// Callback with no arguments.
typedef VoidCallback = void Function();

/// Debounce (time) — invokes [fn] after [delay] of no further calls. Roadmap #176.
VoidCallback debounce(VoidCallback fn, Duration delay) {
  Timer? timer;
  return () {
    timer?.cancel();
    final newTimer = Timer(
      delay,
      () {
        timer = null;
        fn();
      },
    );
    timer = newTimer;
  };
}
