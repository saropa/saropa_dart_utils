final RegExp _trailingIntRegex = RegExp(r'\d+$');

/// An extension on the String class to extract the trailing integer from a string.
///
/// This extension provides a method to get the trailing integer from a string.
/// If the string is empty or does not contain a trailing integer, it returns null.
extension StringNumberExtensions on String {
  /// Checks if the string can be parsed as a number.
  bool isNumeric() =>
      // Attempt to parse as a double and check if the result is not null.
      double.tryParse(this) != null;

  /// safely get an double from a string
  // https://api.flutter.dev/flutter/dart-core/double/tryParse.html
  double? toDoubleNullable() => isEmpty ? null : double.tryParse(this);

  /// safely get an int from a String
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
  int? getTrailingInt() {
    // Exit early if the string is empty
    if (isEmpty) {
      return null;
    }

    // Regular expression to match trailing digits
    final RegExp regex = _trailingIntRegex;

    final RegExpMatch? match = regex.firstMatch(this);

    // Return the parsed integer if a match is found, otherwise return null
    return match == null ? null : int.tryParse(match.group(0)!);
  }
}
