import 'package:saropa_dart_utils/list/list_extensions.dart';

/// Extensions for presentation, like adding quotes, truncating text, and formatting.
extension StringFormattingAndWrappingExtensions on String {
  static const String accentedQuoteOpening = '‘';
  static const String accentedQuoteClosing = '’';
  static const String accentedDoubleQuoteOpening = '“';
  static const String accentedDoubleQuoteClosing = '”';
  static const String ellipsis = '…';
  static const String doubleChevron = '»';
  static const String apostrophe = '’';

  // https://www.compart.com/en/unicode/category/Pd
  // https://wikipedia.org/wiki/Hyphen
  static const String hyphen = '‐';

  /// Soft Hyphen character (U+00AD).
  /// Insert into strings to suggest word break points for automatic hyphenation
  /// by Flutter's text rendering engine. It's invisible unless a break occurs at its position.
  ///
  // cspell:disable-next-line
  /// e.g. 'hyph${SoftHyphen}Hyphenationena${SoftHyphen}Hyphenationtion'
  static const String softHyphen = '\u00ad';

  static const String newLine = '\n';
  static const String lineBreak = newLine;

  // https://blanktext.net/
  static const String blank = 'ㅤ';

  // cspell:disable
  /// 'This\u200Bis\u200Ba\u200Bsentence\u200Bwith\u200Bzero-width\u200Bspaces.
  // cspell:enable
  static const String zeroWidth = '\u200B';

  // ref NOTE https://tosbourn.com/how-to-turn-on-invisible-characters-in-vscode/
  // ref https://www.compart.com/en/unicode/U+2800
  // static const String invisible = '⠀';

  // ref https://stackoverflow.com/questions/64245554/non-breaking-space-in-flutter-string-interpolation
  static const String nonBreakingSpace = '\u00A0';

  /// For not breaking words into newline at hyphen in Text
  // ref https://stackoverflow.com/questions/59441148/flutter-no-breaking-words-into-newline-at-hyphen-in-text
  static const String nonBreakingHyphen = '\u2011';

  /// Wraps the string with the given [before] and [after] strings.
  String wrap({String? before, String? after}) {
    final String b = before ?? '';
    final String a = after ?? '';
    return '$b$this$a';
  }

  /// Extension method to wrap a [String] with a prefix [before]
  /// and a suffix [after]. Returns null if the string is empty.
  String? wrapWith({String? before, String? after}) {
    if (isEmpty) {
      return null;
    }
    return '${before ?? ""}$this${after ?? ""}';
  }

  /// Wraps the string in single quotes: `'string'`.
  ///
  /// If the string is empty, returns `''` if [quoteEmpty] is true,
  /// otherwise returns an empty string.
  String wrapSingleQuotes({bool quoteEmpty = false}) => isEmpty
      ? quoteEmpty
            ? "''"
            : ''
      : "'$this'";

  /// Wraps the string in double quotes: `"string"`.
  ///
  /// If the string is empty, returns `""` if [quoteEmpty] is true,
  /// otherwise returns an empty string.
  String wrapDoubleQuotes({bool quoteEmpty = false}) => isEmpty
      ? quoteEmpty
            ? '""'
            : ''
      : '"$this"';

  /// Return a string wrapped in ‘accented quotes’
  ///
  /// Note that empty strings will still be wrapped: '‘’'
  String wrapSingleAccentedQuotes({bool quoteEmpty = false}) => isEmpty
      ? quoteEmpty
            ? '$accentedQuoteOpening$accentedQuoteClosing'
            : ''
      : '$accentedQuoteOpening$this$accentedQuoteClosing';

  /// Return a string wrapped in “accented quotes”
  ///
  /// Note that empty strings will still be wrapped: '“”'
  String wrapDoubleAccentedQuotes({bool quoteEmpty = false}) => isEmpty
      ? quoteEmpty
            ? '$accentedDoubleQuoteOpening$accentedDoubleQuoteClosing'
            : ''
      : '$accentedDoubleQuoteOpening$this$accentedDoubleQuoteClosing';

  /// Extension method to enclose a [String] in parentheses.
  String? encloseInParentheses({bool wrapEmpty = false}) => isEmpty
      ? wrapEmpty
            ? '()'
            : null
      : '($this)';

  /// Inserts a newline character before each opening parenthesis.
  String insertNewLineBeforeBrackets() => replaceAll('(', '\n(');

  /// Truncates the string to [cutoff] and appends an ellipsis '…'.
  ///
  /// Returns the original string if it's shorter than [cutoff].
  String truncateWithEllipsis(int? cutoff) {
    // Return original string if it's empty or cutoff is invalid
    if (isEmpty || cutoff == null || cutoff <= 0) {
      return this;
    }

    // Return original string if it's already shorter than the cutoff
    if (length <= cutoff) {
      return this;
    }

    // Simple truncation if not keeping words intact
    return '${substring(0, cutoff)}$ellipsis';
    // maxLength <= 0 || length <= maxLength ? this : '${substring(0, maxLength)}…';
  }

  /// Truncates the string to [cutoff] and appends an ellipsis '…'.
  ///
  /// This method will not cut words in half. It will truncate at the last
  /// full word that fits within the [cutoff].
  ///
  /// Returns the original string if it's shorter than [cutoff].
  String truncateWithEllipsisPreserveWords(int? cutoff) {
    // Return original string if it's empty, cutoff is invalid, or it's already short enough.
    if (isEmpty || cutoff == null || cutoff <= 0 || length <= cutoff) {
      return this;
    }

    // Ensure we don't exceed the string's length when finding the last space.
    final int effectiveCutoff = cutoff >= length ? length : cutoff;

    // Find the last space within the allowed length
    final int lastSpaceIndex = substring(
      0,
      effectiveCutoff + 1 > length ? length : effectiveCutoff + 1,
    ).lastIndexOf(' ');

    // If no space is found (e.g., a single long word), we'll just return the ellipsis.
    if (lastSpaceIndex == -1) {
      return '…';
    }

    // Truncate at the last space found and remove any trailing space before adding the ellipsis.
    return '${substring(0, lastSpaceIndex).trimRight()}$ellipsis';
  }

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

  /// Replaces all characters that are not digits (0-9) with the [replacement] string.
  ///
  /// For example, `'abc123def'.replaceNonNumbers(replacement: '-')` results in `'---123---'`.
  String replaceNonNumbers({String replacement = ''}) =>
      // The regex \D matches any non-digit character and replaces it.
      replaceAll(RegExp(r'\D'), replacement);

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

  /// Checks if the string contains only Latin alphabet characters (a-z, A-Z).
  bool isLatin() =>
      // Use a regular expression to match only alphabetic characters from start to end.
      RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Checks if the string starts and ends with matching brackets.
  /// e.g., `(abc)`, `[abc]`, `{abc}`, `<abc>`.
  bool isBracketWrapped() {
    // A wrapped string must have at least 2 characters.
    if (length < 2) return false;
    // Check for each pair of matching brackets.
    return (startsWith('(') && endsWith(')')) ||
        (startsWith('[') && endsWith(']')) ||
        (startsWith('{') && endsWith('}')) ||
        (startsWith('<') && endsWith('>'));
  }

  /// Compares this string to [other], with options for case-insensitivity
  /// and apostrophe normalization.
  bool isEquals(String? other, {bool ignoreCase = true, bool normalizeApostrophe = true}) {
    // If other string is null, they can't be equal.
    if (other == null) return false;
    // Create mutable copies for normalization.
    String first = this;
    String second = other;

    // If ignoring case, convert both to lowercase.
    if (ignoreCase) {
      first = first.toLowerCase();
      second = second.toLowerCase();
    }
    // If normalizing apostrophes, replace variants with a standard one.
    if (normalizeApostrophe) {
      first = first.replaceAll(RegExp("['’]"), "'");
      second = second.replaceAll(RegExp("['’]"), "'");
    }
    // Perform the final comparison.
    return first == second;
  }

  /// Checks if this string contains [other] in a case-insensitive manner.
  bool containsIgnoreCase(String? other) {
    // If other is null or empty, it cannot be contained.
    if (other == null || other.isEmpty) return false;
    // Perform a case-insensitive search.
    return toLowerCase().contains(other.toLowerCase());
  }

  String getFirstDiffChar(String other) {
    final int minLength = length < other.length ? length : other.length;

    for (int i = 0; i < minLength; i++) {
      if (this[i] != other[i]) {
        return other[i];
      }
    }

    // If we reach this point, the shorter string is a prefix of the longer one.
    // The first "different" character is the first character of the remaining part
    // of the longer string.
    if (length > other.length) {
      return this[minLength];
    } else if (other.length > length) {
      return other[minLength];
    }

    // If the strings are identical, return an empty string.
    return '';
  }
}
