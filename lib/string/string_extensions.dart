import 'package:saropa_dart_utils/string/string_nullable_extensions.dart';

/// A set of utility methods for working with strings.
extension StringExtensions on String {
  /// Returns a new string with the specified [start] removed from the beginning
  /// of the original string, if it exists.
  ///
  /// NOTE: returns null if empty so it can be used in ?? coalescing
  ///
  /// Example:
  /// ```dart
  /// String text = 'www.saropa.com';
  /// print(text.removeStart('www.')); // Output: saropa.com
  /// ```
  String? removeStart(
    String? start, {
    bool isCaseSensitive = true,
    bool trimFirst = false,
  }) {
    if (trimFirst) {
      // recurse on trimmed
      return trim().removeStart(
        start,
        isCaseSensitive: isCaseSensitive,
      );
    }

    if (start.isNullOrEmpty) {
      return this;
    }

    if (isCaseSensitive) {
      return startsWith(start!) ? substring(start.length).nullIfEmpty() : this;
    }

    return toLowerCase().startsWith(start!.toLowerCase())
        ? substring(start.length).nullIfEmpty()
        : nullIfEmpty();
  }

  /// Checks if a string is empty.
  ///
  /// Returns null if the string is empty, otherwise returns the string itself.
  String? nullIfEmpty({
    bool trimFirst = true,
  }) {
    /// If the string is empty, return null.
    if (isEmpty) {
      return null;
    }

    if (trimFirst) {
      final trimmed = trim();

      return trimmed.isEmpty ? null : trimmed;
    }

    /// If the string is not empty, return the string itself.
    return this;
  }

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
  String? encloseInParentheses({bool wrapEmpty = false}) {
    if (isNullOrEmpty) {
      return wrapEmpty ? '()' : null;
    }

    // Alternative code:
    // return wrapWith(before: '(', after: ')');
    return '($this)';
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
  String? wrapWith({String? before, String? after}) {
    if (isEmpty) {
      return null;
    }

    return '${before ?? ""}$this${after ?? ""}';
  }

  /// Extension method to remove consecutive spaces in a [String]
  /// and optionally trim the result.
  ///
  /// If [trim] is true (default), the resulting string will also have leading
  /// and trailing spaces removed.
  ///
  /// NOTE: returns null if empty so it can be used in ?? coalescing
  ///
  /// Example:
  /// ```dart
  /// String text = "  Saropa   has   multiple   spaces  ";
  /// print(text.removeConsecutiveSpaces()); // Output: "Saropa has multiple spaces"
  /// print(text.removeConsecutiveSpaces(trim: false)); // Output: " Saropa has multiple spaces "
  /// ```
  String? removeConsecutiveSpaces({bool trim = true}) {
    if (isEmpty) {
      return null;
    }

    String replaced;
    replaced = replaceAll(RegExp(r'\s+'), ' ');
    return replaced.nullIfEmpty(trimFirst: trim);
  }

  /// Extension method to remove consecutive spaces in a [String]
  /// and optionally trim the result.
  ///
  /// This is an alias for [removeConsecutiveSpaces].
  ///
  /// NOTE: returns null if empty so it can be used in ?? coalescing
  ///
  /// Example:
  /// ```dart
  /// String text = "  Saropa   has   multiple   spaces  ";
  /// print(text.compressSpaces()); // Output: "Saropa has multiple spaces"
  /// print(text.compressSpaces(trim: false)); // Output: " Saropa has multiple spaces "
  /// ```
  String? compressSpaces({bool trim = true}) {
    return removeConsecutiveSpaces(trim: trim);
  }
}
