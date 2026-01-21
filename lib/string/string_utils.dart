// Utility methods for string operations.
//
// These methods are designed to provide additional functionality for
// working with strings, such as splitting, extracting, and appending.

/// Minimum position in the Latin alphabet (1 = A/a).
const int _minAlphabetPosition = 1;

/// Maximum position in the Latin alphabet (26 = Z/z).
const int _maxAlphabetPosition = 26;

/// `StringUtils` is a utility class in Dart that provides static methods
/// for manipulating and analyzing strings. This class cannot be instantiated.
///
/// The methods in this class include, but are not limited to, methods for
/// checking string equality, converting strings to different cases,
/// checking if a string is empty or null, and so on.
///
/// Example usage:
/// ```dart
/// String str = 'Hello, World!';
/// bool isEmpty = StringUtils.isEmpty(str);  // returns false
/// String upper = StringUtils.toUpperCase(str);  // returns 'HELLO, WORLD!'
/// ```
///
/// Note: All methods in this class are null-safe, meaning they will not throw
/// an exception if the input string is null. Instead, they will return a
/// reasonable default value (usually null or false, depending on the method).
///
class StringUtils {
  /// Returns the n-th letter of the alphabet in uppercase.
  ///
  /// - [n] is an integer representing the position of the letter in the
  ///   alphabet (1 = A, 2 = B, etc.).
  ///
  /// Returns a string containing the n-th letter of the alphabet in uppercase,
  /// or `null` if [n] is not within the valid range or an error occurs.
  ///
  static String? getNthLatinLetterUpper(int n) {
    // Check if n is within the valid range.
    if (n < _minAlphabetPosition || n > _maxAlphabetPosition) {
      // If n is not within the valid range, return null.
      return null;
    }

    // Calculate the Unicode code point of the n-th letter of the alphabet.
    final int codePoint = 'A'.codeUnitAt(0) + n - 1;

    // Create a new string from the Unicode code point and return it.
    return String.fromCharCode(codePoint);
  }

  /// Returns the n-th letter of the alphabet in lowercase.
  ///
  /// - [n] is an integer representing the position of the letter in the
  ///   alphabet (1 = a, 2 = b, etc.).
  ///
  /// Returns a string containing the n-th letter of the alphabet in lowercase,
  /// or `null` if [n] is not within the valid range or an error occurs.
  ///
  static String? getNthLatinLetterLower(int n) {
    // Check if n is within the valid range.
    if (n < _minAlphabetPosition || n > _maxAlphabetPosition) {
      // If n is not within the valid range, return null.
      return null;
    }

    // Calculate the Unicode code point of the n-th letter of the alphabet.
    final int codePoint = 'a'.codeUnitAt(0) + n - 1;

    // Create a new string from the Unicode code point and return it.
    return String.fromCharCode(codePoint);
  }
}
