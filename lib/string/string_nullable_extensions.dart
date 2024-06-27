/// A set of utility methods for working with strings.
extension StringNullableExtensions on String? {
  /// Extension method to check if a [String] is null or empty.
  ///
  /// Returns `true` if the string is either `null` or an empty string (`""`).
  /// Otherwise, returns `false`.
  ///
  /// Example:
  /// ```dart
  /// String? text;
  /// print(text.isNullOrEmpty); // Output: true
  ///
  /// text = "";
  /// print(text.isNullOrEmpty); // Output: true
  ///
  /// text = "Hello";
  /// print(text.isNullOrEmpty); // Output: false
  /// ```
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
