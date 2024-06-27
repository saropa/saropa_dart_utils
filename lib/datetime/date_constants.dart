/// `DateConstants` is a utility class in Dart that provides static constants
/// for commonly used dates. This class cannot be instantiated.
///
/// The `unixEpochDate` constant in this class represents the Unix epoch,
/// which is the date and time that Unix systems use as the reference point
/// for measuring time. The Unix epoch is defined as 00:00:00 Coordinated
/// Universal Time (UTC), Thursday, 1 January 1970.
///
/// Example usage:
/// ```dart
/// DateTime epoch = DateConstants.unixEpochDate;
/// ```
///
class DateConstants {
  /// January 1st, 1970 is known as the Unix epoch. It is the date and
  /// time that Unix systems use as the reference point for measuring
  /// time. This date was chosen arbitrarily by early Unix engineers
  /// because they needed a uniform and convenient date for the start
  /// of time.
  ///
  // NOTE: default month and day == 1
  static final DateTime unixEpochDate = DateTime.utc(1970);
}
