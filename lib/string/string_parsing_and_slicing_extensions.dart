import 'package:saropa_dart_utils/list/list_extensions.dart';
import 'package:saropa_dart_utils/string/string_manipulation_and_sanitization_extensions.dart';

/// Extensions for splitting strings in advanced ways and safely extracting substrings.
extension StringParsingAndSlicingExtensions on String {
  /// Splits a string by capitalized letters (Unicode-aware) and optionally by spaces,
  /// with an option to prevent splits that result in short segments.
  ///
  /// - [splitNumbers]: If true, also splits before digits.
  /// - [splitBySpace]: If true, splits the result by whitespace.
  /// - [minLength]: Merges adjacent splits if either segment is shorter than this length.
  List<String> splitCapitalizedUnicode({
    bool splitNumbers = false,
    bool splitBySpace = false,
    int minLength = 1,
  }) {
    // Method entry point.
    if (isEmpty) return <String>[]; // Handle empty string case.

    // Define the regex for splitting at capitalized letters (and optionally numbers).
    final RegExp capitalizationPattern = RegExp(
      splitNumbers
          // FIX: Added an OR condition `|(?<=\p{Nd})(?=\p{L})`
          // This now handles both (lowercase -> uppercase/digit) AND (digit -> letter).
          ? r'(?<=\p{Ll})(?=\p{Lu}|\p{Lt}|\p{Nd})|(?<=\p{Nd})(?=\p{L})' // Lower -> Upper/Title/Digit OR Digit -> Letter
          : r'(?<=\p{Ll})(?=\p{Lu}|\p{Lt})', // Lower -> Upper/Title
      unicode: true,
    );
    // Perform the initial split based on the capitalization pattern.
    List<String> intermediateSplit = split(capitalizationPattern);

    // Check if merging is needed based on minLength.
    if (minLength > 1 && intermediateSplit.length > 1) {
      // Logic to merge short segments.
      final List<String> mergedResult = <String>[];
      String currentBuffer = intermediateSplit.first;
      // Loop through the segments to check for necessary merges.
      for (int i = 1; i < intermediateSplit.length; i++) {
        final String nextPart = intermediateSplit[i];
        // If either the current or next part is too short, merge them.
        if (currentBuffer.length < minLength || nextPart.length < minLength) {
          currentBuffer += nextPart;
        } else {
          // Otherwise, finalize the current buffer and start a new one.
          mergedResult.add(currentBuffer);
          currentBuffer = nextPart;
        }
      }
      // Add the final buffer to the results.
      mergedResult.add(currentBuffer);
      // Update the list with the merged results.
      intermediateSplit = mergedResult;
    }

    // If we are not splitting by space, return the result now.
    if (!splitBySpace) return intermediateSplit;

    // Otherwise, split each segment by space and flatten the list.
    return intermediateSplit
        .expand((String part) => part.split(RegExp(r'\s+')))
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  /// Returns the substring before the first occurrence of [find].
  /// Returns the original string if [find] is not found.
  String getEverythingBefore(String find) {
    // Find the index of the target string.
    final int atIndex = indexOf(find);
    // Return the substring before the index, or the original string if not found.
    return atIndex == -1 ? this : substring(0, atIndex);
  }

  /// Returns the substring after the first occurrence of [find].
  /// Returns the original string if [find] is not found.
  String getEverythingAfter(String find) {
    // Find the index of the target string.
    final int atIndex = indexOf(find);
    // Return the substring after the index, or the original string if not found.
    return atIndex == -1 ? this : substring(atIndex + find.length);
  }

  /// Returns the substring after the last occurrence of [find].
  /// Returns the original string if [find] is not found.
  String getEverythingAfterLast(String find) {
    if (find.isEmpty) {
      return this;
    }

    // Find the last index of the target string.
    final int atIndex = lastIndexOf(find);
    // Return the substring after the last index, or the original string if not found.
    return atIndex == -1 ? this : substring(atIndex + find.length);
  }

  /// Safely gets a substring, preventing [RangeError].
  ///
  /// Returns an empty string if [start] is out of bounds or parameters are invalid.
  String substringSafe(int start, [int? end]) {
    // Validate the start index.
    if (start < 0 || start > length) return '';
    // If an end index is provided, validate it.
    if (end != null) {
      // Ensure end is not before start.
      if (end < start) return '';
      // Clamp the end index to the string length.
      end = end > length ? length : end;
    }
    // Return the substring with validated indices.
    return substring(start, end);
  }

  /// Get the last [n] characters of a string.
  ///
  /// Returns the full string if its length is less than [n].
  String lastChars(int n) {
    // Handle invalid length.
    if (n <= 0) return '';
    // If requested length is greater than or equal to string length, return the whole string.
    if (n >= length) return this;
    // Return the last n characters.
    return substring(length - n);
  }

  /// Splits the string into a list of words, using space (" ") as the delimiter.
  ///
  /// This method splits the string by spaces, and filters out any empty or null words.
  List<String>? words() {
    // Handle empty string case by returning null.
    if (isEmpty) {
      return null;
    }

    // Split by space, convert empty parts to null, then filter out the nulls.
    return split(
      ' ',
    ).map((String word) => word.nullIfEmpty()).whereType<String>().toList().nullIfEmpty();
  }
}
