import 'package:saropa_dart_utils/string/string_validation_and_comparison_extensions.dart';

/// Extensions for adding, removing, or changing parts of a string.
extension StringManipulationAndSanitizationExtensions on String {
  /// Reverses the characters in the string. Handles Unicode characters correctly.
  String get reversed =>
      // Convert to runes for Unicode safety, reverse the list, and convert back to a string.
      String.fromCharCodes(runes.toList().reversed);

  /// Returns `null` if the string is empty or contains only whitespace.
  ///
  /// - [trimFirst]: If true (default), the string is trimmed before the check.
  /// Otherwise, returns the (potentially trimmed) string.
  String? nullIfEmpty({bool trimFirst = true}) {
    // Handle the empty string case directly.
    if (isEmpty) {
      return null;
    }
    // If trimFirst is enabled, trim the string before checking for emptiness.
    if (trimFirst) {
      final String trimmed = trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    // Otherwise, return the original string.
    return this;
  }

  /// Inserts [newChar] at the specified [position].
  ///
  /// Returns the original string if [position] is out of bounds.
  String insert(String newChar, int position) {
    // Validate the insertion position.
    if (position < 0 || position > length) return this;
    // Construct the new string.
    return substring(0, position) + newChar + substring(position);
  }

  /// Removes the last occurrence of [target] from the string.
  String removeLastOccurrence(String target) {
    // Find the last index of the target.
    final int lastIndex = lastIndexOf(target);
    // If the target is not found, return the original string.
    if (lastIndex == -1) return this;
    // Reconstruct the string without the last occurrence.
    return substring(0, lastIndex) + substring(lastIndex + target.length);
  }

  /// Removes the first and last characters if they are a matching pair of brackets.
  String removeMatchingWrappingBrackets() =>
      // Use isBracketWrapped to check, then remove the outer characters.
      isBracketWrapped() ? substring(1, length - 1) : this;

  /// Removes the specified [char] from the beginning and/or end of the string.
  String removeWrappingChar(String char, {bool trimFirst = true}) {
    // Method entry point.
    // FIX #1: Trim the string first if requested.
    String str = trimFirst ? trim() : this;
    // Check and remove the prefix if it exists.
    if (str.startsWith(char)) {
      // FIX #2: Remove the full length of the char, not just 1.
      str = str.substring(char.length);
    }
    // Check and remove the suffix if it exists.
    if (str.endsWith(char)) {
      // FIX #2: Remove the full length of the char, not just 1.
      str = str.substring(0, str.length - char.length);
    }
    // Return the processed string.
    return str;
  }

  /// Returns a new string with the specified [start] removed from the beginning
  /// of the original string, if it exists.
  String? removeStart(String? start, {bool isCaseSensitive = true, bool trimFirst = false}) {
    // If trimFirst is true, recurse with the trimmed string.
    if (trimFirst) {
      return trim().removeStart(start, isCaseSensitive: isCaseSensitive);
    }
    // If start is null or empty, there is nothing to remove.
    if (start == null || start.isEmpty) {
      return this;
    }
    // Handle case-sensitive removal.
    if (isCaseSensitive) {
      return startsWith(start) ? substring(start.length).nullIfEmpty() : this;
    }
    // Handle case-insensitive removal.
    return toLowerCase().startsWith(start.toLowerCase())
        ? substring(start.length).nullIfEmpty()
        : nullIfEmpty();
  }

  /// Removes [end] from the end of the string, if it exists.
  String removeEnd(String end) =>
      // Check if the string ends with the target and remove it if so.
      endsWith(end) ? substring(0, length - end.length) : this;

  /// Removes the first character from the string.
  String removeFirstChar() =>
      // Return empty if too short, otherwise return the substring from the second character.
      (length < 1) ? '' : substring(1);

  /// Removes the last character from the string.
  String removeLastChar() =>
      // Return empty if too short, otherwise return the substring without the last character.
      (length < 1) ? '' : substring(0, length - 1);

  /// Removes both the first and the last character from the string.
  String removeFirstLastChar() =>
      // Return empty if too short, otherwise return the inner substring.
      (length < 2) ? '' : substring(1, length - 1);

  /// Replaces different apostrophe characters (’ and ') with a standard single quote.
  String normalizeApostrophe() =>
      // Use a regex to find and replace apostrophe variants.
      replaceAll(RegExp("['’]"), "'");

  /// Removes all characters that are not letters (A-Z, a-z).
  String toAlphaOnly({bool allowSpace = false}) {
    // Define the regex based on whether spaces are allowed.
    final RegExp regExp = allowSpace ? RegExp('[^A-Za-z ]') : RegExp('[^A-Za-z]');
    // Replace all non-matching characters.
    return replaceAll(regExp, '');
  }

  /// Removes all characters that are not letters or numbers.
  String removeNonAlphaNumeric({bool allowSpace = false}) {
    // Define the regex based on whether spaces are allowed.
    final RegExp regExp = allowSpace ? RegExp('[^A-Za-z0-9 ]') : RegExp('[^A-Za-z0-9]');
    // Replace all non-matching characters.
    return replaceAll(regExp, '');
  }

  /// Removes all characters that are not digits (0-9).
  String removeNonNumbers() =>
      // The regex \D matches any non-digit character.
      replaceAll(RegExp(r'\D'), '');

  /// Escapes characters in a string that have a special meaning in regular expressions.
  String escapeForRegex() =>
      // The regex finds any special regex character, and the callback prepends a backslash.
      replaceAllMapped(RegExp(r'[.*+?^${}()|[\]\\]'), (Match m) => '\\${m[0]}');

  /// Extension method to remove consecutive spaces in a [String]
  /// and optionally trim the result.
  String? removeConsecutiveSpaces({bool trim = true}) {
    // Handle empty string case.
    if (isEmpty) {
      return null;
    }
    // The regex \s+ matches one or more whitespace characters.
    final String replaced = replaceAll(RegExp(r'\s+'), ' ');
    // Return the result, potentially trimmed and checked for emptiness.
    return replaced.nullIfEmpty(trimFirst: trim);
  }

  /// Extension method to remove consecutive spaces in a [String]
  /// and optionally trim the result. This is an alias for [removeConsecutiveSpaces].
  String? compressSpaces({bool trim = true}) =>
      // Defer to the main implementation.
      removeConsecutiveSpaces(trim: trim);
}
