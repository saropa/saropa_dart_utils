/// Injectable clock for tests (consistent "now") — roadmap #614.
library;

/// Abstract clock; implementations provide a deterministic or live "now".
abstract class Clock {
  /// Current time for this clock.
  DateTime now();
}

/// Live clock.
class SystemClock implements Clock {
  static const String _kToStringPrefix = 'SystemClock()';

  @override
  DateTime now() => DateTime.now();

  @override
  String toString() => _kToStringPrefix;
}

/// Fixed clock for tests.
class FixedClock implements Clock {
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
Clock get defaultClock => _defaultClockHolder.clock;

/// Sets the injectable clock (e.g. [FixedClock] in tests).
set defaultClock(Clock value) => _defaultClockHolder.clock = value;

class _ClockHolder {
  _ClockHolder(this._clock);
  Clock _clock;

  Clock get clock => _clock;

  set clock(Clock value) => _clock = value;

  @override
  String toString() => '_ClockHolder(clock: $_clock)';
}
