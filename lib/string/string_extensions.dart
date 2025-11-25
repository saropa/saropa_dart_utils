import 'package:saropa_dart_utils/list/list_extensions.dart';

final RegExp _apostropheRegex = RegExp("['’]");

final RegExp _alphaOnlyRegex = RegExp('[^A-Za-z]');

final RegExp _alphaOnlyWithSpaceRegex = RegExp('[^A-Za-z ]');

final RegExp _alphaNumericOnlyRegex = RegExp('[^A-Za-z0-9]');

final RegExp _alphaNumericOnlyWithSpaceRegex = RegExp('[^A-Za-z0-9 ]');

final RegExp _nonDigitRegex = RegExp(r'\D');

final RegExp _regexSpecialCharsRegex = RegExp(r'[.*+?^${}()|[\]\\]');

final RegExp _consecutiveSpacesRegex = RegExp(r'\s+');

final RegExp _latinRegex = RegExp(r'^[a-zA-Z]+$');

final RegExp _splitCapitalizedUnicodeRegex = RegExp(r'(?<=\p{Ll})(?=\p{Lu}|\p{Lt})', unicode: true);

final RegExp _splitCapitalizedUnicodeWithNumbersRegex = RegExp(
  r'(?<=\p{Ll})(?=\p{Lu}|\p{Lt}|\p{Nd})|(?<=\p{Nd})(?=\p{L})',
  unicode: true,
);

final RegExp _singleCharWordRegex = RegExp(r'\b\w\b');

final RegExp _anyDigitsRegex = RegExp(r'\d');

final RegExp _curlyBracesRegex = RegExp(r'\{.+\}');

final RegExp _lineBreakRegex = RegExp('\n');

/// Extensions for presentation, like adding quotes, truncating text, and formatting.
extension StringExtensions on String {
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

  /// Bullet point character (•).
  static const String bullet = '\u2022';

  /// Alias for [bullet].
  static const String dot = bullet;

  /// A dot with spaces for joining items (e.g., "Item 1 • Item 2").
  static const String dotJoiner = ' $bullet ';

  /// Common word-ending characters for text processing.
  static const List<String> commonWordEndings = <String>[
    ' ',
    '.',
    ',',
    '?',
    '!',
    ':',
    ';',
    '{',
    '}',
    '[',
    ']',
    '(',
    ')',
    '-',
    hyphen,
    '"',
    "'",
    ellipsis,
    dot,
    accentedQuoteOpening,
    accentedQuoteClosing,
    accentedDoubleQuoteOpening,
    accentedDoubleQuoteClosing,
    newLine,
  ];

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
  /// full word that fits within the [cutoff]. If the first word is longer than
  /// the cutoff, it falls back to simple truncation at the cutoff point to
  /// ensure some content is always returned.
  ///
  /// Args:
  ///   cutoff (int?): The maximum length before truncation. If null, 0, or negative,
  ///   returns the original string.
  ///
  /// Returns:
  ///   String: The truncated string with ellipsis, or the original string if it's
  ///   shorter than [cutoff].
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.truncateWithEllipsisPreserveWords(8); // Returns 'Hello…'
  /// 'Hello World'.truncateWithEllipsisPreserveWords(20); // Returns 'Hello World'
  /// 'Supercalifragilistic'.truncateWithEllipsisPreserveWords(5); // Returns 'Super…'
  /// ```
  String truncateWithEllipsisPreserveWords(int? cutoff) {
    // Return original string if it's empty, cutoff is invalid, or it's already short enough.
    if (isEmpty || cutoff == null || cutoff <= 0 || length <= cutoff) {
      return this;
    }

    // Find the last space within the allowed length (checking up to cutoff + 1 to include
    // a space right at the cutoff boundary)
    final int searchLength = cutoff + 1 > length ? length : cutoff + 1;
    final int lastSpaceIndex = substring(0, searchLength).lastIndexOf(' ');

    // If no space is found (e.g., a single long word), fall back to simple truncation
    // at the cutoff point. This ensures we always return some meaningful content
    // rather than just an ellipsis.
    if (lastSpaceIndex == -1 || lastSpaceIndex == 0) {
      return '${substring(0, cutoff)}$ellipsis';
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
      replaceAll(_apostropheRegex, "'");

  /// Removes all characters that are not letters (A-Z, a-z).
  // Replace all non-matching characters.
  String toAlphaOnly({bool allowSpace = false}) =>
      replaceAll(allowSpace ? _alphaOnlyWithSpaceRegex : _alphaOnlyRegex, '');

  /// Removes all characters that are not letters or numbers.
  // Replace all non-matching characters.
  String removeNonAlphaNumeric({bool allowSpace = false}) =>
      replaceAll(allowSpace ? _alphaNumericOnlyWithSpaceRegex : _alphaNumericOnlyRegex, '');

  /// Replaces all characters that are not digits (0-9) with the [replacement] string.
  ///
  /// For example, `'abc123def'.replaceNonNumbers(replacement: '-')` results in `'---123---'`.
  String replaceNonNumbers({String replacement = ''}) =>
      // The regex \D matches any non-digit character and replaces it.
      replaceAll(_nonDigitRegex, replacement);

  /// Removes all characters that are not digits (0-9).
  String removeNonNumbers() =>
      // The regex \D matches any non-digit character.
      replaceAll(_nonDigitRegex, '');

  /// Escapes characters in a string that have a special meaning in regular expressions.
  String escapeForRegex() =>
      // The regex finds any special regex character, and the callback prepends a backslash.
      replaceAllMapped(_regexSpecialCharsRegex, (Match m) => '\\${m[0]}');

  /// Extension method to remove consecutive spaces in a [String]
  /// and optionally trim the result.
  String? removeConsecutiveSpaces({bool trim = true}) {
    // Handle empty string case.
    if (isEmpty) {
      return null;
    }
    // The regex \s+ matches one or more whitespace characters.
    final String replaced = replaceAll(_consecutiveSpacesRegex, ' ');
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
    final RegExp capitalizationPattern = splitNumbers
        ? _splitCapitalizedUnicodeWithNumbersRegex
        : _splitCapitalizedUnicodeRegex;
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
        .expand((String part) => part.split(_consecutiveSpacesRegex))
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
      _latinRegex.hasMatch(this);

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
      first = first.replaceAll(_apostropheRegex, "'");
      second = second.replaceAll(_apostropheRegex, "'");
    }
    // Perform the final comparison.
    return first == second;
  }

  /// Checks if this string contains [other] in a case-insensitive manner.
  ///
  /// Following standard string semantics, an empty string is considered to be
  /// contained in any string (including empty strings). Returns `false` only
  /// when [other] is `null`.
  ///
  /// Args:
  ///   other (String?): The substring to search for. Returns `false` if null.
  ///
  /// Returns:
  ///   bool: `true` if this string contains [other] (case-insensitive), `false` if
  ///   [other] is null.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.containsIgnoreCase('world'); // true
  /// 'Hello World'.containsIgnoreCase('HELLO'); // true
  /// 'Hello World'.containsIgnoreCase('xyz'); // false
  /// 'Hello World'.containsIgnoreCase(''); // true (empty string is always contained)
  /// 'Hello World'.containsIgnoreCase(null); // false
  /// ''.containsIgnoreCase(''); // true
  /// ```
  bool containsIgnoreCase(String? other) {
    // Null cannot be contained
    if (other == null) return false;
    // Empty string is always contained (standard string semantics)
    if (other.isEmpty) return true;
    // Perform a case-insensitive search
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

  /// The Unicode replacement character code point for invalid sequences.
  static const int _invalidUnicodeReplacementRuneCode = 56327;

  /// Returns true if this string contains invalid Unicode characters.
  bool get hasInvalidUnicode {
    if (isEmpty) return false;
    return runes.any((int r) => r == _invalidUnicodeReplacementRuneCode);
  }

  /// Removes all invalid Unicode replacement characters.
  String removeInvalidUnicode() {
    if (isEmpty) return this;
    final StringBuffer buffer = StringBuffer();
    for (int r in runes.where((int e) => e != _invalidUnicodeReplacementRuneCode)) {
      buffer.write(String.fromCharCode(r));
    }
    return buffer.toString();
  }

  /// Returns true if this single-character string is a vowel.
  bool isVowel() {
    if (isEmpty || length != 1) return false;
    switch (toLowerCase()) {
      case 'a':
      case 'e':
      case 'i':
      case 'o':
      case 'u':
        return true;
      default:
        return false;
    }
  }

  /// Returns true if this string contains any digit characters.
  bool hasAnyDigits() => contains(_anyDigitsRegex);

  /// Gets the last [len] characters of this string, handling Unicode correctly.
  ///
  /// Returns the full string if [len] is greater than the string length.
  String last(int len) {
    if (isEmpty || len <= 0) return '';
    if (len >= runes.length) return this;
    final List<int> runeList = runes.toList().sublist(runes.length - len);
    return String.fromCharCodes(runeList);
  }

  /// Returns a random character from this string.
  String getRandomChar() {
    if (isEmpty) return '';
    final int index = DateTime.now().microsecondsSinceEpoch % length;
    return this[index];
  }

  /// Repeats this string [count] times.
  String repeat(int count) {
    if (isEmpty || count <= 0) return '';
    return List<String>.filled(count, this).join();
  }

  /// Replaces all occurrences of [pattern] with an empty string.
  String removeAll(Pattern? pattern) {
    if (pattern == null) return this;
    return replaceAll(pattern, '');
  }

  /// Replaces the last [n] characters with [replacementChar].
  String replaceLastNCharacters(int n, String replacementChar) {
    if (n <= 0 || n > length) return this;
    return substring(0, length - n) + replacementChar * n;
  }

  /// Replaces hyphens and spaces with non-breaking equivalents.
  String makeNonBreaking() => replaceAll('-', nonBreakingHyphen)
      .replaceAll(' ', nonBreakingSpace);

  /// Removes single-character words from this string.
  String? removeSingleCharacterWords({bool trim = true, bool removeMultipleSpaces = true}) {
    if (isEmpty) return this;
    String result = removeAll(_singleCharWordRegex);
    if (removeMultipleSpaces) {
      result = result.replaceAll(RegExp(r'\s+'), ' ');
    }
    if (trim) {
      result = result.trim();
    }
    return result.isEmpty ? null : result;
  }

  /// Replaces line breaks with a specified string.
  String replaceLineBreaks(String? replacement, {bool deduplicate = true}) {
    final String result = replaceAll(_lineBreakRegex, replacement ?? '');
    if (deduplicate && replacement != null && replacement.isNotEmpty) {
      return result.replaceAll(replacement + replacement, replacement);
    }
    return result;
  }

  /// Removes leading and trailing occurrences of [find].
  String? removeLeadingAndTrailing(String? find, {bool trim = false}) {
    if (isEmpty || find == null || find.isEmpty) return this;
    String value = trim ? this.trim() : this;
    while (value.startsWith(find)) {
      value = value.substring(find.length);
      if (trim) value = value.trim();
    }
    while (value.endsWith(find)) {
      value = value.substring(0, value.length - find.length);
      if (trim) value = value.trim();
    }
    return value.isEmpty ? null : value;
  }

  /// Returns the first word of this string.
  String? firstWord() {
    if (isEmpty) return null;
    return words()?.firstOrNull;
  }

  /// Returns the second word of this string.
  String? secondWord() {
    if (isEmpty) return null;
    final List<String>? wordList = words();
    if (wordList == null || wordList.length < 2) return null;
    return wordList[1];
  }

  /// Counts occurrences of [find] in this string.
  int count(String find) {
    if (find.isEmpty) return 0;
    return split(find).length - 1;
  }

  /// Extracts only letter characters (A-Z, a-z) from this string.
  String lettersOnly() {
    if (isEmpty) return '';
    final StringBuffer result = StringBuffer();
    for (int rune in runes) {
      if ((rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122)) {
        result.write(String.fromCharCode(rune));
      }
    }
    return result.toString();
  }

  /// Extracts only lowercase letter characters (a-z) from this string.
  String lowerCaseLettersOnly() {
    if (isEmpty) return '';
    final StringBuffer result = StringBuffer();
    for (int rune in runes) {
      if (rune >= 97 && rune <= 122) {
        result.write(String.fromCharCode(rune));
      }
    }
    return result.toString();
  }

  /// Returns the first [limit] lines of this string.
  String firstLines(int limit) {
    if (isEmpty || limit <= 0) return '';
    final List<String> lines = split(newLine);
    return lines.take(limit).join(newLine);
  }

  /// Trims each line and removes empty lines.
  String trimLines() => split(newLine)
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .join(newLine);

  /// Prefixes every line with [insertText].
  String multiLinePrefix(String insertText, {bool prefixEmptyStrings = false}) {
    if (insertText.isEmpty) return this;
    if (isEmpty) return prefixEmptyStrings ? insertText : '';
    return insertText + replaceAll(newLine, newLine + insertText);
  }

  /// Returns true if this string ends with any character in [find].
  bool endsWithAny(List<String> find) {
    if (isEmpty || find.isEmpty) return false;
    final String lastChar = last(1);
    return find.any((String e) => e == lastChar);
  }

  /// Returns true if this string ends with punctuation.
  bool endsWithPunctuation() => endsWithAny(const <String>['.', '?', '!']);

  /// Returns true if this string equals any item in [list].
  bool isAny(List<String> list) {
    if (isEmpty || list.isEmpty) return false;
    return list.any((String e) => e == this);
  }

  /// Finds the index of the second occurrence of [char].
  int secondIndex(String char) {
    if (char.isEmpty || isEmpty) return -1;
    final int firstIdx = indexOf(char);
    if (firstIdx == -1) return -1;
    return indexOf(char, firstIdx + 1);
  }

  /// Extracts all text within curly braces.
  List<String>? extractCurlyBraces() {
    final List<String> matches = _curlyBracesRegex
        .allMatches(this)
        .map((Match m) => m[0])
        .whereType<String>()
        .toList();
    return matches.isEmpty ? null : matches;
  }

  /// Appends [value] only if this string is not empty.
  String appendNotEmpty(String value) => isEmpty ? '' : this + value;

  /// Prepends [value] only if this string is not empty.
  String prefixNotEmpty(String? value) {
    if (isEmpty || value == null || value.isEmpty) return this;
    return value + this;
  }

  /// Returns 'a' or 'an' based on the first character (for English grammar).
  String grammarArticle() {
    if (isEmpty) return '';
    switch (this[0].toLowerCase()) {
      case 'a':
      case 'e':
      case 'i':
      case 'o':
      case 'u':
        return 'an';
      default:
        return 'a';
    }
  }

  /// Returns the possessive form of this string.
  String possess({bool isLocaleUS = true}) {
    if (isEmpty) return this;
    if (isLocaleUS && lastChars(1) == 's') {
      return "$this'";
    }
    return "$this's";
  }

  /// Returns the plural form of this string.
  String pluralize(num? count, {bool simple = false}) {
    if (isEmpty || count == 1 || length == 1) return this;
    if (simple) return '${this}s';

    final String lastChar = lastChars(1);
    switch (lastChar) {
      case 's':
      case 'x':
      case 'z':
        return '${this}es';
      case 'y':
        if (length > 2 && this[length - 2].isVowel()) return '${this}s';
        return '${substring(0, length - 1)}ies';
    }

    final String lastTwo = lastChars(2);
    if (lastTwo == 'sh' || lastTwo == 'ch') return '${this}es';
    return '${this}s';
  }

  /// Creates an obscured version of this string.
  String? obscureText({String char = '•', int obscureLength = 3}) {
    if (isEmpty) return null;
    final int seed = DateTime.now().microsecondsSinceEpoch;
    final int extraLength = (seed % (2 * obscureLength + 1)) - obscureLength;
    final int finalLength = length + extraLength;
    return char * (finalLength > 0 ? finalLength : 1);
  }

  /// Truncates with ellipsis at both ends.
  String trimWithEllipsis({int minLength = 5}) {
    if (length < minLength) return ellipsis;
    if (length < (minLength * 2) + 2) {
      return substring(0, minLength) + ellipsis;
    }
    return substring(0, minLength) + ellipsis + substring(length - minLength);
  }

  /// Collapses a multiline string into a single line with optional truncation.
  String collapseMultilineString({required int cropLength, bool appendEllipsis = true}) {
    if (isEmpty) return this;
    final String collapsed = replaceAll(newLine, ' ').replaceAll('  ', ' ');
    if (collapsed.length <= cropLength) return collapsed.trim();

    String cropped = collapsed.substring(0, cropLength + 1);
    while (cropped.isNotEmpty && !cropped.endsWithAny(commonWordEndings)) {
      cropped = cropped.substring(0, cropped.length - 1);
    }
    if (cropped.isNotEmpty) {
      cropped = cropped.substring(0, cropped.length - 1).trim();
    }
    return appendEllipsis ? cropped + ellipsis : cropped;
  }
}
