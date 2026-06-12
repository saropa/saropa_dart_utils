/// "Quiet hours" helper — roadmap #613.
///
/// Tests whether an instant falls inside a configured daily mute window (e.g.
/// 22:00–07:00 "do not disturb") and, when it does, reports when quiet ends — so
/// a notification can be deferred to [quietUntil] instead of firing during the
/// blackout. Windows are minute-of-day and may wrap past midnight (start > end),
/// which is the common overnight case.
///
/// This is the time-of-day blackout primitive; it is intentionally simpler than
/// `BusinessHours` (#595), which models a per-weekday OPEN schedule. Quiet
/// windows here apply every day.
library;

/// A daily quiet window in minutes past midnight. When [startMinute] <
/// [endMinute] it is a same-day window `[start, end)`; when [startMinute] >
/// [endMinute] it WRAPS past midnight (e.g. `1320`→`420` is 22:00–07:00). The
/// two bounds must differ (a zero-length window mutes nothing; a full-day mute
/// has no well-defined end).
class QuietWindow {
  /// Creates a window from [startMinute] to [endMinute] (0..1440), wrapping when
  /// start > end.
  /// Audited: 2026-06-12 11:26 EDT
  const QuietWindow(this.startMinute, this.endMinute)
    : assert(startMinute >= 0 && startMinute <= 1440, 'startMinute must be 0..1440'),
      assert(endMinute >= 0 && endMinute <= 1440, 'endMinute must be 0..1440'),
      assert(startMinute != endMinute, 'startMinute and endMinute must differ');

  /// Inclusive start minute past midnight.
  final int startMinute;

  /// Exclusive end minute past midnight.
  final int endMinute;

  /// Whether [minuteOfDay] falls inside this window, honoring midnight wrap.
  /// Audited: 2026-06-12 11:26 EDT
  bool containsMinute(int minuteOfDay) {
    if (startMinute < endMinute) {
      return minuteOfDay >= startMinute && minuteOfDay < endMinute;
    }
    // Wrapped window: the evening tail `[start, 1440)` OR the morning head
    // `[0, end)` of the next calendar day.
    return minuteOfDay >= startMinute || minuteOfDay < endMinute;
  }
}

/// A set of daily quiet windows with point-in-time and "when does quiet end"
/// queries. Immutable.
class QuietHours {
  /// Creates quiet hours from [windows] (applied every day).
  /// Audited: 2026-06-12 11:26 EDT
  const QuietHours(this.windows);

  /// Convenience for a single daily window `[startMinute, endMinute)`.
  /// Audited: 2026-06-12 11:26 EDT
  factory QuietHours.daily(int startMinute, int endMinute) =>
      QuietHours(<QuietWindow>[QuietWindow(startMinute, endMinute)]);

  /// The configured quiet windows.
  final List<QuietWindow> windows;

  /// Whether [at] falls inside any quiet window (minute resolution).
  /// Audited: 2026-06-12 11:26 EDT
  bool isQuiet(DateTime at) {
    final int minute = _minuteOfDay(at);
    return windows.any((QuietWindow w) => w.containsMinute(minute));
  }

  /// If [at] is within quiet hours, the instant quiet ends (so a deferred
  /// notification can be scheduled for then); otherwise null. Back-to-back and
  /// overlapping windows are chained so the result is the end of the contiguous
  /// quiet stretch, not just the first window.
  /// Audited: 2026-06-12 11:26 EDT
  DateTime? quietUntil(DateTime at) {
    if (!isQuiet(at)) {
      return null;
    }
    DateTime cursor = at;
    // Jump to the latest end of any window covering `cursor`, then stop unless
    // that boundary is itself the start of another (adjacent) quiet window. The
    // window-count bound caps a pathological all-day configuration.
    for (int i = 0; i <= windows.length; i++) {
      final DateTime? end = _latestEndCovering(cursor);
      if (end == null) {
        break;
      }
      cursor = end;
      if (!isQuiet(cursor)) {
        break;
      }
    }
    return cursor;
  }

  /// The latest end instant among the windows covering [at], or null if none.
  /// Audited: 2026-06-12 11:26 EDT
  DateTime? _latestEndCovering(DateTime at) {
    final int minute = _minuteOfDay(at);
    DateTime? latest;
    // Windows can overlap, so [at] may sit inside several at once. The caller
    // needs the furthest-out end (when quiet hours actually lift), hence we keep
    // the maximum end instant rather than returning on the first match.
    for (final QuietWindow w in windows) {
      // Skip windows that don't cover this minute-of-day.
      if (!w.containsMinute(minute)) {
        continue;
      }
      // Resolve the covering window's end to an absolute instant (today or
      // tomorrow for a midnight-wrapping window) and track the latest seen.
      final DateTime end = _endInstant(at, w, minute);
      if (latest == null || end.isAfter(latest)) {
        latest = end;
      }
    }
    return latest;
  }

  /// The instant window [w] (which covers [at] at [minute]) ends. A same-day
  /// window ends today; a wrapped window ends tomorrow when [at] is in the
  /// evening tail, today when it is in the morning head.
  /// Audited: 2026-06-12 11:26 EDT
  DateTime _endInstant(DateTime at, QuietWindow w, int minute) {
    final DateTime day = _dateOnly(at);
    if (w.startMinute < w.endMinute || minute < w.endMinute) {
      return _atMinute(day, w.endMinute);
    }
    return _atMinute(_addDays(day, 1), w.endMinute);
  }
}

/// Minutes past midnight for [t] (seconds/sub-second dropped — minute precision).
/// Audited: 2026-06-12 11:26 EDT
int _minuteOfDay(DateTime t) => t.hour * 60 + t.minute;

/// Midnight on [d]'s calendar day, preserving its UTC-ness (so the returned
/// instants stay in the input's zone).
/// Audited: 2026-06-12 11:26 EDT
DateTime _dateOnly(DateTime d) =>
    d.isUtc ? DateTime.utc(d.year, d.month, d.day) : DateTime(d.year, d.month, d.day);

/// Calendar-field day shift (not a `Duration`), DST-safe and UTC-preserving.
/// Audited: 2026-06-12 11:26 EDT
DateTime _addDays(DateTime d, int days) =>
    d.isUtc ? DateTime.utc(d.year, d.month, d.day + days) : DateTime(d.year, d.month, d.day + days);

/// The instant [minute] minutes past midnight on [day], preserving its UTC-ness.
/// `1440` normalizes to the next midnight.
/// Audited: 2026-06-12 11:26 EDT
DateTime _atMinute(DateTime day, int minute) {
  final int hour = minute ~/ 60;
  final int min = minute % 60;
  return day.isUtc
      ? DateTime.utc(day.year, day.month, day.day, hour, min)
      : DateTime(day.year, day.month, day.day, hour, min);
}
