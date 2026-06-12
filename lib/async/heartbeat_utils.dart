/// Heartbeat/keepalive for long-running tasks — roadmap #675.
library;

import 'dart:async' show Timer; // ignore: require_ios_deployment_target_consistency

/// Calls [onBeat] every [interval] until [stop] or [dispose] is called.
class HeartbeatUtils {
  /// Creates a heartbeat that invokes [onBeat] every [interval] once [start]
  /// is called.
  /// Audited: 2026-06-12 11:26 EDT
  HeartbeatUtils(Duration interval, void Function() onBeat)
    : _interval = interval,
      _onBeat = onBeat;
  final Duration _interval;

  /// Interval between heartbeat callbacks.
  /// Audited: 2026-06-12 11:26 EDT
  Duration get interval => _interval;
  final void Function() _onBeat;

  /// Callback invoked every [interval] while running.
  /// Audited: 2026-06-12 11:26 EDT
  void Function() get onBeat => _onBeat;
  Timer? _timer;

  /// Releases the timer; call when the heartbeat is no longer needed.
  /// Audited: 2026-06-12 11:26 EDT
  void dispose() => stop();

  /// Starts the periodic heartbeat; cancels any existing timer.
  /// Audited: 2026-06-12 11:26 EDT
  void start() {
    _timer?.cancel();
    // ignore: saropa_lints/avoid_work_in_paused_state, saropa_lints/require_workmanager_for_background -- pure-Dart utility primitive; app-lifecycle pausing and Android WorkManager scheduling are the consuming app's responsibility, not this library's
    _timer = Timer.periodic(_interval, (_) => _onBeat());
  }

  /// Stops the heartbeat and cancels the timer.
  /// Audited: 2026-06-12 11:26 EDT
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  String toString() => 'HeartbeatUtils(interval: $_interval, active: ${_timer != null})';
}
