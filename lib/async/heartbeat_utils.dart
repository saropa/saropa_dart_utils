/// Heartbeat/keepalive for long-running tasks — roadmap #675.
library;

import 'dart:async' show Timer; // ignore: require_ios_deployment_target_consistency

/// Calls [onBeat] every [interval] until [stop] or [dispose] is called.
class Heartbeat {
  Heartbeat(Duration interval, void Function() onBeat) : _interval = interval, _onBeat = onBeat;
  final Duration _interval;

  /// Interval between heartbeat callbacks.
  Duration get interval => _interval;
  final void Function() _onBeat;

  /// Callback invoked every [interval] while running.
  void Function() get onBeat => _onBeat;
  Timer? _timer;

  /// Releases the timer; call when the heartbeat is no longer needed.
  void dispose() => stop();

  /// Starts the periodic heartbeat; cancels any existing timer.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _onBeat());
  }

  /// Stops the heartbeat and cancels the timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  String toString() => 'Heartbeat(interval: $_interval, active: ${_timer != null})';
}
