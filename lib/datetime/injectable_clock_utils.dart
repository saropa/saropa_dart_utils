/// Injectable clock for tests (consistent "now") — roadmap #614.
library;

/// Abstract clock; implementations provide a deterministic or live "now".
abstract class InjectableClockUtils {
  /// Current time for this clock.
  DateTime now();
}

/// Live clock.
class SystemClock implements InjectableClockUtils {
  static const String _kToStringPrefix = 'SystemClock()';

  @override
  DateTime now() => DateTime.now();

  @override
  String toString() => _kToStringPrefix;
}

/// Fixed clock for tests.
class FixedClock implements InjectableClockUtils {
  FixedClock(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;

  @override
  String toString() => 'FixedClock(now: $_now)';
}

final _defaultClockHolder = _ClockHolder(SystemClock());

/// Current clock used by code that depends on injectable time.
/// Tests can set this to a [FixedClock] for deterministic "now".
InjectableClockUtils get defaultClock => _defaultClockHolder.clock;

/// Sets the injectable clock (e.g. [FixedClock] in tests).
set defaultClock(InjectableClockUtils value) => _defaultClockHolder.clock = value;

class _ClockHolder {
  _ClockHolder(this._clock);
  InjectableClockUtils _clock;

  InjectableClockUtils get clock => _clock;

  set clock(InjectableClockUtils value) => _clock = value;

  @override
  String toString() => '_ClockHolder(clock: $_clock)';
}
