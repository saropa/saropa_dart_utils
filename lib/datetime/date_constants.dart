/// `DateConstants` is a utility class in Dart that provides static constants
/// for commonly used dates. This class cannot be instantiated.
///
/// The `unixEpochDate` constant in this class represents the Unix epoch,
/// which is the date and time that Unix systems use as the reference point
/// for measuring time. The Unix epoch is defined as 00:00:00 Coordinated
/// Universal Time (UTC), Thursday, 1 January 1970.
///
/// Example usage:
/// ```dart
/// DateTime epoch = DateConstants.unixEpochDate;
/// ```
///
class DateConstants {
  /// January 1st, 1970 is known as the Unix epoch. It is the date and
  /// time that Unix systems use as the reference point for measuring
  /// time. This date was chosen arbitrarily by early Unix engineers
  /// because they needed a uniform and convenient date for the start
  /// of time.
  ///
  // NOTE: default month and day == 1
  static final DateTime unixEpochDate = DateTime.utc(1970);
}

/// Utility class for month name operations.
class MonthUtils {
  const MonthUtils._();

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

  /// Gets the full name of a month.
  static String? getMonthLongName(int month) => monthLongNames[month];

  /// Gets the abbreviated name of a month.
  static String? getMonthShortName(int? month) => month == null ? null : monthShortNames[month];
}

/// Utility class for weekday name operations.
class WeekdayUtils {
  const WeekdayUtils._();

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

  /// Gets the full name of a weekday.
  static String? getDayLongName(int? dayOfWeek) =>
      dayOfWeek == null ? null : dayLongNames[dayOfWeek];

  /// Gets the abbreviated name of a weekday.
  static String? getDayShortName(int? dayOfWeek) =>
      dayOfWeek == null ? null : dayShortNames[dayOfWeek];
}

/// Utility class for serial date string parsing.
class SerialDateUtils {
  const SerialDateUtils._();

  /// Parses a serial date string (ISO 8601 format) to DateTime.
  ///
  /// Args:
  ///   dateWithT: A date string in ISO 8601 format (e.g., "20231225T120000").
  ///
  /// Returns:
  ///   A DateTime object, or null if the string is null, empty, or invalid.
  static DateTime? serialToDateTime(String? dateWithT) {
    if (dateWithT == null || dateWithT.isEmpty) return null;
    return DateTime.tryParse(dateWithT);
  }
}
