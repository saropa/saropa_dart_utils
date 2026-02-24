import 'dart:io';

import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

final RegExp _yearRegex = RegExp(r'\b\d{4}\b');

/// A utility class for working with [DateTime] objects.
abstract final class DateTimeUtils {
  // -- Locale constants for month-first date format --

  /// Locale codes that commonly use month-first (MM/DD/YYYY) date format.
  ///
  /// Includes US, Philippines, Canada (English), Filipino, Micronesian,
  /// Guamanian, Marshallese, Palauan, and Belize.
  // cspell: ignore Palauan
  static const Set<String> _monthFirstLocales = <String>{
    'en_US', // US English
    'en_PH', // Philippine English
    'en_CA', // Canadian English
    'fil', // Filipino
    'fsm', // Micronesian - Federated States of Micronesia
    'gu_GU', // Guamanian - Guam
    'mh', // Marshallese - Marshall Islands
    'pw', // Palauan - Palau
    'en_BZ', // Belize
  };

  // -- Duration display labels (English) --

  /// Singular form of 'year' for duration display.
  static const String _yearLabel = 'year';

  /// Plural form of 'year' for duration display.
  static const String _yearsLabel = 'years';

  /// Singular form of 'month' for duration display.
  static const String _monthLabel = 'month';

  /// Plural form of 'month' for duration display.
  static const String _monthsLabel = 'months';

  /// Singular form of 'day' for duration display.
  static const String _dayLabel = 'day';

  /// Plural form of 'day' for duration display.
  static const String _daysLabel = 'days';

  /// Default output when no full years or months are present.
  static const String _zeroDays = '0 days';

  // -- Error messages --

  /// Error message for out-of-range month values.
  static const String _invalidMonthMessage = 'Month must be between 1 and 12';

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
  @useResult
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
  @useResult
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
  /// Pass [now] to override the current date (useful for testing). The
  /// returned date has its time set to [hour], [minute], and [second]
  /// (all defaulting to 0).
  @useResult
  static DateTime tomorrow({DateTime? now, int? hour, int minute = 0, int second = 0}) {
    // Calculate the date for tomorrow at the specified time
    final DateTime resolvedNow = now ?? DateTime.now();
    final DateTime tomorrowAtSpecifiedTime = resolvedNow.addDays(1);

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
  @useResult
  static bool isDeviceDateMonthFirst() => _monthFirstLocales.contains(Platform.localeName);

  /// Average number of days per year, accounting for leap years.
  /// (365 * 3 + 366) / 4 = 365.25
  static const double _avgDaysPerYear = 365.25;

  /// Average number of days per month.
  /// 365.25 / 12 = 30.4375
  static const double _avgDaysPerMonth = 30.4375;

  /// Returns the English singular or plural label for [count].
  ///
  /// English-only by design (no Intl dependency).
  // ignore: require_plural_handling
  static String _pluralLabel({
    required int count,
    required String singular,
    required String plural,
  }) => count == 1 ? singular : plural;

  /// Joins duration parts with 'and' for readability.
  static String _joinWithAnd(List<String> parts) {
    if (parts.length == 1) {
      return parts[0];
    }

    if (parts.length == 2) {
      return '${parts[0]} and ${parts[1]}';
    }

    return '${parts[0]}, ${parts[1]}, and ${parts[2]}';
  }

  /// Returns a human-readable string representing [days] as years, months,
  /// and optionally remaining days, or `null` if [days] is `null` or less
  /// than 1.
  ///
  /// This method uses average values that account for leap years:
  /// - Average days per year: 365.25 (accounts for leap years)
  /// - Average days per month: 30.4375 (365.25 / 12)
  ///
  /// If [includeRemainingDays] is `true`, includes remaining days in the
  /// output when they don't form a complete month.
  ///
  /// **Note:** Output uses English plural rules only.
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
  @useResult
  static String? convertDaysToYearsAndMonths(
    int? days, {
    bool includeRemainingDays = false,
  }) {
    if (days == null || days < 1) {
      return null;
    }

    final int years = (days / _avgDaysPerYear).floor();
    double remainingDays = days - (years * _avgDaysPerYear);
    final int months = (remainingDays / _avgDaysPerMonth).floor();
    remainingDays -= months * _avgDaysPerMonth;
    final int remainingDaysInt = remainingDays.round();

    final List<String> parts = _buildDurationParts(
      years: years,
      months: months,
      remainingDaysInt: remainingDaysInt,
      includeRemainingDays: includeRemainingDays,
    );

    if (parts.isEmpty) {
      if (!includeRemainingDays || remainingDaysInt <= 0) {
        return _zeroDays;
      }

      final String dayStr = _pluralLabel(
        count: remainingDaysInt,
        singular: _dayLabel,
        plural: _daysLabel,
      );

      return '$remainingDaysInt $dayStr';
    }

    return _joinWithAnd(parts);
  }

  /// Builds the list of duration parts (years, months, days).
  static List<String> _buildDurationParts({
    required int years,
    required int months,
    required int remainingDaysInt,
    required bool includeRemainingDays,
  }) {
    final List<String> parts = <String>[];

    if (years > 0) {
      parts.add('$years ${_pluralLabel(count: years, singular: _yearLabel, plural: _yearsLabel)}');
    }

    if (months > 0) {
      parts.add(
        '$months ${_pluralLabel(count: months, singular: _monthLabel, plural: _monthsLabel)}',
      );
    }

    if (includeRemainingDays && remainingDaysInt > 0) {
      parts.add(
        '$remainingDaysInt ${_pluralLabel(count: remainingDaysInt, singular: _dayLabel, plural: _daysLabel)}',
      );
    }

    return parts;
  }

  /// Returns the first day of the month following the given [month] and [year],
  /// or `null` if [month] is invalid.
  @useResult
  static DateTime? firstDayNextMonth({required int month, required int year}) {
    // ref: https://stackoverflow.com/questions/61881850/sort-list-based-on-boolean
    // ref: https://stackoverflow.com/questions/67144785/flutter-dart-datetime-max-min-value
    if (month < DateConstants.minMonth || month > DateConstants.maxMonth) {
      // invalid
      return null;
    }

    // there are ALWAYS 28 days in any month
    final DateTime someDayNextMonth = DateTime(
      year,
      month,
      DateConstants.minDaysInAnyMonth,
    ).addDays(DateConstants.daysToAddToGetNextMonth);

    return DateTime(someDayNextMonth.year, someDayNextMonth.month);
  }

  /// Returns the later of two dates.
  ///
  /// If [date2] is null, [date1] is returned.
  @useResult
  static DateTime maxDate(DateTime date1, DateTime? date2) {
    if (date2 == null) {
      return date1;
    }

    return date1.compareTo(date2) >= 0 ? date1 : date2;
  }

  /// Returns the earlier of two dates.
  ///
  /// If [date2] is null, [date1] is returned.
  @useResult
  static DateTime minDate(DateTime date1, DateTime? date2) {
    if (date2 == null) {
      return date1;
    }

    return date1.compareTo(date2) <= 0 ? date1 : date2;
  }

  /// Checks if the given year is a leap year.
  ///
  /// Returns true if the year is a leap year, false otherwise.
  @useResult
  static bool isLeapYear({required int year}) {
    final bool isDivisibleBy4 = year % DateConstants.leapYearModulo4 == 0;
    final bool isDivisibleBy100 = year % DateConstants.leapYearModulo100 == 0;
    final bool isDivisibleBy400 = year % DateConstants.leapYearModulo400 == 0;

    return isDivisibleBy4 && (!isDivisibleBy100 || isDivisibleBy400);
  }

  /// Returns the number of days in the given [month] and [year].
  ///
  /// Takes into account leap years for February.
  ///
  /// Throws [ArgumentError] if [month] is not between 1 and 12.
  @useResult
  static int monthDayCount({required int year, required int month}) {
    if (month < DateConstants.minMonth || month > DateConstants.maxMonth) {
      throw ArgumentError(_invalidMonthMessage);
    }

    const List<int> daysInMonth = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (month == 2 && isLeapYear(year: year)) {
      return DateConstants.daysInFebLeapYear;
    }

    return daysInMonth[month - 1];
  }

  /// Returns `true` if [value] is `null` or within [min]..[max] inclusive.
  static bool _isInRange({required int? value, required int min, required int max}) {
    if (value == null) {
      return true;
    }

    return value >= min && value <= max;
  }

  /// Returns `true` if all provided date/time components are within valid
  /// ranges.
  ///
  /// Valid ranges for each component:
  /// - [year]: 0-9999
  /// - [month]: 1-12
  /// - [day]: 1 to max days in [month] (requires [month] to be set)
  /// - [hour]: 0-23
  /// - [minute]: 0-59
  /// - [second]: 0-59
  /// - [millisecond]: 0-999
  /// - [microsecond]: 0-999
  ///
  /// Components that are `null` are not validated.
  @useResult
  // All 8 named params are needed to validate each DateTime component
  // ignore: avoid_long_parameter_list
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
    if (!_isInRange(value: year, min: 0, max: DateConstants.maxYear)) {
      return false;
    }

    if (!_isInRange(value: month, min: DateConstants.minMonth, max: DateConstants.maxMonth)) {
      return false;
    }

    if (!_isValidDay(day: day, month: month, year: year)) {
      return false;
    }

    if (!_isInRange(value: hour, min: 0, max: DateConstants.maxHour)) {
      return false;
    }

    if (!_isInRange(value: minute, min: 0, max: DateConstants.maxMinuteOrSecond)) {
      return false;
    }

    if (!_isInRange(value: second, min: 0, max: DateConstants.maxMinuteOrSecond)) {
      return false;
    }

    if (!_isInRange(value: millisecond, min: 0, max: DateConstants.maxMillisecondOrMicrosecond)) {
      return false;
    }

    return _isInRange(value: microsecond, min: 0, max: DateConstants.maxMillisecondOrMicrosecond);
  }

  /// Validates the [day] component given [month] and [year].
  static bool _isValidDay({int? day, int? month, int? year}) {
    if (day == null) {
      return true;
    }

    if (month == null) {
      return false;
    }

    final int maxDay = monthDayCount(
      year: year ?? DateConstants.defaultLeapYearCheckYear,
      month: month,
    );

    return day >= 1 && day <= maxDay;
  }
}
