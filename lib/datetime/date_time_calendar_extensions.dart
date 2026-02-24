import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';

/// Extensions on [DateTime] for age, calendar, formatting, and time alignment.
extension DateTimeCalendarExtensions on DateTime {
  /// Calculates the age based on the current date.
  ///
  /// Args:
  ///   now (DateTime?): The current date and time. Defaults to null (uses
  ///   the actual current date and time).
  ///
  /// Returns:
  ///   int: The calculated age.
  @useResult
  int calculateAgeFromNow({DateTime? now}) =>
      calculateAgeFromDate(now ?? DateTime.now());

  /// Calculates the age based on a given date.
  ///
  /// Args:
  ///   fromDate (DateTime): The date to calculate the age from.
  ///
  /// Returns:
  ///   int: The calculated age.
  @useResult
  int calculateAgeFromDate(DateTime fromDate) {
    int age = fromDate.year - year;

    // Adjust age if the birthday hasn't occurred yet this year
    if (month > fromDate.month || (month == fromDate.month && day > fromDate.day)) {
      age--;
    }

    return age;
  }

  /// Returns the most recent Sunday before or on this date.
  @useResult
  DateTime get mostRecentSunday => mostRecentWeekday(DateTime.sunday);

  /// Returns the most recent occurrence of the specified weekday.
  ///
  /// **Args:**
  /// - [weekdayTarget]: The target weekday (1 = Monday, 7 = Sunday).
  ///
  /// **Returns:**
  /// The most recent date that falls on the target weekday.
  @useResult
  DateTime mostRecentWeekday(int weekdayTarget) =>
      DateTime(year, month, day - (weekday - weekdayTarget) % DateConstants.daysPerWeek);

  /// Returns the day of the year (1-366).
  @useResult
  int get dayOfYear {
    final DateTime jan1 = DateTime(year);

    return difference(jan1).inDays + 1;
  }

  /// Returns a raw week-of-year value used internally.
  ///
  /// **Warning:** this value can be 0 for dates in early January that belong
  /// to the last ISO week of the previous year, or 53 for dates in late
  /// December that belong to week 1 of the next year. Use `weekNumber` for
  /// fully ISO 8601-compliant results.
  @useResult
  int get weekOfYear =>
      ((dayOfYear - weekday + DateConstants.isoWeekOffset) / DateConstants.daysPerWeek).floor();

  /// Returns the number of ISO weeks in the specified year.
  @useResult
  int numOfWeeks(int targetYear) {
    final DateTime dec28 = DateTime(
      targetYear,
      DateTime.december,
      DateConstants.isoWeekReferenceDay,
    );
    final DateTime jan1 = DateTime(targetYear);
    final int dayOfDec28 = dec28.difference(jan1).inDays + 1;

    return ((dayOfDec28 - dec28.weekday + DateConstants.isoWeekOffset) / DateConstants.daysPerWeek)
        .floor();
  }

  /// Returns the ISO 8601 week number, correctly handling year boundaries.
  ///
  /// Dates in early January that belong to the last week of the previous year
  /// return that year's final week number. Dates in late December that belong
  /// to week 1 of the next year return 1.
  ///
  /// Prefer this over `weekOfYear` for any user-facing or standards-compliant
  /// week calculations.
  @useResult
  int weekNumber() {
    if (weekOfYear < 1) {
      return numOfWeeks(year - 1);
    }

    if (weekOfYear > numOfWeeks(year)) {
      return 1;
    }

    return weekOfYear;
  }

  /// Converts this DateTime to a serial string format (yyyyMMdd'T'HHmmss).
  @useResult
  String get toSerialString {
    final String yearPad = year.toString().padLeft(DateConstants.yearStringWidth, '0');
    final String monthPad = month.toString().padLeft(2, '0');
    final String dayPad = day.toString().padLeft(2, '0');
    final String hourPad = hour.toString().padLeft(2, '0');
    final String minutePad = minute.toString().padLeft(2, '0');
    final String secondPad = second.toString().padLeft(2, '0');

    return '$yearPad$monthPad${dayPad}T$hourPad$minutePad$secondPad';
  }

  /// Converts this DateTime to a serial day string format (yyyyMMdd).
  @useResult
  String get toSerialStringDay {
    final String yearPad = year.toString().padLeft(DateConstants.yearStringWidth, '0');
    final String monthPad = month.toString().padLeft(2, '0');
    final String dayPad = day.toString().padLeft(2, '0');

    return '$yearPad$monthPad$dayPad';
  }

  /// Converts this local [DateTime] to UTC using the given timezone [offset].
  ///
  /// [offset] is the hours-ahead-of-UTC value for this DateTime's timezone.
  /// Positive for timezones east of UTC (e.g., `2.0` for UTC+2),
  /// negative for timezones west of UTC (e.g., `-5.0` for UTC-5).
  /// Fractional values represent partial hours (e.g., `5.5` for UTC+5:30).
  ///
  /// Always returns a non-null [DateTime]. Returns the original instance if
  /// [offset] is 0.
  @useResult
  DateTime getUtcTimeFromLocal(double offset) {
    if (offset == 0) {
      return this;
    }

    final int hours = offset.truncate();
    final int minutes = ((offset - hours) * DateConstants.minutesPerHour).round();

    return subtract(Duration(hours: hours, minutes: minutes));
  }

  /// Sets the time of the current [DateTime] to the specified [TimeOfDay].
  ///
  /// Returns a new [DateTime] with the same date but the given [time].
  @useResult
  DateTime setTime({required TimeOfDay time}) => DateTime(year, month, day, time.hour, time.minute);

  /// Returns a new [DateTime] aligned to the specified [alignment] duration.
  ///
  /// If [shouldRoundUp] is `true`, the result is rounded up to the next
  /// alignment boundary. Defaults to rounding down.
  @useResult
  DateTime alignDateTime({
    required Duration alignment,
    bool shouldRoundUp = false,
  }) {
    if (alignment == Duration.zero) {
      return this;
    }

    final int hours;
    if (alignment.inDays > 0) {
      hours = hour;
    } else {
      hours = alignment.inHours > 0 ? hour % alignment.inHours : 0;
    }

    int minutes;
    if (alignment.inHours > 0) {
      minutes = minute;
    } else {
      minutes = alignment.inMinutes > 0 ? minute % alignment.inMinutes : 0;
    }

    int seconds;
    if (alignment.inMinutes > 0) {
      seconds = second;
    } else {
      seconds = alignment.inSeconds > 0 ? second % alignment.inSeconds : 0;
    }

    int milliseconds;
    if (alignment.inSeconds > 0) {
      milliseconds = millisecond;
    } else {
      milliseconds = alignment.inMilliseconds > 0 ? millisecond % alignment.inMilliseconds : 0;
    }

    final int microseconds = alignment.inMilliseconds > 0 ? microsecond : 0;

    final Duration correction = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
      microseconds: microseconds,
    );

    if (correction == Duration.zero) {
      return this;
    }

    final DateTime corrected = subtract(correction);

    return shouldRoundUp ? corrected.add(alignment) : corrected;
  }
}
