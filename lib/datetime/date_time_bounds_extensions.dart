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
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// Start of week. [firstWeekday] 1 = Monday, 7 = Sunday (default Monday).
  @useResult
  DateTime startOfWeek({int firstWeekday = DateTime.monday}) {
    final int delta =
        (weekday - firstWeekday + DateConstants.daysPerWeek) % DateConstants.daysPerWeek;
    return DateTime(year, month, day - delta);
  }

  /// End of week (last day 23:59:59.999999). [firstWeekday] 1 = Monday.
  @useResult
  DateTime endOfWeek({int firstWeekday = DateTime.monday}) {
    final DateTime start = startOfWeek(firstWeekday: firstWeekday);
    return DateTime(start.year, start.month, start.day + 6, 23, 59, 59, 999, 999);
  }

  /// Start of month (first day 00:00:00).
  @useResult
  DateTime get startOfMonth => DateTime(year, month);

  /// End of month (last day 23:59:59.999999).
  @useResult
  DateTime get endOfMonth {
    final int lastDay = DateTimeUtils.monthDayCount(year: year, month: month);
    return DateTime(year, month, lastDay, 23, 59, 59, 999, 999);
  }

  /// Quarter (1–4).
  @useResult
  int get quarter => ((month - 1) / 3).floor() + 1;

  /// Start of quarter (first day of quarter month 00:00:00).
  @useResult
  DateTime get startOfQuarter {
    final int qMonth = (quarter - 1) * 3 + 1;
    return DateTime(year, qMonth);
  }

  /// End of quarter (last day of quarter month 23:59:59.999999).
  @useResult
  DateTime get endOfQuarter {
    final int qMonth = quarter * 3;
    final int lastDay = DateTimeUtils.monthDayCount(year: year, month: qMonth);
    return DateTime(year, qMonth, lastDay, 23, 59, 59, 999, 999);
  }

  /// Start of year (Jan 1 00:00:00). Same as [DateTime.yearStart] in date_time_extensions.
  @useResult
  DateTime get startOfYear => DateTime(year);

  /// End of year (Dec 31 23:59:59.999999).
  @useResult
  DateTime get endOfYear =>
      DateTime(year, DateTime.december, DateConstants.decemberLastDay, 23, 59, 59, 999, 999);

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
}
