import 'package:flutter/material.dart';

/// Extension methods for [String] to facilitate hexadecimal conversions.
extension HexExtensions on String {
  /// Converts a hexadecimal string to an integer ([int]).
  ///
  /// This method attempts to parse the string as a hexadecimal number.
  /// It performs several checks to ensure the input is a valid hexadecimal string
  /// and that the resulting value can be represented as an [int].
  ///
  /// Returns:
  /// An [int] representation of the hexadecimal string, or `null` if the string is empty,
  /// not a valid hexadecimal string, or represents a value too large for an [int].
  ///
  /// Prints a warning to the debug console if the input is invalid or too large.
  ///
  /// Example:
  /// ```dart
  /// 'FF'.hexToInt(); // Returns 255
  /// '1A3F'.hexToInt(); // Returns 6719
  /// ''.hexToInt(); // Returns null
  /// 'invalid-hex'.hexToInt(); // Returns null, prints a warning
  /// 'FFFFFFFFFFFFFFFF'.hexToInt(); // Returns null, prints a warning (too large)
  /// ```
  int? hexToInt() {
    if (isEmpty) {
      return null;
    }
    // Check if the hexadecimal string is valid using a regular expression.
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(this)) {
      debugPrint('WARNING: Invalid [hexValue]: `$this`');
      return null;
    }
    // Check if the hexadecimal string is too large to be represented as an int.
    if (length > 16 || (length == 16 && compareTo('7FFFFFFFFFFFFFFF') > 0)) {
      debugPrint('WARNING: [hexValue] too large to be represented as an int: `$this`');
      return null;
    }
    // Convert the hexadecimal string to an int and return it.
    return int.parse(this, radix: 16);
  }
}

/// Extension methods for [int] to facilitate hexadecimal conversions.
extension HexIntExtensions on int {
  /// Converts an integer ([int]) value to a hexadecimal string ([String]).
  ///
  /// This method converts the integer to its hexadecimal representation as a string.
  ///
  /// Returns:
  /// A hexadecimal [String] representation of the [int] value.
  ///
  /// Example:
  /// ```dart
  /// 255.intToHex(); // Returns 'ff'
  /// 6719.intToHex(); // Returns '1a3f'
  /// 0.intToHex(); // Returns '0'
  /// ```
  String? intToHex() => toRadixString(16);
}
