import 'package:saropa_dart_utils/datetime/date_constants.dart';

/// `DateConstantExtensions` is an extension on the `DateTime` class in Dart.
///  It provides additional properties for performing operations on `DateTime`
///  instances.
///
/// The `isUnixEpochDate` property checks if the year, month, and day of the
///  `DateTime` instance match those of the Unix epoch date (January 1, 1970).
///
/// The `isUnixEpochDateTime` property checks if the `DateTime` instance is
///  exactly equal to the Unix epoch date and time (00:00:00 UTC, January 1,
///  1970).
///
/// Example usage:
/// ```dart
/// DateTime date = DateTime.utc(1970, 1, 1);
/// bool isEpochDate = date.isUnixEpochDate;  // returns true
/// bool isEpochDateTime = date.isUnixEpochDateTime;  // returns true
/// ```
///
extension DateConstantExtensions on DateTime {
  /// Checks if the year, month, and day of the `DateTime` instance
  /// match those of the Unix epoch date (January 1, 1970).
  ///
  /// Returns `true` if the year, month, and day match the Unix epoch date,
  /// and `false` otherwise.
  ///
  bool get isUnixEpochDate =>
      year == DateConstants.unixEpochDate.year &&
      month == DateConstants.unixEpochDate.month &&
      day == DateConstants.unixEpochDate.day;

  /// Checks if the `DateTime` instance is exactly equal to
  /// the Unix epoch date and time (00:00:00 UTC, January 1, 1970).
  ///
  /// Returns `true` if the `DateTime` instance represents the exact
  /// Unix epoch date and time, and `false` otherwise.
  ///
  bool get isUnixEpochDateTime => this == DateConstants.unixEpochDate;
}
