import 'package:intl/intl.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

/// A utility class for working with [DateTime] objects.
class DateTimeUtils {
  /// Calculates the age at death based on the date of birth (DOB) and date
  /// of death (DOD).
  ///
  /// Args:
  ///   dob (DateTime?): The date of birth.
  ///   dod (DateTime?): The date of death.
  ///
  /// Returns:
  ///   int?: The calculated age at death, or null if either [dob] or [dod]
  ///   is null, or if [dod] is before [dob].
  static int? calculateAgeAtDeath({
    required DateTime? dob,
    required DateTime? dod,
  }) {
    // Check if either dob or dod is null
    if (dob == null || dod == null) {
      return null;
    }

    // Check if dod is before dob
    if (dod.isBefore(dob)) {
      return null;
    }

    int age = dod.year - dob.year;

    // Adjust age if the birthday hasn't occurred yet in the dod year
    if (dod.month < dob.month ||
        (dod.month == dob.month && dod.day < dob.day)) {
      age--;
    }

    return age;
  }

  /// Extracts a 4-digit year from a given string.
  ///
  /// This function uses a regular expression to search for a 4-digit year
  /// within the input string. If a year is found, it returns the year as an
  /// integer. If no year is found, it returns null.
  ///
  /// Example:
  /// ```dart
  /// int? year = extractYear('April–August 1976, Bulgaria');  // Output: 1976
  /// ```
  ///
  /// @param input The string to search for a 4-digit year.
  /// @return The extracted year as an integer, or null if no year is found.
  static int? extractYear(String input) {
    // Regular expression to match a 4-digit year
    final RegExp yearRegex = RegExp(r'\b\d{4}\b');

    // Search for the first match of the regex in the input string
    // \b in a regular expression is a word boundary anchor
    final RegExpMatch? match = yearRegex.firstMatch(input);

    // If a match is found, try to parse it as an integer and return it
    final String? groupValue = match?.group(0);
    if (groupValue == null) {
      // If no match is found, return null
      return null;
    }

    return int.tryParse(groupValue);
  }

  /// Returns the date for tomorrow at the specified time.
  ///
  /// Args:
  ///   now (DateTime?): The current date and time. Defaults to null (uses
  ///   the actual current date and time).
  ///   hour (int?): The hour for tomorrow's date. Defaults to 0.
  ///   minute (int?): The minute for tomorrow's date. Defaults to 0.
  ///   second (int?): The second for tomorrow's date. Defaults to 0.
  ///
  /// Returns:
  ///   DateTime: The date for tomorrow at the specified time.
  static DateTime tomorrow({
    DateTime? now,
    int? hour,
    int? minute = 0,
    int? second = 0,
  }) {
    // Get the current date and time
    now ??= DateTime.now();

    // Calculate the date for tomorrow at the specified time
    final DateTime tomorrowAtSpecifiedTime = now.addDays(1);

    return tomorrowAtSpecifiedTime.copyWith(
      hour: hour ?? 0,
      minute: minute ?? 0,
      second: second ?? 0,
      microsecond: 0,
    );
  }

  /// Method to check if the device date format is month first.
  ///
  /// The method uses the `DateFormat` class from the `intl` package to format a
  /// test date, and then checks if the month appears before the day in the
  /// resulting string.
  ///
  /// Note: This method assumes that the device's locale has been properly set.
  /// If the locale is not set, the method may not return accurate results.
  static bool isDeviceDateMonthFirst() {
    // Create a test date (2nd of January 2023) with a KNOWN month and day
    final DateTime testDate = DateTime(2023, 2);

    // Format the test date using the device's locale
    final String formattedDate = DateFormat.yMd().format(testDate);

    // Check if the month (2) appears before the day (1) in the formatted string
    return formattedDate.indexOf('2') < formattedDate.indexOf('1');
  }

  /// Function to convert an integer representing days into a string format of
  ///  years and months.
  ///
  /// @param days - The number of days as an integer.
  /// @return A string in the format of "X year(s) and Y month(s)".
  static String? convertDaysToYearsAndMonths(int? days) {
    if (days == null || days < 1) {
      return null;
    }

    // Calculate the number of years by integer division of the days by 365.
    final int years = days ~/ 365;

    // Calculate the remaining number of months by first getting the
    // remainder of days when divided by 365 (which gives the number of
    // days in the current year), then doing integer division by 30.
    final int months = (days % 365) ~/ 30;

    // Determine whether to use singular or plural form for "year" and
    // "month".
    final String yearStr = (years == 1) ? 'year' : 'years';
    final String monthStr = (months == 1) ? 'month' : 'months';

    // Construct the result string.
    if (years > 0 && months > 0) {
      return '$years $yearStr and $months $monthStr';
    } else if (years > 0) {
      return '$years $yearStr';
    } else if (months > 0) {
      return '$months $monthStr';
    } else {
      return '0 days';
    }
  }

  /// Calculates the first day of the next month for a given month and year.
  ///
  /// Args:
  ///   month (int): The month (1-12).
  ///   year (int): The year.
  ///
  /// Returns:
  ///   DateTime?: The first day of the next month, or null if the month is
  ///   invalid.
  static DateTime? firstDayNextMonth({
    required int month,
    required int year,
  }) {
    // ref: https://stackoverflow.com/questions/61881850/sort-list-based-on-boolean
    // ref: https://stackoverflow.com/questions/67144785/flutter-dart-datetime-max-min-value
    if (month < 1 || month > 12) {
      // invalid
      return null;
    }

    // there are ALWAYS 28 days in any month
    final DateTime someDayNextMonth = DateTime(year, month, 28).addDays(4);

    return DateTime(someDayNextMonth.year, someDayNextMonth.month);
  }

  /// Returns the later of two dates.
  ///
  /// If [date2] is null, [date1] is returned.
  static DateTime maxDate(
    DateTime date1,
    DateTime? date2,
  ) {
    if (date2 == null) {
      return date1;
    }

    return date1.compareTo(date2) >= 0 ? date1 : date2;
  }

  /// Returns the earlier of two dates.
  ///
  /// If [date2] is null, [date1] is returned.
  static DateTime minDate(
    DateTime date1,
    DateTime? date2,
  ) {
    if (date2 == null) {
      return date1;
    }

    return date1.compareTo(date2) <= 0 ? date1 : date2;
  }

  /// Checks if the given year is a leap year.
  ///
  /// Returns true if the year is a leap year, false otherwise.
  static bool isLeapYear({
    required int year,
  }) {
    // A year is a leap year if it is divisible by 4
    return year % 4 == 0
        // A year is not a leap year if it is divisible by 100
        &&
        (year % 100 != 0
            // unless it is also divisible by 400
            ||
            year % 400 == 0);
  }

  /// Returns the number of days in the given month and year.
  ///
  /// Takes into account leap years for February.
  static int monthDayCount({
    required int year,
    required int month,
  }) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }

    const List<int> daysInMonth = <int>[
      31,
      28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];

    if (month == 2 &&
        isLeapYear(
          year: year,
        )) {
      return 29;
    }

    return daysInMonth[month - 1];
  }
}
