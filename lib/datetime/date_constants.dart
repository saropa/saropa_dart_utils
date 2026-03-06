import 'package:meta/meta.dart';

/// Utility class providing static constants for commonly used date/time values.
///
/// This class cannot be instantiated. Access constants via `DateConstants.xxx`.
///
/// Example usage:
/// ```dart
/// DateTime epoch = DateConstants.unixEpochDate;
/// bool valid = month >= DateConstants.minMonth;
/// ```
// ignore: avoid_god_class
abstract final class DateConstants {
  // Date/Time Range Constants

  /// The year of the Unix epoch (January 1, 1970 00:00:00 UTC).
  static const int _unixEpochYear = 1970;

  /// Minimum valid month number (January).
  static const int minMonth = 1;

  /// Maximum valid month number (December).
  static const int maxMonth = 12;

  /// Maximum valid year in DateTime (9999).
  static const int maxYear = 9999;

  // Time Component Range Constants

  /// Maximum valid hour (23 for 24-hour format, 0-23 range).
  static const int maxHour = 23;

  /// Maximum valid minute or second (59 for 0-59 range).
  static const int maxMinuteOrSecond = 59;

  /// Maximum valid millisecond or microsecond (999 for 0-999 range).
  static const int maxMillisecondOrMicrosecond = 999;

  // Month Calculation Constants

  /// Minimum number of days that exist in any month (February in non-leap years).
  static const int minDaysInAnyMonth = 28;

  /// Days to add to safely reach next month (28 + 4 = 32 days > any month).
  static const int daysToAddToGetNextMonth = 4;

  /// Number of days in February during a leap year.
  static const int daysInFebLeapYear = 29;

  /// Default year to use for leap year calculations when year is not specified
  /// (chosen as a leap year).
  static const int defaultLeapYearCheckYear = 2000;

  // Leap Year Calculation Constants

  /// Modulo divisor for basic leap year check (divisible by 4).
  static const int leapYearModulo4 = 4;

  /// Modulo divisor for century leap year exception (divisible by 100).
  static const int leapYearModulo100 = 100;

  /// Modulo divisor for century leap year exception override (divisible by 400).
  static const int leapYearModulo400 = 400;

  // Day/Night Time Thresholds

  /// Hour threshold for start of "day" time (after 7am).
  static const int dayStartHour = 7;

  /// Hour threshold for end of "day" time (before 6pm/18:00).
  static const int dayEndHour = 18;

  /// January 1st, 1970 is known as the Unix epoch. It is the date and
  /// time that Unix systems use as the reference point for measuring
  /// time. This date was chosen arbitrarily by early Unix engineers
  /// because they needed a uniform and convenient date for the start
  /// of time.
  ///
  // NOTE: default month and day == 1
  static final DateTime unixEpochDate = DateTime.utc(_unixEpochYear);

  // Week and ISO Week Constants

  /// Number of days in a week.
  static const int daysPerWeek = 7;

  /// Days from start of week to end of week (0-based index of last weekday).
  static const int lastDayOffsetInWeek = 6;

  /// Number of months per quarter.
  static const int monthsPerQuarter = 3;

  /// Offset used in the ISO 8601 week number formula.
  static const int isoWeekOffset = 10;

  /// December day used to determine ISO weeks in a year.
  static const int isoWeekReferenceDay = 28;

  // Formatting and Conversion Constants

  /// Number of digits in a year for zero-padded formatting.
  static const int yearStringWidth = 4;

  /// Number of minutes in one hour.
  static const int minutesPerHour = 60;

  /// Last day of December.
  static const int decemberLastDay = 31;

  /// Minimum age for non-child content access under COPPA.
  static const int coppaMinAge = 13;
}

/// Utility class for month name operations.
abstract final class MonthUtils {
  /// Full month names indexed by month number (1-12).
  static const Map<int, String> monthLongNames = <int, String>{
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  /// Abbreviated month names indexed by month number (1-12).
  static const Map<int, String> monthShortNames = <int, String>{
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  /// List of all month numbers (1-12).
  static const List<int> monthNumbers = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  /// Returns the full name of the given [month] (1-12), or `null` if invalid.
  @useResult
  static String? getMonthLongName(int month) => monthLongNames[month];

  /// Returns the abbreviated name of the given [month] (1-12), or `null` if
  /// [month] is `null` or invalid.
  @useResult
  static String? getMonthShortName(int? month) => month == null ? null : monthShortNames[month];
}

/// Utility class for weekday name operations.
abstract final class WeekdayUtils {
  /// Full weekday names indexed by DateTime weekday constant (1 = Monday, 7 = Sunday).
  static const Map<int, String> dayLongNames = <int, String>{
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

  /// Abbreviated weekday names indexed by DateTime weekday constant.
  static const Map<int, String> dayShortNames = <int, String>{
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  /// Returns the full name of the given [dayOfWeek] (1=Monday, 7=Sunday), or
  /// `null` if [dayOfWeek] is `null` or invalid.
  @useResult
  static String? getDayLongName(int? dayOfWeek) =>
      dayOfWeek == null ? null : dayLongNames[dayOfWeek];

  /// Returns the abbreviated name of the given [dayOfWeek] (1=Monday,
  /// 7=Sunday), or `null` if [dayOfWeek] is `null` or invalid.
  @useResult
  static String? getDayShortName(int? dayOfWeek) =>
      dayOfWeek == null ? null : dayShortNames[dayOfWeek];
}

/// Utility class for serial date string parsing.
abstract final class SerialDateUtils {
  /// Parses a serial date string (ISO 8601 format) to DateTime.
  ///
  /// Args:
  ///   dateWithT: A date string in ISO 8601 format (e.g., "20231225T120000").
  ///
  /// Returns:
  ///   A DateTime object, or null if the string is null, empty, or invalid.
  @useResult
  static DateTime? serialToDateTime(String? dateWithT) {
    if (dateWithT == null || dateWithT.isEmpty) {
      return null;
    }

    return DateTime.tryParse(dateWithT);
  }
}
