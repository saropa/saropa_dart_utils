/// Radix for hexadecimal number system (base 16).
const int _hexRadix = 16;

/// Maximum length of a hex string for a 64-bit integer (16 hex digits).
const int _maxHexLength = 16;

final RegExp _hexRegex = RegExp(r'^[0-9a-fA-F]+$');

/// Extension methods for [String] to facilitate hexadecimal conversions.
extension HexExtensions on String {
  /// The maximum hex value that can be represented as a signed 64-bit integer.
  /// This is 2^63 - 1 = 9223372036854775807 = 0x7FFFFFFFFFFFFFFF.
  static const String _maxInt64Hex = '7FFFFFFFFFFFFFFF';

  /// Converts a hexadecimal string to an integer ([int]).
  ///
  /// This method attempts to parse the string as a hexadecimal number.
  /// It performs several checks to ensure the input is a valid hexadecimal string
  /// and that the resulting value can be represented as an [int] (signed 64-bit).
  ///
  /// The method correctly handles both uppercase and lowercase hex strings,
  /// normalizing to uppercase for the overflow comparison.
  ///
  /// Returns:
  /// An [int] representation of the hexadecimal string, or `null` if:
  /// - The string is empty
  /// - The string contains non-hexadecimal characters
  /// - The value exceeds the maximum signed 64-bit integer (0x7FFFFFFFFFFFFFFF)
  ///
  /// Prints a warning to the debug console if the input is invalid or too large.
  ///
  /// Example:
  /// ```dart
  /// 'FF'.hexToInt(); // Returns 255
  /// 'ff'.hexToInt(); // Returns 255 (case-insensitive)
  /// '1A3F'.hexToInt(); // Returns 6719
  /// '7fffffffffffffff'.hexToInt(); // Returns 9223372036854775807 (max int64)
  /// ''.hexToInt(); // Returns null
  /// 'invalid-hex'.hexToInt(); // Returns null, prints a warning
  /// '8000000000000000'.hexToInt(); // Returns null, prints a warning (too large)
  /// ```
  int? hexToInt() {
    if (isEmpty) {
      return null;
    }

    // Check if the hexadecimal string is valid using a regular expression.
    if (!_hexRegex.hasMatch(this)) {
      return null;
    }

    // Check if the hexadecimal string is too large to be represented as an int.
    // Normalize to uppercase for consistent comparison since the input can be
    // mixed case (e.g., '7fffffffffffffff' should equal '7FFFFFFFFFFFFFFF').
    final String upperHex = toUpperCase();
    if (length > _maxHexLength || (length == _maxHexLength && upperHex.compareTo(_maxInt64Hex) > 0)) {
      return null;
    }

    // Convert the hexadecimal string to an int and return it.
    return int.tryParse(this, radix: _hexRadix);
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
  String? intToHex() => toRadixString(_hexRadix);
}
