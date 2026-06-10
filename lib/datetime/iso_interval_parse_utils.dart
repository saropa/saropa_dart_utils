/// ISO 8601 time-interval parser — roadmap #646.
///
/// Parses the three interval forms from ISO 8601 into a [DateTimeRange]:
///   * `start/end`       — two timestamps (`2026-01-01T00:00Z/2026-01-02T00:00Z`)
///   * `start/duration`  — a timestamp plus a duration (`2026-01-01/P1M`)
///   * `duration/end`    — a duration ending at a timestamp (`P7D/2026-01-08`)
///
/// The timestamp halves use Dart's native ISO 8601 datetime parsing; the
/// duration half is an ISO 8601 duration (`P[nY][nM][nW][nD][T[nH][nM][nS]]`)
/// applied with calendar arithmetic (years/months add as calendar units, not a
/// fixed number of days). Anything malformed throws a [FormatException].
library;

import 'package:flutter/material.dart' show DateTimeRange;

/// ISO 8601 duration: years/months/days (weeks folded into days) applied as
/// calendar units, plus a sub-day [time] portion (hours/minutes/seconds, which
/// may be fractional) applied as a fixed [Duration].
class _IsoDuration {
  const _IsoDuration(this.years, this.months, this.days, this.time);

  final int years;
  final int months;
  final int days;
  final Duration time;

  /// Applies this duration to [base] in direction [sign] (+1 forward, -1 back),
  /// preserving [base]'s time-of-day fields and UTC-ness. Calendar fields shift
  /// first (via the constructor's normalization), then the fixed [time] part.
  DateTime applyTo(DateTime base, int sign) {
    final DateTime shifted = base.isUtc
        ? DateTime.utc(
            base.year + sign * years,
            base.month + sign * months,
            base.day + sign * days,
            base.hour,
            base.minute,
            base.second,
            base.millisecond,
            base.microsecond,
          )
        : DateTime(
            base.year + sign * years,
            base.month + sign * months,
            base.day + sign * days,
            base.hour,
            base.minute,
            base.second,
            base.millisecond,
            base.microsecond,
          );
    return sign > 0 ? shifted.add(time) : shifted.subtract(time);
  }
}

/// `P[nY][nM][nW][nD][T[nH][nM][nS]]`; weeks combine with other fields here
/// (lenient vs. the strict spec where `PnW` stands alone). Time components allow
/// a decimal fraction; date components are whole units.
final RegExp _isoDurationPattern = RegExp(
  r'^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?'
  r'(?:T(?:(\d+(?:\.\d+)?)H)?(?:(\d+(?:\.\d+)?)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
);

/// Parses an ISO 8601 time interval into a [DateTimeRange]. Accepts the
/// `start/end`, `start/duration`, and `duration/end` forms, separated by `/`.
/// Throws a [FormatException] if the separator is missing, either half is
/// malformed, both halves are durations, or `start` ends up after `end`.
///
/// Example:
/// ```dart
/// parseIsoInterval('2026-01-01T00:00:00Z/P1DT12H');
/// // start 2026-01-01T00:00Z, end 2026-01-02T12:00Z
/// ```
DateTimeRange parseIsoInterval(String input) {
  final List<String> halves = input.trim().split('/');
  if (halves.length != 2) {
    throw FormatException('ISO interval must be two parts separated by "/"', input);
  }
  final String left = halves[0];
  final String right = halves[1];
  final bool leftIsDuration = left.startsWith('P');
  final bool rightIsDuration = right.startsWith('P');
  if (leftIsDuration && rightIsDuration) {
    throw FormatException('ISO interval cannot have two durations', input);
  }
  if (leftIsDuration) {
    final DateTime end = _parseDateTime(right);
    return _range(_parseIsoDuration(left).applyTo(end, -1), end, input);
  }
  final DateTime start = _parseDateTime(left);
  if (rightIsDuration) {
    return _range(start, _parseIsoDuration(right).applyTo(start, 1), input);
  }
  return _range(start, _parseDateTime(right), input);
}

/// Builds the range, rejecting an inverted interval (`start` after `end`) before
/// the [DateTimeRange] assertion would, with a clearer message.
DateTimeRange _range(DateTime start, DateTime end, String input) {
  if (start.isAfter(end)) {
    throw FormatException('ISO interval start is after end', input);
  }
  return DateTimeRange(start: start, end: end);
}

/// Parses one ISO 8601 timestamp half, throwing a [FormatException] on anything
/// `DateTime` can't read (used instead of `DateTime.parse`, which would throw a
/// less specific error and is flagged as unvalidated).
DateTime _parseDateTime(String value) {
  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Invalid ISO 8601 timestamp', value);
  }
  return parsed;
}

/// Parses an ISO 8601 duration string into an [_IsoDuration]. Requires at least
/// one component (a bare `P` or `PT` is rejected).
_IsoDuration _parseIsoDuration(String value) {
  final RegExpMatch? m = _isoDurationPattern.firstMatch(value);
  if (m == null || List<int>.generate(7, (int i) => i + 1).every((int g) => m.group(g) == null)) {
    throw FormatException('Invalid or empty ISO 8601 duration', value);
  }
  // Every captured group is digits (with an optional decimal for the time
  // fields), so each value always parses; the tryParse fallbacks are unreachable
  // and present only to satisfy the safe-parse lint. Absent optional components
  // default to zero.
  final int weeks = int.tryParse(m.group(3) ?? '0') ?? 0;
  final double hours = double.tryParse(m.group(5) ?? '0') ?? 0;
  final double minutes = double.tryParse(m.group(6) ?? '0') ?? 0;
  final double seconds = double.tryParse(m.group(7) ?? '0') ?? 0;
  // Sub-day fields become one fixed Duration; weeks fold into days. Years and
  // months stay as calendar units for applyTo to add via the DateTime ctor.
  final int micros = ((hours * 3600 + minutes * 60 + seconds) * Duration.microsecondsPerSecond).round();
  return _IsoDuration(
    int.tryParse(m.group(1) ?? '0') ?? 0,
    int.tryParse(m.group(2) ?? '0') ?? 0,
    (int.tryParse(m.group(4) ?? '0') ?? 0) + weeks * 7,
    Duration(microseconds: micros),
  );
}
