/// Extension methods for nullable [List<T>?].
extension ListExtensionsNullable<T> on List<T>? {
  /// Checks if the nullable list is either `null` or empty.
  ///
  /// This is a null-safe way to determine if a nullable list is considered "empty",
  /// meaning it is either explicitly `null` or contains no elements.
  ///
  /// Returns:
  /// `true` if the list is `null` or empty, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// List<String>? nullList = null;
  /// bool isNullOrEmpty1 = nullList.isListNullOrEmpty; // Returns true
  ///
  /// List<int>? emptyList = [];
  /// bool isNullOrEmpty2 = emptyList.isListNullOrEmpty; // Returns true
  ///
  /// List<double>? nonEmptyList = [1.0, 2.0];
  /// bool isNullOrEmpty3 = nonEmptyList.isListNullOrEmpty; // Returns false
  /// ```
  bool get isListNullOrEmpty => this?.isEmpty ?? true;

  /// Checks if the nullable list is neither `null` nor empty.
  ///
  /// This is the inverse of [isListNullOrEmpty]. It provides a null-safe way to check
  /// if a nullable list actually contains elements and is not `null`.
  ///
  /// Returns:
  /// `true` if the list is not `null` and not empty, `false` otherwise (i.e., if it's `null` or empty).
  ///
  /// Example:
  /// ```dart
  /// List<String>? nullList = null;
  /// bool isNotEmpty1 = nullList.isNotListNullOrEmpty; // Returns false
  ///
  /// List<int>? emptyList = [];
  /// bool isNotEmpty2 = emptyList.isNotListNullOrEmpty; // Returns false
  ///
  /// List<double>? nonEmptyList = [1.0, 2.0];
  /// bool isNotEmpty3 = nonEmptyList.isNotListNullOrEmpty; // Returns true
  /// ```
  bool get isNotListNullOrEmpty => this?.isNotEmpty ?? false;
}
