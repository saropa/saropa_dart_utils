/// SLA / due-date calculator over business hours + holidays — roadmap #595.
///
/// Answers "when is this due if it must be done within N working hours?" and
/// "how much working time elapsed between these two instants?", counting only
/// time inside a weekly [BusinessHours] schedule and skipping holidays from an
/// optional [BusinessCalendar]. Reuses the holiday-aware calendar (#593) for the
/// day-level skip and layers time-of-day open windows on top.
///
/// Open windows are half-open `[open, close)` and times are compared in the
/// instant's own zone; all date stepping uses calendar fields (not `Duration`)
/// so it never drifts across a DST boundary.
library;

import 'package:saropa_dart_utils/datetime/business_calendar_utils.dart';

/// A single open period within a day, expressed as minutes from midnight:
/// `[startMinute, endMinute)`. `09:00–17:00` is `OpenWindow(540, 1020)`.
class OpenWindow {
  /// Creates a window from [startMinute] to [endMinute] (minutes past midnight).
  /// Requires `0 <= startMinute < endMinute <= 1440`.
  /// Audited: 2026-06-12 11:26 EDT
  const OpenWindow(this.startMinute, this.endMinute)
    : assert(startMinute >= 0, 'startMinute must be >= 0'),
      assert(startMinute < endMinute, 'startMinute must be < endMinute'),
      assert(endMinute <= 1440, 'endMinute must be <= 1440 (minutes in a day)');

  /// Inclusive start, minutes past midnight.
  final int startMinute;

  /// Exclusive end, minutes past midnight.
  final int endMinute;
}

/// A weekly schedule of open windows keyed by `DateTime.weekday` (Mon = 1 …
/// Sun = 7). A weekday with no entry is fully closed.
class BusinessHours {
  /// Creates a schedule from [windowsByWeekday]. Each day's windows are copied
  /// and sorted by start so the calculators can walk them in order.
  /// Audited: 2026-06-12 11:26 EDT
  BusinessHours(Map<int, List<OpenWindow>> windowsByWeekday)
    : _windows = <int, List<OpenWindow>>{
        for (final MapEntry<int, List<OpenWindow>> e in windowsByWeekday.entries)
          e.key: (List<OpenWindow>.of(e.value)
            ..sort((OpenWindow a, OpenWindow b) => a.startMinute.compareTo(b.startMinute))),
      };

  /// Same open window every listed weekday (default Monday–Friday). The common
  /// "9-to-5 on weekdays" case without spelling out each day.
  /// Audited: 2026-06-12 11:26 EDT
  factory BusinessHours.uniform({
    required int openMinute,
    required int closeMinute,
    Set<int> days = const <int>{
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    },
  }) {
    final OpenWindow window = OpenWindow(openMinute, closeMinute);
    return BusinessHours(
      <int, List<OpenWindow>>{
        for (final int day in days) day: <OpenWindow>[window],
      },
    );
  }

  final Map<int, List<OpenWindow>> _windows;

  /// The open windows for [weekday] (Mon = 1 … Sun = 7), empty if closed.
  /// Audited: 2026-06-12 11:26 EDT
  List<OpenWindow> windowsFor(int weekday) => _windows[weekday] ?? const <OpenWindow>[];
}

/// Computes deadlines and elapsed working time against a [BusinessHours]
/// schedule, optionally skipping holidays from a [BusinessCalendar].
class SlaCalculator {
  /// Creates a calculator for [hours], optionally holiday-aware via [calendar].
  /// Audited: 2026-06-12 11:26 EDT
  const SlaCalculator(this.hours, {BusinessCalendar? calendar}) : _calendar = calendar;

  /// The weekly open-hours schedule.
  final BusinessHours hours;

  final BusinessCalendar? _calendar;

  /// Hard ceiling on the forward scan so a fully-closed schedule fails loudly
  /// instead of looping forever (~11 years of days).
  static const int _maxScanDays = 4000;

  /// Whether [at] falls inside an open window on a working day.
  /// Audited: 2026-06-12 11:26 EDT
  bool isOpen(DateTime at) {
    for (final (DateTime open, DateTime close) in _concreteWindows(at)) {
      if (!at.isBefore(open) && at.isBefore(close)) {
        return true;
      }
    }
    return false;
  }

  /// The instant [amount] of working time after [start], counting only open-hour
  /// time and skipping holidays/closed days. A non-positive [amount] returns
  /// [start] unchanged. Throws [StateError] if no deadline is reachable within
  /// [_maxScanDays] (e.g. an empty schedule).
  /// Audited: 2026-06-12 11:26 EDT
  DateTime addWorkingTime(DateTime start, Duration amount) {
    if (amount <= Duration.zero) {
      return start;
    }
    Duration remaining = amount;
    DateTime day = _dateOnly(start);
    for (int scanned = 0; scanned < _maxScanDays; scanned++) {
      for (final (DateTime open, DateTime close) in _concreteWindows(day)) {
        // Skip windows that ended before `start` (only possible on the first day).
        if (!close.isAfter(start)) {
          continue;
        }
        final DateTime from = open.isBefore(start) ? start : open;
        final Duration available = close.difference(from);
        if (remaining <= available) {
          return from.add(remaining);
        }
        remaining -= available;
      }
      day = _addDays(day, 1);
    }
    throw StateError('SLA deadline not reachable within $_maxScanDays days — check the schedule');
  }

  /// The amount of working time within `[start, end)`, counting only open-hour
  /// time on working days. Returns [Duration.zero] when [end] is not after
  /// [start].
  /// Audited: 2026-06-12 11:26 EDT
  Duration workingTimeBetween(DateTime start, DateTime end) {
    if (!end.isAfter(start)) {
      return Duration.zero;
    }
    Duration total = Duration.zero;
    DateTime day = _dateOnly(start);
    while (!day.isAfter(end)) {
      for (final (DateTime open, DateTime close) in _concreteWindows(day)) {
        // Clip the window to the query span before adding its length.
        final DateTime from = open.isBefore(start) ? start : open;
        final DateTime to = close.isAfter(end) ? end : close;
        if (to.isAfter(from)) {
          total += to.difference(from);
        }
      }
      day = _addDays(day, 1);
    }
    return total;
  }

  /// The concrete `[open, close)` instants for the calendar day of [reference],
  /// honoring holidays (empty when the day is a holiday) and the weekday
  /// schedule. Built in [reference]'s own zone.
  /// Audited: 2026-06-12 11:26 EDT
  List<(DateTime, DateTime)> _concreteWindows(DateTime reference) {
    final BusinessCalendar? calendar = _calendar;
    if (calendar != null && calendar.isHoliday(reference)) {
      return const <(DateTime, DateTime)>[];
    }
    return <(DateTime, DateTime)>[
      for (final OpenWindow w in hours.windowsFor(reference.weekday))
        (_atMinute(reference, w.startMinute), _atMinute(reference, w.endMinute)),
    ];
  }

  /// Builds the instant [minute] minutes past midnight on [reference]'s calendar
  /// day, preserving its UTC-ness. `1440` yields the next midnight (window end).
  /// Audited: 2026-06-12 11:26 EDT
  DateTime _atMinute(DateTime reference, int minute) {
    final int hour = minute ~/ 60;
    final int min = minute % 60;
    return reference.isUtc
        ? DateTime.utc(reference.year, reference.month, reference.day, hour, min)
        : DateTime(reference.year, reference.month, reference.day, hour, min);
  }
}

/// Midnight on [d]'s calendar day, preserving its UTC-ness so window instants
/// built from it stay in the same zone as the caller's input.
/// Audited: 2026-06-12 11:26 EDT
DateTime _dateOnly(DateTime d) =>
    d.isUtc ? DateTime.utc(d.year, d.month, d.day) : DateTime(d.year, d.month, d.day);

/// Calendar-field day shift (not a `Duration`), DST-safe and UTC-preserving.
/// Audited: 2026-06-12 11:26 EDT
DateTime _addDays(DateTime d, int days) =>
    d.isUtc ? DateTime.utc(d.year, d.month, d.day + days) : DateTime(d.year, d.month, d.day + days);
