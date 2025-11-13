import 'package:flutter/material.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

/// Extension on [DateTimeRange] to provide additional functionality
extension DateTimeRangeExtensions on DateTimeRange {
  /// Determines if the nth occurrence of a specific day of the week in a given
  ///  month falls within the specified date range.
  ///
  bool isNthDayOfMonthInRange(int n, int dayOfWeek, int month, {bool inclusive = true}) {
    // Check if the month is even within the range's months
    if (month < start.month || month > end.month) {
      return false;
    }

    // Iterate through each year within the range
    for (int year = start.year; year <= end.year; year++) {
      // Optimization: Only proceed if the month is within the range for the
      // current year
      if ((year == start.year && month < start.month) || (year == end.year && month > end.month)) {
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

      // Check if the nth occurrence is in range
      if (inclusive) {
        if ((nthOccurrence.isAtSameMomentAs(start) || nthOccurrence.isAfter(start)) &&
            (nthOccurrence.isAtSameMomentAs(end) || nthOccurrence.isBefore(end))) {
          return true;
        }
      } else {
        if (nthOccurrence.isAfter(start) && nthOccurrence.isBefore(end)) {
          return true;
        }
      }
    }

    // If we couldn't find the nth occurrence in any year within the range,
    //  return false
    return false;
  }

  /// Checks if a given date is within the range
  ///
  /// [date] The date to check
  /// Returns true if the date is within the range, false otherwise
  bool inRange(DateTime date) => date.isAfter(start) && date.isBefore(end);

  /// Checks if the current date and time is within the range
  ///
  /// NOTE: you can't really make date optional, even if looking for now
  ///       because of microsecond precision. So just cache DateTime.now()
  ///       and pass it in.
  ///
  /// Returns true if the current date and time is within the range
  bool isNowInRange({DateTime? now}) {
    now ??= DateTime.now();

    return inRange(now);
  }
}
