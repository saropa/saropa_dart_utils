import 'dart:io';

import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

final RegExp _yearRegex = RegExp(r'\b\d{4}\b');

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
  static int? calculateAgeAtDeath({required DateTime? dob, required DateTime? dod}) {
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
    if (dod.month < dob.month || (dod.month == dob.month && dod.day < dob.day)) {
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
    final RegExp yearRegex = _yearRegex;

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
  static DateTime tomorrow({DateTime? now, int? hour, int minute = 0, int second = 0}) {
    // Get the current date and time
    now ??= DateTime.now();

    // Calculate the date for tomorrow at the specified time
    final DateTime tomorrowAtSpecifiedTime = now.addDays(1);

    return tomorrowAtSpecifiedTime.copyWith(
      hour: hour ?? 0,
      minute: minute,
      second: second,
      microsecond: 0,
    );
  }

  /// Method to check if the device date format is month first.
  ///
  /// This method directly checks the device's locale to determine if the
  /// date format is month-first.  It supports a limited number of locales
  /// known to commonly use month-first formats.
  ///
  /// Returns true if the locale is likely month-first (e.g., en_US, en_CA),
  /// false otherwise.
  /// Note: This method provides a simplified approximation and may not be
  /// accurate for all locales or regions within those locales.  Date format
  /// usage can be complex and vary.
  static bool isDeviceDateMonthFirst() {
    final String locale = Platform.localeName;

    /// Locales that are commonly month-first (MM/DD/YYYY)
    switch (locale) {
      case 'en_US':
      case 'en_PH':
      case 'en_CA': // Canadian English - month-day-year common but YYYY-MM-DD official
      case 'fil': // Filipino
      case 'fsm': // Micronesian - Federated States of Micronesia
      case 'gu_GU': // Guamanian - Guam
      case 'mh': // Marshallese - Marshall Islands
      // cspell: ignore Palauan
      case 'pw': // Palauan - Palau
      case 'en_BZ': // Belize
        return true;

      //Default to false, assuming day-first or year-first format for other locales.
      default:
        return false;
    }
  }

  /// Average number of days per year, accounting for leap years.
  /// (365 * 3 + 366) / 4 = 365.25
  static const double _avgDaysPerYear = 365.25;

  /// Average number of days per month.
  /// 365.25 / 12 = 30.4375
  static const double _avgDaysPerMonth = 30.4375;

  /// Converts an integer representing days into a human-readable string format
  /// of years, months, and optionally remaining days.
  ///
  /// This method uses average values that account for leap years:
  /// - Average days per year: 365.25 (accounts for leap years)
  /// - Average days per month: 30.4375 (365.25 / 12)
  ///
  /// Args:
  ///   days (int?): The number of days to convert. Returns null if null or < 1.
  ///   includeRemainingDays (bool): If true, includes remaining days in the output
  ///   when they don't form a complete month. Defaults to false.
  ///
  /// Returns:
  ///   String?: A human-readable string representing the duration, or null if
  ///   [days] is null or less than 1.
  ///
  /// Example:
  /// ```dart
  /// convertDaysToYearsAndMonths(400); // '1 year and 1 month'
  /// convertDaysToYearsAndMonths(365); // '1 year'
  /// convertDaysToYearsAndMonths(45); // '1 month'
  /// convertDaysToYearsAndMonths(45, includeRemainingDays: true); // '1 month and 14 days'
  /// convertDaysToYearsAndMonths(10); // '0 days'
  /// convertDaysToYearsAndMonths(10, includeRemainingDays: true); // '10 days'
  /// ```
  static String? convertDaysToYearsAndMonths(
    int? days, {
    bool includeRemainingDays = false,
  }) {
    if (days == null || days < 1) {
      return null;
    }

    // Calculate years using average days per year (365.25 to account for leap years)
    final int years = (days / _avgDaysPerYear).floor();
    double remainingDays = days - (years * _avgDaysPerYear);

    // Calculate months from remaining days using average days per month
    final int months = (remainingDays / _avgDaysPerMonth).floor();
    remainingDays = remainingDays - (months * _avgDaysPerMonth);

    // Round remaining days
    final int remainingDaysInt = remainingDays.round();

    // Determine whether to use singular or plural forms
    final String yearStr = (years == 1) ? 'year' : 'years';
    final String monthStr = (months == 1) ? 'month' : 'months';
    final String dayStr = (remainingDaysInt == 1) ? 'day' : 'days';

    // Build result parts
    final List<String> parts = <String>[];

    if (years > 0) {
      parts.add('$years $yearStr');
    }

    if (months > 0) {
      parts.add('$months $monthStr');
    }

    if (includeRemainingDays && remainingDaysInt > 0) {
      parts.add('$remainingDaysInt $dayStr');
    }

    // Handle case where we have no years or months
    if (parts.isEmpty) {
      if (includeRemainingDays && remainingDaysInt > 0) {
        return '$remainingDaysInt $dayStr';
      }
      return '0 days';
    }

    // Join parts with 'and' for readability
    if (parts.length == 1) {
      return parts[0];
    } else if (parts.length == 2) {
      return '${parts[0]} and ${parts[1]}';
    } else {
      // For 3 parts: "X years, Y months, and Z days"
      return '${parts[0]}, ${parts[1]}, and ${parts[2]}';
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
  static DateTime? firstDayNextMonth({required int month, required int year}) {
    // ref: https://stackoverflow.com/questions/61881850/sort-list-based-on-boolean
    // ref: https://stackoverflow.com/questions/67144785/flutter-dart-datetime-max-min-value
    if (month < minMonth || month > maxMonth) {
      // invalid
      return null;
    }

    // there are ALWAYS 28 days in any month
    final DateTime someDayNextMonth = DateTime(year, month, minDaysInAnyMonth).addDays(daysToAddToGetNextMonth);

    return DateTime(someDayNextMonth.year, someDayNextMonth.month);
  }

  /// Returns the later of two dates.
  ///
  /// If [date2] is null, [date1] is returned.
  static DateTime maxDate(DateTime date1, DateTime? date2) {
    if (date2 == null) {
      return date1;
    }

    return date1.compareTo(date2) >= 0 ? date1 : date2;
  }

  /// Returns the earlier of two dates.
  ///
  /// If [date2] is null, [date1] is returned.
  static DateTime minDate(DateTime date1, DateTime? date2) {
    if (date2 == null) {
      return date1;
    }

    return date1.compareTo(date2) <= 0 ? date1 : date2;
  }

  /// Checks if the given year is a leap year.
  ///
  /// Returns true if the year is a leap year, false otherwise.
  static bool isLeapYear({required int year}) =>
      // A year is a leap year if it is divisible by 4
      year % leapYearModulo4 == 0
      // A year is not a leap year if it is divisible by 100
      &&
      (year % leapYearModulo100 != 0
          // unless it is also divisible by 400
          ||
          year % leapYearModulo400 == 0);

  /// Returns the number of days in the given month and year.
  ///
  /// Takes into account leap years for February.
  static int monthDayCount({required int year, required int month}) {
    if (month < minMonth || month > maxMonth) {
      throw ArgumentError('Month must be between 1 and 12');
    }

    const List<int> daysInMonth = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (month == 2 && isLeapYear(year: year)) {
      return daysInFebLeapYear;
    }

    return daysInMonth[month - 1];
  }

  /// Validates date and time components.
  ///
  /// Returns true if all provided components are within valid ranges:
  /// - year: 0-9999
  /// - month: 1-12
  /// - day: 1 to max days in month (requires month to be set)
  /// - hour: 0-23
  /// - minute: 0-59
  /// - second: 0-59
  /// - millisecond: 0-999
  /// - microsecond: 0-999
  ///
  /// Components that are null are not validated.
  static bool isValidDateParts({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    if (year != null && (year < 0 || year > maxYear)) return false;
    if (month != null && (month < minMonth || month > maxMonth)) return false;
    if (day != null) {
      if (month == null) return false;
      final int maxDay = monthDayCount(year: year ?? defaultLeapYearCheckYear, month: month);
      if (day < 1 || day > maxDay) return false;
    }
    if (hour != null && (hour < 0 || hour > maxHour)) return false;
    if (minute != null && (minute < 0 || minute > maxMinuteOrSecond)) return false;
    if (second != null && (second < 0 || second > maxMinuteOrSecond)) return false;
    if (millisecond != null && (millisecond < 0 || millisecond > maxMillisecondOrMicrosecond)) return false;
    if (microsecond != null && (microsecond < 0 || microsecond > maxMillisecondOrMicrosecond)) return false;
    return true;
  }
}
