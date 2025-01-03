import 'package:flutter/material.dart';

/// Extension on DateTimeRange to provide additional functionality
extension DateTimeCheck on DateTimeRange {
  /// Checks if a given date is within the range
  ///
  /// [date] The date to check
  /// Returns true if the date is within the range, false otherwise
  bool inRange(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }

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
