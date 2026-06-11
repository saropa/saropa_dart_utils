// Only the [DateTimeRange] type is needed here. Importing the whole material
// library would pull a heavy UI surface into a pure date-math file, so the
// `show` clause keeps the dependency narrow (mirrors iso_interval_parse_utils.dart).
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/date_time_utils.dart';

/// Start/end of day, week, month, quarter, year; quarter; next weekday; isWeekend.
extension DateTimeBoundsExtensions on DateTime {
  /// Start of day (00:00:00.000000).
  @useResult
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59.999999).
  @useResult
  DateTime get endOfDay => DateTime(
    year,
    month,
    day,
    DateConstants.maxHour,
    DateConstants.maxMinuteOrSecond,
    DateConstants.maxMinuteOrSecond,
    DateConstants.maxMillisecondOrMicrosecond,
    DateConstants.maxMillisecondOrMicrosecond,
  );

  /// Start of week. [firstWeekday] 1 = Monday, 7 = Sunday (default Monday).
  ///
  /// Returns the [DateTime] at 00:00:00 on the first day of the week.
  @useResult
  DateTime startOfWeek({int firstWeekday = DateTime.monday}) {
    final int delta =
        (weekday - firstWeekday + DateConstants.daysPerWeek) % DateConstants.daysPerWeek;
    return DateTime(year, month, day - delta);
  }

  /// End of week (last day 23:59:59.999999). [firstWeekday] 1 = Monday.
  ///
  /// Returns the [DateTime] at 23:59:59.999999 on the last day of the week.
  @useResult
  DateTime endOfWeek({int firstWeekday = DateTime.monday}) {
    final DateTime start = startOfWeek(firstWeekday: firstWeekday);
    return DateTime(
      start.year,
      start.month,
      start.day + DateConstants.lastDayOffsetInWeek,
      DateConstants.maxHour,
      DateConstants.maxMinuteOrSecond,
      DateConstants.maxMinuteOrSecond,
      DateConstants.maxMillisecondOrMicrosecond,
      DateConstants.maxMillisecondOrMicrosecond,
    );
  }

  /// Start of month (first day 00:00:00).
  @useResult
  DateTime get startOfMonth => DateTime(year, month);

  /// End of month (last day 23:59:59.999999).
  @useResult
  DateTime get endOfMonth {
    final int lastDay = DateTimeUtils.monthDayCount(year: year, month: month);
    return DateTime(
      year,
      month,
      lastDay,
      DateConstants.maxHour,
      DateConstants.maxMinuteOrSecond,
      DateConstants.maxMinuteOrSecond,
      DateConstants.maxMillisecondOrMicrosecond,
      DateConstants.maxMillisecondOrMicrosecond,
    );
  }

  /// Quarter (1–4).
  @useResult
  int get quarter =>
      ((month - DateConstants.minMonth) / DateConstants.monthsPerQuarter).floor() +
      DateConstants.minMonth;

  /// Start of quarter (first day of quarter month 00:00:00).
  @useResult
  DateTime get startOfQuarter {
    final int qMonth =
        (quarter - DateConstants.minMonth) * DateConstants.monthsPerQuarter +
        DateConstants.minMonth;
    return DateTime(year, qMonth);
  }

  /// End of quarter (last day of quarter month 23:59:59.999999).
  @useResult
  DateTime get endOfQuarter {
    final int qMonth = quarter * DateConstants.monthsPerQuarter;
    final int lastDay = DateTimeUtils.monthDayCount(year: year, month: qMonth);
    return DateTime(
      year,
      qMonth,
      lastDay,
      DateConstants.maxHour,
      DateConstants.maxMinuteOrSecond,
      DateConstants.maxMinuteOrSecond,
      DateConstants.maxMillisecondOrMicrosecond,
      DateConstants.maxMillisecondOrMicrosecond,
    );
  }

  /// Start of year (Jan 1 00:00:00). Same as [DateTime.yearStart] in date_time_extensions.
  @useResult
  DateTime get startOfYear => DateTime(year);

  /// End of year (Dec 31 23:59:59.999999).
  @useResult
  DateTime get endOfYear => DateTime(
    year,
    DateTime.december,
    DateConstants.decemberLastDay,
    DateConstants.maxHour,
    DateConstants.maxMinuteOrSecond,
    DateConstants.maxMinuteOrSecond,
    DateConstants.maxMillisecondOrMicrosecond,
    DateConstants.maxMillisecondOrMicrosecond,
  );

  /// True if Saturday or Sunday.
  @useResult
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Next date that is a weekday (skips Saturday/Sunday). If this is already weekday, returns this date at 00:00:00.
  @useResult
  DateTime nextWeekday() {
    DateTime d = DateTime(year, month, day);
    while (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return d;
  }

  /// Same calendar date as the receiver with time components from [other].
  ///
  /// Returns a new [DateTime] with this date and [other]'s time.
  @useResult
  DateTime sameTimeOn(DateTime other) => DateTime(
    year,
    month,
    day,
    other.hour,
    other.minute,
    other.second,
    other.millisecond,
    other.microsecond,
  );

  /// The month/day of this date pinned to the sentinel year 0 — the canonical
  /// "recurring annual date" form (birthday, anniversary, holiday-without-year).
  ///
  /// Stripping the year lets two dates be compared on month/day alone. Year 0
  /// is the agreed sentinel for "any year": this is the blessed producer for
  /// the existing consumer
  /// [DateTimeComparisonExtensions.isAnnualDateInRange], which treats a year-0
  /// [DateTime] as a month/day match against any year covered by a range.
  ///
  /// Edge cases / guarantees:
  /// - Time-of-day is dropped — the result is year-0 midnight (hour, minute,
  ///   second, millisecond, microsecond all 0).
  /// - Feb 29 survives. Year 0 is a leap year in Dart's proleptic Gregorian
  ///   calendar, so `DateTime(2024, 2, 29).toAnnualDate` is `DateTime(0, 2, 29)`
  ///   and does NOT roll over to Mar 1.
  /// - The result is a **local** (non-UTC) [DateTime], even when called on a
  ///   `DateTime.utc(...)`, because the year-0 value is built with the local
  ///   [DateTime] constructor. Annual dates carry no real instant, so the UTC
  ///   flag is intentionally not preserved.
  /// - Idempotent: a value already at year 0 maps to an equal value.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 3, 15, 10, 30).toAnnualDate; // DateTime(0, 3, 15)
  /// DateTime(1999, 3, 15).toAnnualDate == DateTime(2024, 3, 15).toAnnualDate; // true
  /// ```
  @useResult
  DateTime get toAnnualDate => DateTime(0, month, day);

  /// The full local calendar day of this date as a [DateTimeRange]:
  /// [startOfDay] (00:00:00.000000) to [endOfDay] (23:59:59.999999).
  ///
  /// Composes the existing day-bound getters so the bounds keep a single source
  /// of truth — a future change to [startOfDay] / [endOfDay] flows through here
  /// automatically. The end is the last representable instant before the next
  /// midnight (microsecond precision), deliberately NOT the millisecond-
  /// truncated `...59.999` form, so no real sub-millisecond instant of the day
  /// falls outside the range.
  ///
  /// Edge cases / guarantees:
  /// - Both bounds stay on this calendar day; Feb 29, Dec 31, and Jan 1 inputs
  ///   do not bleed into an adjacent day.
  /// - Bounds use wall-clock [DateTime] arithmetic, so on a DST-transition day
  ///   the range's real-time [DateTimeRange.duration] is NOT a clean
  ///   23h59m59.999999s — it is shorter (spring-forward) or longer (fall-back)
  ///   by the offset shift. This is intentional local-wall-clock semantics, not
  ///   a bug.
  /// - The bounds are **local** even for a UTC receiver, because [startOfDay] /
  ///   [endOfDay] build local [DateTime]s.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 3, 15, 10, 30).toDayRange();
  /// // start: DateTime(2024, 3, 15), end: DateTime(2024, 3, 15, 23, 59, 59, 999, 999)
  /// ```
  @useResult
  DateTimeRange toDayRange() => DateTimeRange(start: startOfDay, end: endOfDay);
}
