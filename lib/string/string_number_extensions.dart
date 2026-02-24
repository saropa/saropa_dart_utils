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
