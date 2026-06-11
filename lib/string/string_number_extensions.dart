import 'package:meta/meta.dart';

final RegExp _trailingIntRegex = RegExp(r'\d+$');

/// An extension on the String class to extract the trailing integer from a string.
///
/// This extension provides a method to get the trailing integer from a string.
/// If the string is empty or does not contain a trailing integer, it returns null.
extension StringNumberExtensions on String {
  /// Returns `true` if this string can be parsed as a number.
  @useResult
  bool isNumeric() =>
      // Attempt to parse as a double and check if the result is not null.
      double.tryParse(this) != null;

  /// Returns `true` if this string parses as an integer via [int.tryParse].
  ///
  /// Stricter than [isNumeric]: a value with a decimal point (`'4.2'`) or in
  /// scientific notation (`'1e3'`) is `false` here but `true` for [isNumeric],
  /// which parses as a `double`. Use this when only whole-number input is
  /// acceptable (IDs, counts, ports), and [isNumeric] when decimals are valid.
  ///
  /// Delegates entirely to [int.tryParse], so its acceptance rules apply: an
  /// optional leading sign and a `0x`/`0X` hexadecimal prefix are accepted
  /// (`'0x1F'` is `true`), surrounding whitespace is trimmed (`' 42 '` is
  /// `true`), and a magnitude that overflows the platform `int` returns `null`
  /// (`true` on the web's doubles, `false` on the native 64-bit VM). The empty
  /// string is `false`.
  ///
  /// **Example:**
  /// ```dart
  /// '42'.isNumber;    // true
  /// '-7'.isNumber;    // true
  /// '0x1F'.isNumber;  // true  (hexadecimal)
  /// '4.2'.isNumber;   // false (decimal)
  /// '1e3'.isNumber;   // false (scientific notation)
  /// ''.isNumber;      // false
  /// ```
  @useResult
  bool get isNumber => int.tryParse(this) != null;

  /// Returns this string parsed as a `double`, or `null` if parsing fails.
  // https://api.flutter.dev/flutter/dart-core/double/tryParse.html
  @useResult
  double? toDoubleNullable() => isEmpty ? null : double.tryParse(this);

  /// Returns this string parsed as an `int`, or `null` if parsing fails.
  @useResult
  int? toIntNullable() {
    if (isEmpty) {
      return null;
    }

    // https://api.flutter.dev/flutter/dart-core/int/tryParse.html
    return int.tryParse(this);
  }

  /// Gets the trailing integer from the string.
  ///
  /// This method uses a regular expression to find the trailing digits in the string.
  /// If the string is empty or no trailing digits are found, it returns null.
  ///
  /// Example:
  /// ```dart
  /// String example = "FUZZY_NAME_60";
  /// print(example.getTrailingInt()); // Output: 60
  /// ```
  @useResult
  int? getTrailingInt() {
    // Exit early if the string is empty
    if (isEmpty) {
      return null;
    }

    // Regular expression to match trailing digits
    final RegExp regex = _trailingIntRegex;

    final String? matchGroup = regex.firstMatch(this)?.group(0);

    // Return the parsed integer if a match is found, otherwise return null
    return matchGroup == null ? null : int.tryParse(matchGroup);
  }
}
