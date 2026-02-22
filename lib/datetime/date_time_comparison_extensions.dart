import 'package:flutter/material.dart';

/// Extensions on [DateTime] for comparison, range, and equality checks.
extension DateTimeComparisonExtensions on DateTime {
  /// Checks if the date is in the future compared to the current date and time.
  bool isAfterNow([DateTime? now]) {
    now ??= DateTime.now();
    return isAfter(now);
  }

  /// Checks if the date is in the past compared to the current date and time.
  bool isBeforeNow([DateTime? now]) {
    now ??= DateTime.now();
    return isBefore(now);
  }

  /// Returns `false` if [other] is `null`, otherwise returns the result of
  /// comparing this [DateTime] with [other] using the `isBefore` method.
  bool isBeforeNullable(DateTime? other) {
    if (other == null) {
      return false;
    }
    return isBefore(other);
  }

  /// Returns `false` if [other] is `null`, otherwise returns the result of
  /// comparing this [DateTime] with [other] using the `isAfter` method.
  bool isAfterNullable(DateTime? other) {
    if (other == null) {
      return false;
    }
    return isAfter(other);
  }

  /// Checks if the date is in the current calendar year.
  ///
  /// Pass [now] to override the current time (useful for testing).
  bool isYearCurrent({DateTime? now}) => year == (now ?? DateTime.now()).year;

  /// Returns true if this date (date-only) is the same as or after [other].
  ///
  /// Compares only year/month/day — time components are ignored.
  bool isSameDateOrAfter(DateTime other) {
    final DateTime selfDate = toDateOnly();
    final DateTime otherDate = other.toDateOnly();
    return !selfDate.isBefore(otherDate);
  }

  /// Returns true if this date (date-only) is the same as or before [other].
  ///
  /// Compares only year/month/day — time components are ignored.
  bool isSameDateOrBefore(DateTime other) {
    final DateTime selfDate = toDateOnly();
    final DateTime otherDate = other.toDateOnly();
    return !selfDate.isAfter(otherDate);
  }

  /// Removes the time component from the [DateTime] object, returning only
  /// the date part (year, month, and day).
  DateTime toDateOnly() => DateTime(year, month, day);

  /// Returns `true` if this [DateTime] is within the specified [range].
  ///
  /// When `year` is 0, this method checks if the month/day combination falls
  /// within the range for ANY year covered by the range. This correctly handles
  /// ranges that span year boundaries (e.g., Dec 2023 to Feb 2024).
  ///
  /// If [inclusive] is `true` (default), the start and end dates of the range
  /// are included in the check. Returns `true` if [range] is `null`.
  bool isAnnualDateInRange(DateTimeRange? range, {bool inclusive = true}) {
    if (range == null) {
      return true;
    }

    if (year == 0) {
      for (int checkYear = range.start.year;
          checkYear <= range.end.year;
          checkYear++) {
        final DateTime dateInYear = DateTime(checkYear, month, day);

        if (dateInYear.isBetween(
          range.start,
          range.end,
          inclusive: inclusive,
        )) {
          return true;
        }
      }

      return false;
    }

    return isBetweenRange(range, inclusive: inclusive);
  }

  /// Returns `true` if this [DateTime] is within the specified [range],
  /// `false` if [range] is `null`.
  ///
  /// If [inclusive] is `true` (default), the start and end dates of the range
  /// are included in the check (closed interval). If `false`, only dates
  /// strictly between start and end are considered in range (open interval).
  bool isBetweenRange(DateTimeRange? range, {bool inclusive = true}) {
    if (range == null) {
      return false;
    }

    return isBetween(range.start, range.end, inclusive: inclusive);
  }

  /// Returns `true` if this [DateTime] is between [start] and [end].
  ///
  /// If [inclusive] is `true` (default), [start] and [end] are included
  /// in the check. If `false`, only dates strictly between them match.
  bool isBetween(DateTime start, DateTime end, {bool inclusive = true}) {
    if (inclusive) {
      return (isAfter(start) || isAtSameMomentAs(start)) &&
          (isBefore(end) || isAtSameMomentAs(end));
    }

    return isAfter(start) && isBefore(end);
  }

  /// Returns true if this date is strictly after today (i.e., tomorrow or
  /// later).
  ///
  /// Pass [now] to override the current time (useful for testing).
  bool isDateAfterToday({DateTime? now}) {
    final DateTime currentNow = now ?? DateTime.now();

    final DateTime endOfToday = DateTime(
      currentNow.year,
      currentNow.month,
      currentNow.day,
    ).add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    return isAfter(endOfToday);
  }

  /// Returns `true` if this [DateTime] matches the current date (today).
  ///
  /// Pass [now] to override the current time (useful for testing). If
  /// [ignoreYear] is `true`, the year is excluded from the comparison.
  bool isToday({DateTime? now, bool ignoreYear = false}) {
    now ??= DateTime.now();

    return now.day == day &&
        now.month == month &&
        (ignoreYear || now.year == year);
  }

  /// Checks if the current [DateTime] has the same date (year, month, day)
  /// as another [DateTime].
  bool isSameDateOnly(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Checks if the current [DateTime] has the same day and month as another
  /// [DateTime].
  bool isSameDayMonth(DateTime other) =>
      month == other.month && day == other.day;

  /// Checks if the current [DateTime] has the same month as another
  /// [DateTime].
  bool isSameMonth(DateTime other) => month == other.month;
}
