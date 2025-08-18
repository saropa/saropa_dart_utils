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

  /// IMPORTANT: do not call ?.isNotNullOrEmpty as it will chain to null not a bool
  /// Return true if the string is null or empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
