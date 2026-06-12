import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/date_time_arithmetic_extensions.dart';
import 'package:saropa_dart_utils/datetime/date_time_utils.dart';
import 'package:saropa_dart_utils/int/int_string_extensions.dart';

// Re-export split files for backward compatibility
export 'date_time_arithmetic_extensions.dart';
export 'date_time_calendar_extensions.dart';
export 'date_time_comparison_extensions.dart';

/// Error message for year values exceeding the maximum.
const String _yearExceedsMaxMessage = '[year] must be <= 9999';

/// One day duration, used for day arithmetic.
/// Audited: 2026-06-12 11:26 EDT
const Duration _oneDay = Duration(days: 1);

/// Extensions on the [DateTime] class to provide additional functionality.
extension DateTimeExtensions on DateTime {
  /// Returns the date of the [n]th occurrence of [dayOfWeek] within the
  /// current instance's month and year, or `null` if it does not exist
  /// (e.g., 5th Friday in February).
  ///
  /// [n] is the desired occurrence (e.g., 1 for the 1st, 2 for the 2nd).
  /// [dayOfWeek] is the day of the week (e.g., [DateTime.monday]).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime? getNthWeekdayOfMonthInYear(int n, int dayOfWeek) {
    if (n < 1) {
      return null;
    }

    final int firstWeekday = DateTime(year, month).weekday;

    final int offset =
        (dayOfWeek - firstWeekday + DateConstants.daysPerWeek) % DateConstants.daysPerWeek;

    // Compute the target day-of-month directly and let DateTime normalize any
    // overflow into the next month (caught by the month check below). Calendar
    // fields, NOT `add(Duration(days: ...))`: a fixed-day Duration step on a
    // LOCAL DateTime drifts off midnight across a DST boundary and a fall-back
    // (25h) day can push the result back onto the previous calendar day.
    final int targetDay = 1 + offset + (n - 1) * DateConstants.daysPerWeek;
    final DateTime nthOccurrence = DateTime(year, month, targetDay);
    if (nthOccurrence.month != month) {
      return null;
    }

    return nthOccurrence;
  }

  /// Returns `true` if the date (of birth) is under 13 years old.
  ///
  /// This is useful for determining non-child content access based on
  /// the Children's Online Privacy Protection Act (COPPA).
  ///
  /// [today] can be optionally provided to specify the date to compare
  /// against. If not provided, the current date is used.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool isUnder13({DateTime? today}) {
    final DateTime resolvedToday = today ?? DateTime.now();

    if (isAfter(resolvedToday)) {
      return false;
    }

    final DateTime thirteenthBirthday = addYears(DateConstants.coppaMinAge);

    return resolvedToday.isBefore(thirteenthBirthday);
  }

  /// Returns a list of [DateTime] objects for consecutive days.
  ///
  /// Starts from `this` and generates [days] number of dates. If
  /// [isStartOfDay] is `true` (default), each date is set to midnight.
  ///
  /// NOTE: returns an empty list when [days] is 0.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  List<DateTime> generateDayList(int days, {bool isStartOfDay = true}) {
    DateTime currentDate = this;

    return List<DateTime>.generate(
      days,
      (_) {
        final DateTime result = currentDate;
        currentDate = currentDate.nextDay(isStartOfDay: isStartOfDay);

        return result;
      },
    );
  }

  /// Returns the previous day.
  ///
  /// This method calculates the day before the current [DateTime] object.
  /// It handles month and year changes correctly.
  /// [isStartOfDay] if true, returns the previous day at 00:00:00.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime prevDay({bool isStartOfDay = true}) {
    DateTime result = subtract(_oneDay);
    if (isStartOfDay) {
      result = DateTime(result.year, result.month, result.day);
    }

    return result;
  }

  /// Returns the next day.
  ///
  /// This method calculates the day after the current [DateTime] object.
  /// It handles month and year changes correctly.
  /// [isStartOfDay] if true, returns the next day at 00:00:00.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime nextDay({bool isStartOfDay = true}) {
    DateTime result = add(_oneDay);
    if (isStartOfDay) {
      result = DateTime(result.year, result.month, result.day);
    }

    return result;
  }

  /// Checks if the current year is a leap year using
  /// [DateTimeUtils.isLeapYear].
  ///
  /// Returns:
  ///   bool: True if the year is a leap year, false otherwise.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool isLeapYear() => DateTimeUtils.isLeapYear(year: year);

  /// Gets the start date of the year.
  ///
  /// Returns:
  ///   DateTime: The first day of the year.
  ///
  /// Throws:
  ///   ArgumentError: If the year is greater than 9999.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime get yearStart {
    if (year > DateConstants.maxYear) {
      throw ArgumentError(_yearExceedsMaxMessage);
    }

    return DateTime(year);
  }

  /// Gets the end date of the year.
  ///
  /// Returns:
  ///   DateTime: The last day of the year.
  ///
  /// Throws:
  ///   ArgumentError: If the year is greater than 9999.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime get yearEnd {
    if (year > DateConstants.maxYear) {
      throw ArgumentError(_yearExceedsMaxMessage);
    }

    return DateTime(year, DateTime.december, DateConstants.decemberLastDay);
  }

  /// Checks if the current time is exactly midnight (00:00:00.000000).
  ///
  /// All time components — including milliseconds and microseconds — must be
  /// zero. A time of 00:00:00.001 is not considered midnight.
  ///
  /// Returns:
  ///   bool: True if the time is exactly midnight, false otherwise.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isMidnight =>
      hour == 0 && minute == 0 && second == 0 && millisecond == 0 && microsecond == 0;

  /// Ignores the year of the current [DateTime] and returns a new [DateTime]
  /// with the specified [setYear].
  ///
  /// Requires `month` and `day` to be set in the current [DateTime].
  ///
  /// Returns null if the date is invalid in [setYear] — for example, when
  /// this is February 29 (a leap day) and [setYear] is not a leap year.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime? toDateInYear(int setYear) {
    if (month == DateTime.february && day == DateConstants.daysInFebLeapYear) {
      final bool isTargetLeap = DateTimeUtils.isLeapYear(year: setYear);
      if (!isTargetLeap) {
        return null;
      }
    }

    return DateTime(
      setYear,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Returns the ordinal representation of the day of the month.
  ///
  /// For example, for the 1st day of the month, it returns "1st".
  /// For the 2nd day, it returns "2nd", and so on.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String dayOfMonthOrdinal() => day.ordinal();
}
