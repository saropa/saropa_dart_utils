/// A set of utility methods for working with strings.
extension NullableStringExtensions on String? {
  /// Returns a new string with the specified [start] removed from the beginning
  /// of the original string, if it exists.
  ///
  /// Example:
  /// ```dart
  /// String text = 'www.saropa.com';
  /// print(text.removeStart('www.')); // Output: saropa.com
  /// ```
  @Deprecated('use StringExtensions.removeStart()')
  String? removeStart(String start) {
    if (start.isEmpty) {
      return this;
    }

    if (this == null) {
      return null;
    }

    return this!.startsWith(start) ? this?.substring(start.length) : this;
  }

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

  /// Extension method to check if a [String] is not null or empty.
  ///
  /// Returns `true` if the string is neither `null` nor an empty string (`""`).
  /// Otherwise, returns `false`.
  ///
  /// Example:
  /// ```dart
  /// String? text;
  /// print(text.notNullOrEmpty); // Output: false
  ///
  /// text = "";
  /// print(text.notNullOrEmpty); // Output: false
  ///
  /// text = "Hello";
  /// print(text.notNullOrEmpty); // Output: true
  /// ```
  @Deprecated('use !isNullOrEmpty')
  bool get notNullOrEmpty => !isNullOrEmpty;

  /// Extension method to enclose a [String] in parentheses.
  ///
  /// If the string is null or empty it returns null unless [wrapEmpty]
  /// is set to true,
  /// in which case it returns '()'. If an error occurs, it logs the error
  /// and returns null.
  ///
  /// Example:
  /// ```dart
  /// String? text = "Saropa";
  /// print(text.encloseInParentheses()); // Output: (Saropa)
  ///
  /// text = "";
  /// print(text.encloseInParentheses(wrapEmpty: true)); // Output: ()
  ///
  /// text = null;
  /// print(text.encloseInParentheses()); // Output: null
  ///
  /// ```
  @Deprecated('use StringExtensions.encloseInParentheses()')
  String? encloseInParentheses({bool wrapEmpty = false}) {
    if (isNullOrEmpty) {
      return wrapEmpty ? '()' : null;
    }

    return '(${this!})';
  }

  /// Extension method to wrap a [String] with a prefix [before]
  /// and a suffix [after].
  ///
  /// If the string is null or empty, it returns null. If [before]
  /// or [after] are null or empty,
  ///
  /// they are ignored in the wrapping process.
  ///
  /// Examples:
  /// ```dart
  /// String? text = "Saropa";
  /// print(text.wrapWith(before: "(", after: ")")); // Output: (Saropa)
  /// print(text.wrapWith(before: "Prefix-")); // Output: Prefix-Saropa
  /// print(text.wrapWith(after: "-Suffix")); // Output: Saropa-Suffix
  /// ```
  ///
  @Deprecated('use StringExtensions.wrapWith()')
  String? wrapWith({String? before, String? after}) {
    if (isNullOrEmpty) {
      return null;
    }

    String result;
    result = this!;
    if (!before.isNullOrEmpty) {
      result = '$before$result';
    }
    if (!after.isNullOrEmpty) {
      result = '$result$after';
    }

    return result;
  }

  /// Extension method to remove consecutive spaces in a [String]
  /// and optionally trim the result.
  ///
  /// If [trim] is true (default), the resulting string will also have leading
  /// and trailing spaces removed.
  ///
  /// Example:
  /// ```dart
  /// String text = "  Saropa   has   multiple   spaces  ";
  /// print(text.removeConsecutiveSpaces()); // Output: "Saropa has multiple spaces"
  /// print(text.removeConsecutiveSpaces(trim: false)); // Output: " Saropa has multiple spaces "
  /// ```
  @Deprecated('use StringExtensions.removeConsecutiveSpaces()')
  String removeConsecutiveSpaces({bool trim = true}) {
    if (isNullOrEmpty) {
      return '';
    }

    String replaced;
    replaced = this!.replaceAll(RegExp(r'\s+'), ' ');
    return trim ? replaced.trim() : replaced;
  }

  /// Extension method to remove consecutive spaces in a [String]
  /// and optionally trim the result.
  ///
  /// This is an alias for [removeConsecutiveSpaces].
  ///
  /// Example:
  /// ```dart
  /// String text = "  Saropa   has   multiple   spaces  ";
  /// print(text.compressSpaces()); // Output: "Saropa has multiple spaces"
  /// print(text.compressSpaces(trim: false)); // Output: " Saropa has multiple spaces "
  /// ```
  @Deprecated('use StringExtensions.removeConsecutiveSpaces()')
  String compressSpaces({bool trim = true}) {
    return removeConsecutiveSpaces(trim: trim);
  }
}
