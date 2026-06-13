import 'package:meta/meta.dart';

/// Start of the special last-two-digits range (11-13) whose ordinal suffix is
/// always 'th' — covers 11/12/13 and any number ending in them (111, 1012, 213).
const int _teenRangeStart = 11;

/// End of that range: 13. (11th, 12th, 13th, 111th, 213th … are all 'th'.)
const int _teenRangeEnd = 13;

/// Base 10 modulo for determining the ones place digit.
const int _base10 = 10;

/// Base 100 modulo for the last-two-digits 'th' test.
const int _base100 = 100;

/// Ones digit for the 'rd' ordinal suffix (3rd, 23rd, etc.).
const int _ordinalRdDigit = 3;

/// `IntStringExtensions` is an extension on the `int` class in Dart. It
///  provides additional methods for performing operations on integers.
///
/// The `ordinal` method in this extension returns an ordinal number of
///  `String` type for any integer.
///
/// It handles both positive and negative integers, as well as zero.
///
/// Example usage:
/// ```dart
/// int number = 101;
/// String ordinalNumber = number.ordinal();  // returns '101st'
/// ```
///
/// Note: All methods in this extension are null-safe, meaning they will not
///  throw an exception if the integer on which they are called is null.
///
extension IntStringExtensions on int {
  /// Returns an ordinal number of `String` type for any integer
  ///
  /// ```dart
  /// 101.ordinal(); // 101st
  /// 114.ordinal(); // 114th
  ///
  /// 999218.ordinal(); // 999218th
  /// ```
  ///
  /// A `double` typed version can use: value.floor()
  ///
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String ordinal() {
    // 11th/12th/13th are 'th' — and so is ANY number ending in 11/12/13 (111th,
    // 1012th, 213th). Test the last TWO digits, not an absolute 11..19 window:
    // the old window left 111 → '111st'. Use abs() so a negative picks its suffix
    // from the magnitude ((-21) → '-21st', not the '-21th' that `-21 % 10` gave).
    final int magnitude = abs();
    final int lastTwo = magnitude % _base100;
    if (lastTwo >= _teenRangeStart && lastTwo <= _teenRangeEnd) {
      return '${this}th';
    }

    return switch (magnitude % _base10) {
      1 => '${this}st',
      2 => '${this}nd',
      _ordinalRdDigit => '${this}rd',
      _ => '${this}th',
    };
  }
}
