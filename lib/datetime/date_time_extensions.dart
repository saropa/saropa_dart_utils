import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:saropa_dart_utils/datetime/date_time_utils.dart';
import 'package:saropa_dart_utils/int/int_string_extensions.dart';

/// Extensions on the [DateTime] class to provide additional functionality.
extension DateTimeExtensions on DateTime {
  /// Determines if the date (of birth) is under 13 years old.
  ///
  /// This is useful for determining non-child content access based on
  /// the Children's Online Privacy Protection Act (COPPA).
  ///
  /// [today] can be optionally provided to specify the date to compare against.
  /// If not provided, the current date is used.
  ///
  /// NOTE:  the legal definition of "under 13" can vary slightly by region or
  ///  specific regulation.
  bool isUnder13({
    DateTime? today,
  }) {
    today ??= DateTime.now();

    // NEW: Check if the date of birth is in the future.
    if (isAfter(today)) {
      return false; // Future dates are not considered under 13.
    }

    // Calculate the 13th birthday by adding 13 years to the current date
    final DateTime thirteenthBirthday = addYears(13);

    // Return true if today's date is before the 13th birthday,
    // indicating the age is under 13
    return today.isBefore(thirteenthBirthday);
  }

  /// Generates a list of [DateTime] objects for consecutive days.
  ///
  /// Starts from `this` and generates [days] number of dates.
  List<DateTime> generateDayList(
    int days, {
    bool startOfDay = true,
  }) {
    final List<DateTime> dayList = <DateTime>[];
    DateTime currentDate = this;
    for (int i = 0; i < days; i++) {
      dayList.add(currentDate);
      currentDate = currentDate.nextDay(
        startOfDay: startOfDay,
      );
    }
    return dayList;
  }

  /// Returns the previous day.
  ///
  /// This method calculates the day before the current [DateTime] object.
  /// It handles month and year changes correctly.
  /// [startOfDay] if true, returns the previous day at 00:00:00.
  DateTime prevDay({
    bool startOfDay = true,
  }) {
    DateTime result = add(const Duration(days: -1));
    if (startOfDay) {
      result = DateTime(result.year, result.month, result.day);
    }
    return result;
  }

  /// Returns the next day.
  ///
  /// This method calculates the day after the current [DateTime] object.
  /// It handles month and year changes correctly.
  /// [startOfDay] if true, returns the next day at 00:00:00.
  DateTime nextDay({
    bool startOfDay = true,
  }) {
    DateTime result = add(const Duration(days: 1));
    if (startOfDay) {
      result = DateTime(result.year, result.month, result.day);
    }
    return result;
  }

  /// Checks if the date is in the future compared to the current date and time.
  ///
  /// Args:
  ///   [now] (DateTime?, optional): The current date and time. Defaults to
  ///          null (uses the actual current date and time).
  ///
  /// Returns:
  ///   bool: True if the date is in the future, False otherwise.
  bool isAfterNow([DateTime? now]) {
    now ??= DateTime.now();
    return isAfter(now);
  }

  /// Checks if the date is in the past compared to the current date and time.
  ///
  /// Args:
  ///   [now] (DateTime?, optional): The current date and time. Defaults to
  ///         null (uses the actual current date and time).
  ///
  /// Returns:
  ///   bool: True if the date is in the past, False otherwise.
  bool isBeforeNow([DateTime? now]) {
    now ??= DateTime.now();
    return isBefore(now);
  }

  /// Checks if the current year is a leap year using [DateTimeUtils.isLeapYear]
  ///
  /// Returns:
  ///   bool: True if the year is a leap year, false otherwise.
  bool isLeapYear() {
    return DateTimeUtils.isLeapYear(year: year);
  }

  /// Gets the start date of the year.
  ///
  /// Returns:
  ///   DateTime: The first day of the year.
  ///
  /// Throws:
  ///   ArgumentError: If the year is greater than 9999.
  DateTime get yearStart {
    if (year > 9999) {
      throw ArgumentError('[year] must be <= 9999');
    }

    // January 1st of the year - 1 is the default month and day
    return DateTime(year);
  }

  /// Gets the end date of the year.
  ///
  /// Returns:
  ///   DateTime: The last day of the year.
  ///
  /// Throws:
  ///   ArgumentError: If the year is greater than 9999.
  DateTime get yearEnd {
    if (year > 9999) {
      throw ArgumentError('[year] must be <= 9999');
    }

    return DateTime(year, 12, 31);
  }

  /// Extension method to check if this [DateTime] is before another [DateTime].
  ///
  /// Returns `false` if [other] is `null`, otherwise returns the result of
  /// comparing this [DateTime] with [other] using the `isBefore` method.
  bool isBeforeNullable(DateTime? other) {
    if (other == null) {
      return false;
    }
    return isBefore(other);
  }

  /// Extension method to check if this [DateTime] is after another [DateTime].
  ///
  /// Returns `false` if [other] is `null`, otherwise returns the result of
  /// comparing this [DateTime] with [other] using the `isAfter` method.
  bool isAfterNullable(DateTime? other) {
    if (other == null) {
      return false;
    }
    return isAfter(other);
  }

  /// Checks if the current time is midnight (00:00:00).
  ///
  /// Returns:
  ///   bool: True if the time is midnight, false otherwise.
  bool get isMidnight => hour == 0 && minute == 0 && second == 0;

  /// Ignores the year of the current [DateTime] and returns a new [DateTime]
  /// with the specified [setYear].
  ///
  /// Requires [month] and [day] to be set in the current [DateTime].
  DateTime? toDateInYear(int setYear) {
    return DateTime(setYear, month, day);
  }

  /// Returns the ordinal representation of the day of the month.
  ///
  /// For example, for the 1st day of the month, it returns "1st".
  /// For the 2nd day, it returns "2nd", and so on.
  String? dayOfMonthOrdinal() => day.ordinal();

  /// Calculates the time difference in milliseconds between the current
  /// [DateTime] and another [DateTime].
  ///
  /// Args:
  ///   compareTo (DateTime?): The [DateTime] to compare to.
  ///   alwaysPositive (bool): If true, the result will always be a
  ///   positive value. Defaults to true.
  ///
  /// Returns:
  ///   int?: The time difference in milliseconds, or null if [compareTo]
  ///   is null.
  int? getTimeDifferenceMs(
    DateTime? compareTo, {
    bool alwaysPositive = true,
  }) {
    if (compareTo == null) {
      return null;
    }

    final int inMilliseconds = difference(compareTo).inMilliseconds;

    return alwaysPositive ? inMilliseconds.abs() : inMilliseconds;
  }

  /// Adds the specified number of years to the current [DateTime].
  ///
  /// Note: When adding a year to February 29th, it returns February 28th
  ///  (not March 1st)
  ///
  /// Args:
  ///   years (int): The number of years to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added years.
  DateTime addYears(int years) {
    if (years == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).add(years: years).dateTime;
  }

  /// Adds the specified number of months to the current [DateTime].
  ///
  /// Args:
  ///   months (int): The number of months to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added months.
  DateTime addMonths(int months) {
    if (months == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).add(months: months).dateTime;
  }

  /// Adds the specified number of days to the current [DateTime].
  ///
  /// Args:
  ///   days (int): The number of days to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added days.
  DateTime addDays(int days) {
    if (days == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).add(days: days).dateTime;
  }

  /// Adds the specified number of hours to the current [DateTime].
  ///
  /// Args:
  ///   hours (int): The number of hours to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added hours.
  DateTime addHours(int hours) {
    if (hours == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).add(hours: hours).dateTime;
  }

  /// Adds the specified number of minutes to the current [DateTime].
  ///
  /// Args:
  ///   minutes (int): The number of minutes to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added minutes.
  DateTime addMinutes(int minutes) {
    if (minutes == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).add(minutes: minutes).dateTime;
  }

  /// Subtracts the specified number of minutes from the current [DateTime].
  ///
  /// Args:
  ///   minutes (int): The number of minutes to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted minutes.
  DateTime subtractMinutes(int minutes) {
    if (minutes == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).subtract(minutes: minutes).dateTime;
  }

  /// Subtracts the specified number of hours from the current [DateTime].
  ///
  /// Args:
  ///   hours (int): The number of hours to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted hours.
  DateTime subtractHours(int hours) {
    if (hours == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).subtract(hours: hours).dateTime;
  }

  /// Subtracts the specified number of months from the current [DateTime].
  ///
  /// Args:
  ///   months (int): The number of months to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted months.
  DateTime subtractMonths(int months) {
    if (months == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).subtract(months: months).dateTime;
  }

  /// Subtracts the specified number of years from the current [DateTime].
  ///
  /// NOTE: you WILL lose Feb 29th when adding and subtracting 1 year
  ///
  /// Args:
  ///   years (int): The number of years to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted years.
  ///
  DateTime subtractYears(int years) {
    if (years == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).subtract(years: years).dateTime;
  }

  /// Subtracts the specified number of days from the current [DateTime].
  ///
  /// Args:
  ///   days (int?): The number of days to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted days.
  DateTime subtractDays(int? days) {
    if (days == null || days == 0) {
      // same
      return this;
    }

    // We used the Jiffy package to add years, months, etc
    // https://stackoverflow.com/questions/54792056/add-subtract-months-years-to-date-in-dart
    return Jiffy.parseFromDateTime(this).subtract(days: days).dateTime;
  }

  /// Checks if the date is in the current calendar year.
  ///
  /// Returns:
  ///   bool: True if the date is in the current year, false otherwise.
  bool get isYearCurrent {
    // https://stackoverflow.com/questions/56427418/how-to-extract-only-the-time-from-datetime-now
    return year == DateTime.now().year;
  }

  /// Returns true if this date is the same as or after [other] date.
  ///
  /// This method compares the year, month, and day of the current [DateTime]
  /// with another [DateTime] object.
  bool isSameDateOrAfter(DateTime other) {
    // Check if the year of this date is greater than the year of the other
    // date
    if (year > other.year) {
      return true;
    }

    // If the years are equal, check if the month of this date is greater
    // than the month of the other date
    if (year == other.year && month > other.month) {
      return true;
    }

    // If the years and months are equal, check if the day of this date is
    // greater than or equal to the day of the other date
    if (year == other.year && month == other.month && day >= other.day) {
      return true;
    }

    // If none of the above conditions are met, return false
    return false;
  }

  /// Returns true if this date is the same as or before [other] date.
  ///
  /// This method compares the year, month, and day of the current [DateTime]
  /// with another [DateTime] object.
  bool isSameDateOrBefore(DateTime other) {
    // Check if the year of this date is less than the year of the other date
    if (year < other.year) {
      return true;
    }

    // If the years are equal, check if the month of this date is less than
    // the month of the other date
    if (year == other.year && month < other.month) {
      return true;
    }

    // If the years and months are equal, check if the day of this date is
    // less than or equal to the day of the other date
    if (year == other.year && month == other.month && day <= other.day) {
      return true;
    }

    // If none of the above conditions are met, return false
    return false;
  }

  /// Removes the time component from the [DateTime] object, returning only
  /// the date part (year, month, and day).
  DateTime toDateOnly() => DateTime(
        year,
        month,
        day,
      );

  /// Converts the current [DateTime] to UTC and adds the specified offset.
  ///
  /// Args:
  ///   offset (double): The offset to add, in hours.
  ///
  /// Returns:
  ///   DateTime?: A new [DateTime] object with the added offset, or null if
  ///   the offset is 0.
  DateTime? getUtcTimeFromLocal(double offset) {
    if (offset == 0) {
      return this;
    }

    final int hours = offset.floor();
    final int minutes = ((offset - hours) * 60).round();

    return toUtc().add(Duration(hours: hours, minutes: minutes));
  }

  /// Checks if the current [DateTime] is within the specified range.
  ///
  /// Args:
  ///   range (DateTimeRange?): The range to check against.
  ///   inclusive (bool): If true, the start and end dates of the range are
  ///   included in the check. Defaults to true.
  ///
  /// Returns:
  ///   bool: True if the [DateTime] is within the range, false otherwise.
  bool isBetweenRange(
    DateTimeRange? range, {
    bool inclusive = true,
  }) {
    if (range == null) {
      return false;
    }

    return isBetween(range.start, range.end);
  }

  /// Checks if the current [DateTime] is between the specified start and
  /// end dates.
  ///
  /// Args:
  ///   start (DateTime): The start date of the range.
  ///   end (DateTime): The end date of the range.
  ///   inclusive (bool): If true, the start and end dates are included in
  ///   the check. Defaults to true.
  ///
  /// Returns:
  ///   bool: True if the [DateTime] is between the start and end dates,
  ///   false otherwise.
  bool isBetween(
    DateTime start,
    DateTime end, {
    bool inclusive = true,
  }) {
    if (inclusive) {
      return (this == start || isAfter(start)) &&
          (this == end || isBefore(end));
    }

    return isAfter(start) && isBefore(end);
  }

  /// Checks if a given date is after today.
  ///
  /// This method takes a [DateTime] object as an argument and returns `true` if
  /// the date is after today, and `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// DateTime dateToCheck = ... // the date you want to check
  /// if (isDateAfterToday(dateToCheck)) {
  ///   // dateToCheck is after today
  /// }
  /// ```
  bool isDateAfterToday(
    DateTime dateToCheck,
  ) {
    // Get the current date and time
    final DateTime now = DateTime.now();

    // Create a new DateTime object representing today at midnight
    final DateTime endOfToday = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1)); // Just before midnight

    // Check if the given date is after today and return the result
    return dateToCheck.isAfter(endOfToday);
  }

  /// Checks if the current [DateTime] matches the current date (today).
  ///
  /// Args:
  ///   now (DateTime?): The current date and time. Defaults to null (uses
  ///   the actual current date and time).
  ///   ignoreYear (bool): If true, the year is ignored in the comparison.
  ///   Defaults to false.
  ///
  /// Returns:
  ///   bool: True if the [DateTime] matches the current date, false otherwise.
  bool isToday({
    DateTime? now,
    bool ignoreYear = false,
  }) {
    now ??= DateTime.now();

    // https://stackoverflow.com/questions/54391477/check-if-datetime-variable-is-today-tomorrow-or-yesterday
    return now.day == day &&
        now.month == month &&
        (ignoreYear || now.year == year);
  }

  /// Checks if the current [DateTime] has the same date (year, month, day)
  /// as another [DateTime].
  ///
  /// Args:
  ///   other (DateTime): The other [DateTime] to compare with.
  ///
  /// Returns:
  ///   bool: True if the dates are the same, false otherwise.
  bool isSameDateOnly(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Checks if the current [DateTime] has the same day and month as another
  /// [DateTime].
  ///
  /// Args:
  ///   other (DateTime): The other [DateTime] to compare with.
  ///
  /// Returns:
  ///   bool: True if the day and month are the same, false otherwise.
  bool isSameDayMonth(DateTime other) {
    return month == other.month && day == other.day;
  }

  /// Checks if the current [DateTime] has the same month as another [DateTime].
  ///
  /// Args:
  ///   other (DateTime): The other [DateTime] to compare with.
  ///
  /// Returns:
  ///   bool: True if the month is the same, false otherwise.
  bool isSameMonth(DateTime other) {
    return month == other.month;
  }

  /// Sets the time of the current [DateTime] to the specified [TimeOfDay].
  ///
  /// Args:
  ///   time (TimeOfDay): The time to set.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the updated time.
  DateTime setTime({
    required TimeOfDay time,
  }) {
    return DateTime(
      year,
      month,
      day,
      time.hour,
      time.minute,
    );
  }

  /// Aligns the current [DateTime] to the specified duration.
  ///
  /// Args:
  ///   alignment (Duration): The duration to align to.
  ///   roundUp (bool): If true, the [DateTime] is rounded up to the next
  ///   alignment. Defaults to false.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object aligned to the specified duration.
  DateTime alignDateTime({
    required Duration alignment,
    bool roundUp = false,
  }) {
    // ref: https://stackoverflow.com/questions/60880315/how-to-round-up-the-date-time-nearest-to-30-min-interval-in-dart-flutter
    if (alignment == Duration.zero) {
      return this;
    }

    final Duration correction = Duration(
      //days: 0,
      hours: alignment.inDays > 0
          ? hour
          : alignment.inHours > 0
              ? hour % alignment.inHours
              : 0,
      minutes: alignment.inHours > 0
          ? minute
          : alignment.inMinutes > 0
              ? minute % alignment.inMinutes
              : 0,
      seconds: alignment.inMinutes > 0
          ? second
          : alignment.inSeconds > 0
              ? second % alignment.inSeconds
              : 0,
      milliseconds: alignment.inSeconds > 0
          ? millisecond
          : alignment.inMilliseconds > 0
              ? millisecond % alignment.inMilliseconds
              : 0,
      microseconds: alignment.inMilliseconds > 0 ? microsecond : 0,
    );

    if (correction == Duration.zero) {
      return this;
    }

    final DateTime corrected = subtract(correction);

    return roundUp ? corrected.add(alignment) : corrected;
  }

  /// Calculates the age based on the current date.
  ///
  /// Args:
  ///   now (DateTime?): The current date and time. Defaults to null (uses
  ///   the actual current date and time).
  ///
  /// Returns:
  ///   int: The calculated age.
  int calculateAgeFromNow({
    DateTime? now,
  }) {
    now ??= DateTime.now();

    return calculateAgeFromDate(now);
  }

  /// Calculates the age based on a given date.
  ///
  /// Args:
  ///   fromDate (DateTime): The date to calculate the age from.
  ///
  /// Returns:
  ///   int: The calculated age.
  int calculateAgeFromDate(DateTime fromDate) {
    // final int age = fromDate.year - year;
    // final int month1 = fromDate.month;
    // final int month2 = month;

    // if (month2 > month1) {
    //   return age - 1;
    // }

    // if (month1 == month2) {
    //   final int day1 = fromDate.day;
    //   final int day2 = day;

    //   if (day2 > day1) {
    //     return age - 1;
    //   }
    // }

    int age = fromDate.year - year;

    // Adjust age if the birthday hasn't occurred yet this year
    if (month > fromDate.month ||
        (month == fromDate.month && day > fromDate.day)) {
      age--;
    }

    return age;
  }
}
