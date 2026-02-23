import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

/// One day duration used for month-end calculations.
const Duration _oneDay = Duration(days: 1);

/// Extension on [DateTimeRange] to provide additional functionality
extension DateTimeRangeExtensions on DateTimeRange {
  /// Returns `true` if the [n]th occurrence of [dayOfWeek] in the given
  /// [month] falls within this date range.
  ///
  /// This method correctly handles ranges that span year boundaries. For example,
  /// a range from Nov 2023 to Feb 2024 will correctly check for occurrences in
  /// January 2024.
  ///
  /// If [isInclusive] is `true` (default), dates at the start/end boundaries
  /// are considered in range. If `false`, only dates strictly between start
  /// and end are considered.
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
  @useResult
  bool isNthDayOfMonthInRange(int n, int dayOfWeek, int month, {bool isInclusive = true}) {
    // Validate month parameter
    if (month < DateConstants.minMonth || month > DateConstants.maxMonth) {
      return false;
    }

    // Iterate through each year within the range.
    // We no longer do an early-exit check on months because that fails
    // for ranges spanning year boundaries (e.g., Nov 2023 to Feb 2024).
    for (int year = start.year; year <= end.year; year++) {
      final DateTime monthStart = DateTime(year, month);
      final DateTime monthEnd = DateTime(year, month + 1).subtract(_oneDay);

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
      if (nthOccurrence.isBetween(start, end, isInclusive: isInclusive)) {
        return true;
      }
    }

    // If we couldn't find the nth occurrence in any year within the range,
    // return false
    return false;
  }

  /// Returns `true` if the given [date] is within this range.
  ///
  /// By default, this check is [isInclusive], meaning dates exactly equal to the
  /// range's start or end are considered within the range.
  ///
  /// Example:
  /// ```dart
  /// final range = DateTimeRange(
  ///   start: DateTime(2024, 1, 1),
  ///   end: DateTime(2024, 12, 31),
  /// );
  /// range.inRange(DateTime(2024, 6, 15)); // true
  /// range.inRange(DateTime(2024, 1, 1)); // true (inclusive by default)
  /// range.inRange(DateTime(2024, 1, 1), isInclusive: false); // false
  /// ```
  @useResult
  bool inRange(DateTime date, {bool isInclusive = true}) =>
      date.isBetween(start, end, isInclusive: isInclusive);

  /// Returns `true` if [now] is within this range.
  ///
  /// By default, this check is [isInclusive], meaning if [now] equals the start
  /// or end of the range, it is considered within the range.
  ///
  /// NOTE: You can't really make date optional, even if looking for now,
  /// because of microsecond precision. So just cache DateTime.now()
  /// and pass it in for consistent results.
  @useResult
  bool isNowInRange({DateTime? now, bool isInclusive = true}) {
    now ??= DateTime.now();

    return inRange(now, isInclusive: isInclusive);
  }
}
