import 'package:saropa_dart_utils/string/string_nullable_extensions.dart';

/// A set of utility methods for working with strings.
extension StringExtensions on String {
  // cspell: ignore Corrext
  /// Compares this string with another string character by character and returns the first character that differs between them, or an empty string if the strings are identical up to the length of the shorter string.
  ///
  /// This method is optimized for quickly pinpointing the location of the first difference in strings, especially useful in test assertions for identifying subtle discrepancies.
  ///
  /// Returns the first differing [String] character from the `other` string, or an empty [String] if:
  /// - The strings are identical up to the length of the shorter string.
  /// - This string is empty or `other` string is empty and they are identical.
  ///
  /// If the strings have different lengths and no difference is found within the shorter length, an empty string is returned, implying identity up to the shorter length.
  ///
  /// Example Usage in Tests:
  /// ```dart
  /// test('String comparison - find first different char', () {
  ///   String expected = 'Correct String';
  ///   String actual = 'Corrext String'; // 'r' vs 'x'
  ///   expect(actual, expected, reason: expected.getFirstDiffChar(actual)); // Use getFirstDiffChar as reason
  /// });
  /// ```
  ///
  /// Parameters:
  ///   - `other`: The [String] to compare this string to. Must not be `null`.
  ///
  /// Returns:
  /// A [String] representing the first differing character from the `other` string, or an empty [String] if no difference is found up to the length of the shorter string, or if either string is empty and they are considered equal.
  String getFirstDiffChar(String other) {
    final int len1 = length;
    final int len2 = other.length;
    final int shorterLength = len1 < len2 ? len1 : len2;

    for (int i = 0; i < shorterLength; i++) {
      if (this[i] != other[i]) {
        return other[i]; // Return the differing character from the 'other' string
      }
    }

    return ''; // Empty string indicates no difference up to shorter length
  }

  /// Splits the string into a list of words, using space (" ") as the delimiter.
  ///
  /// This method splits the string by spaces, trims each resulting word to remove
  /// leading/trailing whitespace, and filters out any empty words.
  ///
  /// Returns:
  /// A [List<String>] containing the words from the string, or `null` if the
  /// original string is empty or if an error occurs during processing.
  /// Empty words resulting from multiple spaces or leading/trailing spaces are not included
  /// in the returned list.
  ///
  /// Example:
  /// ```dart
  /// String text = "  Hello   world from Dart  ";
  /// List<String>? wordList = text.words();
  /// print(wordList); // Output: [Hello, world, from, Dart]
  ///
  /// String emptyText = "";
  /// List<String>? emptyWordList = emptyText.words();
  /// print(emptyWordList); // Output: null
  /// ```
  List<String>? words() {
    if (isEmpty) {
      // failed null or empty check
      return null;
    }

    return isEmpty
        ? null
        : split(' ')
            .map((String word) {
              return word.nullIfEmpty();
            })
            .nonNulls
            .toList();
  }

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
  String? removeStart(String? start, {bool isCaseSensitive = true, bool trimFirst = false}) {
    if (trimFirst) {
      // recurse on trimmed
      return trim().removeStart(start, isCaseSensitive: isCaseSensitive);
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
  String? nullIfEmpty({bool trimFirst = true}) {
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
