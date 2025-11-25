import 'package:flutter/material.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

/// Extension on [DateTimeRange] to provide additional functionality
extension DateTimeRangeExtensions on DateTimeRange {
  /// Determines if the nth occurrence of a specific day of the week in a given
  /// month falls within the specified date range.
  ///
  /// This method correctly handles ranges that span year boundaries. For example,
  /// a range from Nov 2023 to Feb 2024 will correctly check for occurrences in
  /// January 2024.
  ///
  /// Args:
  ///   n (int): The occurrence number (1st, 2nd, 3rd, etc.)
  ///   dayOfWeek (int): The day of the week (e.g., DateTime.monday)
  ///   month (int): The month to check (1-12)
  ///   inclusive (bool): If `true` (default), dates at the start/end boundaries
  ///   are considered in range. If `false`, only dates strictly between start
  ///   and end are considered.
  ///
  /// Returns:
  ///   bool: `true` if the nth occurrence of the specified weekday in the given
  ///   month falls within the range, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// // Range: Nov 15, 2023 to Feb 15, 2024
  /// final range = DateTimeRange(
  ///   start: DateTime(2023, 11, 15),
  ///   end: DateTime(2024, 2, 15),
  /// );
  /// // Check if 2nd Monday of January falls in range
  /// range.isNthDayOfMonthInRange(2, DateTime.monday, 1); // true (Jan 2024)
  /// ```
  bool isNthDayOfMonthInRange(int n, int dayOfWeek, int month, {bool inclusive = true}) {
    // Validate month parameter
    if (month < 1 || month > 12) {
      return false;
    }

    // Iterate through each year within the range.
    // We no longer do an early-exit check on months because that fails
    // for ranges spanning year boundaries (e.g., Nov 2023 to Feb 2024).
    for (int year = start.year; year <= end.year; year++) {
      // Optimization: Only proceed if the month is within the range for the
      // current year. This correctly handles year boundaries.
      final DateTime monthStart = DateTime(year, month);
      final DateTime monthEnd = DateTime(year, month + 1).subtract(const Duration(days: 1));

      // Skip this year if the entire month is outside the range
      if (monthEnd.isBefore(start) || monthStart.isAfter(end)) {
        continue;
      }

      // Use getNthWeekdayOfMonthInYear to get the date
      final DateTime? nthOccurrence = DateTime(
        year,
        month,
      ).getNthWeekdayOfMonthInYear(n, dayOfWeek);

      // Ensure the nth occurrence is within the target month
      if (nthOccurrence == null || nthOccurrence.month != month) {
        continue;
      }

      // Check if the nth occurrence is in range using isBetween for consistency
      if (nthOccurrence.isBetween(start, end, inclusive: inclusive)) {
        return true;
      }
    }

    // If we couldn't find the nth occurrence in any year within the range,
    // return false
    return false;
  }

  /// Checks if a given date is within the range.
  ///
  /// By default, this check is inclusive, meaning dates exactly equal to [start]
  /// or [end] are considered within the range. Set [inclusive] to `false` to
  /// exclude boundary dates.
  ///
  /// Args:
  ///   date (DateTime): The date to check.
  ///   inclusive (bool): If `true` (default), dates at the start/end boundaries
  ///   are considered in range. If `false`, only dates strictly between start
  ///   and end are considered.
  ///
  /// Returns:
  ///   bool: `true` if the date is within the range, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final range = DateTimeRange(
  ///   start: DateTime(2024, 1, 1),
  ///   end: DateTime(2024, 12, 31),
  /// );
  /// range.inRange(DateTime(2024, 6, 15)); // true
  /// range.inRange(DateTime(2024, 1, 1)); // true (inclusive by default)
  /// range.inRange(DateTime(2024, 1, 1), inclusive: false); // false
  /// ```
  bool inRange(DateTime date, {bool inclusive = true}) {
    if (inclusive) {
      return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
          (date.isAtSameMomentAs(end) || date.isBefore(end));
    }
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Checks if the current date and time is within the range.
  ///
  /// By default, this check is inclusive, meaning if `now` equals the start
  /// or end of the range, it is considered within the range.
  ///
  /// NOTE: You can't really make date optional, even if looking for now,
  /// because of microsecond precision. So just cache DateTime.now()
  /// and pass it in for consistent results.
  ///
  /// Args:
  ///   now (DateTime?): The date/time to check. Defaults to DateTime.now().
  ///   inclusive (bool): If `true` (default), boundary dates are included.
  ///
  /// Returns:
  ///   bool: `true` if the date/time is within the range, `false` otherwise.
  bool isNowInRange({DateTime? now, bool inclusive = true}) {
    now ??= DateTime.now();

    return inRange(now, inclusive: inclusive);
  }
}
