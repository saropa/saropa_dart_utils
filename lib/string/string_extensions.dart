import 'package:characters/characters.dart';
import 'package:meta/meta.dart';
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

final RegExp _singleCharWordRegex = RegExp(r'(?<=^|\s)[\p{L}\p{N}](?=\s|$)', unicode: true);

final RegExp _anyDigitsRegex = RegExp(r'\d');

final RegExp _curlyBracesRegex = RegExp(r'\{.+?\}');

final RegExp _lineBreakRegex = RegExp('\n');

const List<String> _silentHPrefixes = <String>['hour', 'honest', 'honor', 'heir'];
const List<String> _youSoundPrefixes = <String>['uni', 'use', 'user', 'union', 'university'];
const String _wunSoundPrefix = 'one';

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

  /// Alias for `bullet`.
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

  /// Returns this string wrapped with [before] prepended and [after] appended.
  String wrap({String? before, String? after}) {
    final String prefix = before ?? '';
    final String suffix = after ?? '';
    return '$prefix$this$suffix';
  }

  /// Returns this string wrapped with [before] prepended and [after] appended,
  /// or `null` if the string is empty.
  String? wrapWith({String? before, String? after}) {
    if (isEmpty) {
      return null;
    }
    return '${before ?? ""}$this${after ?? ""}';
  }

  /// Returns this string wrapped in single quotes: `'string'`.
  ///
  /// If the string is empty, returns `''` if [quoteEmpty] is `true`,
  /// otherwise returns an empty string.
  String wrapSingleQuotes({bool quoteEmpty = false}) {
    if (isEmpty) {
      return quoteEmpty ? "''" : '';
    }
    return "'$this'";
  }

  /// Returns this string wrapped in double quotes: `"string"`.
  ///
  /// If the string is empty, returns `""` if [quoteEmpty] is `true`,
  /// otherwise returns an empty string.
  String wrapDoubleQuotes({bool quoteEmpty = false}) {
    if (isEmpty) {
      return quoteEmpty ? '""' : '';
    }
    return '"$this"';
  }

  /// Returns this string wrapped in accented single quotes.
  ///
  /// If the string is empty, returns the empty quote pair if [quoteEmpty] is
  /// `true`, otherwise returns an empty string.
  String wrapSingleAccentedQuotes({bool quoteEmpty = false}) {
    if (isEmpty) {
      return quoteEmpty
          ? '$accentedQuoteOpening$accentedQuoteClosing'
          : '';
    }
    return '$accentedQuoteOpening$this$accentedQuoteClosing';
  }

  /// Returns this string wrapped in accented double quotes.
  ///
  /// If the string is empty, returns the empty quote pair if [quoteEmpty] is
  /// `true`, otherwise returns an empty string.
  String wrapDoubleAccentedQuotes({bool quoteEmpty = false}) {
    if (isEmpty) {
      return quoteEmpty
          ? '$accentedDoubleQuoteOpening$accentedDoubleQuoteClosing'
          : '';
    }
    return '$accentedDoubleQuoteOpening$this$accentedDoubleQuoteClosing';
  }

  /// Returns this string enclosed in parentheses, or `null` if empty.
  ///
  /// When [wrapEmpty] is `true`, returns `'()'` for empty strings.
  String? encloseInParentheses({bool wrapEmpty = false}) {
    if (isEmpty) {
      return wrapEmpty ? '()' : null;
    }
    return '($this)';
  }

  /// Returns a new string with a newline character inserted before each
  /// opening parenthesis.
  String insertNewLineBeforeBrackets() => replaceAll('(', '\n(');

  /// Returns the string truncated to [cutoff] graphemes with an ellipsis
  /// appended.
  ///
  /// Uses grapheme clusters for proper Unicode support, including emojis.
  /// Returns the original string if it's shorter than [cutoff].
  String truncateWithEllipsis(int? cutoff) {
    // Return original string if it's empty or cutoff is invalid
    if (isEmpty || cutoff == null || cutoff <= 0) {
      return this;
    }

    // Return original string if it's already shorter than the cutoff
    // Use grapheme length for proper emoji support
    if (characters.length <= cutoff) {
      return this;
    }

    // Simple truncation if not keeping words intact
    return '${substringSafe(0, cutoff)}$ellipsis';
  }

  /// Returns the string truncated to [cutoff] graphemes with an ellipsis,
  /// preserving whole words.
  ///
  /// Truncates at the last full word that fits within [cutoff]. If the first
  /// word is longer than the cutoff, falls back to simple truncation.
  ///
  /// Uses grapheme clusters for proper Unicode support, including emojis.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.truncateWithEllipsisPreserveWords(8); // Returns 'Hello…'
  /// 'Hello World'.truncateWithEllipsisPreserveWords(20); // Returns 'Hello World'
  /// 'Supercalifragilistic'.truncateWithEllipsisPreserveWords(5); // Returns 'Super…'
  /// ```
  String truncateWithEllipsisPreserveWords(int? cutoff) {
    final int charLength = characters.length;
    // Return original string if it's empty, cutoff is invalid, or it's already short enough.
    if (isEmpty || cutoff == null || cutoff <= 0 || charLength <= cutoff) {
      return this;
    }

    // Work in grapheme-cluster space to avoid splitting multi-codepoint emoji.
    final int searchLength = cutoff + 1 > charLength ? charLength : cutoff + 1;
    final String searchWindow = characters.take(searchLength).toString();
    final int lastSpaceIndex = searchWindow.lastIndexOf(' ');

    // If no space is found (e.g., a single long word), fall back to simple truncation
    // at the cutoff point using grapheme clusters.
    if (lastSpaceIndex == -1 || lastSpaceIndex == 0) {
      return '${characters.take(cutoff).toString()}$ellipsis';
    }

    // Truncate at the last space found and remove any trailing space before adding the ellipsis.
    return '${searchWindow.substringSafe(0, lastSpaceIndex).trimRight()}$ellipsis';
  }

  /// Returns a new string with all characters reversed. Handles Unicode
  /// correctly.
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

  /// Returns a new string with [newChar] inserted at the specified [position].
  ///
  /// Returns the original string if [position] is out of bounds.
  String insert(String newChar, int position) {
    // Validate the insertion position.
    if (position < 0 || position > length) return this;
    // Construct the new string.
    return substringSafe(0, position) + newChar + substringSafe(position);
  }

  /// Returns a new string with the last occurrence of [target] removed.
  String removeLastOccurrence(String target) {
    // Find the last index of the target.
    final int lastIndex = lastIndexOf(target);
    // If the target is not found, return the original string.
    if (lastIndex == -1) return this;
    // Reconstruct the string without the last occurrence.
    return substringSafe(0, lastIndex) + substringSafe(lastIndex + target.length);
  }

  /// Returns a new string with the outer matching bracket pair removed.
  String removeMatchingWrappingBrackets() =>
      // Use isBracketWrapped to check, then remove the outer characters.
      isBracketWrapped() ? substringSafe(1, length - 1) : this;

  /// Returns a new string with [char] removed from the beginning and/or end.
  ///
  /// When [trimFirst] is `true` (default), the string is trimmed before
  /// checking.
  String removeWrappingChar(String char, {bool trimFirst = true}) {
    // Method entry point.
    // FIX #1: Trim the string first if requested.
    String str = trimFirst ? trim() : this;
    // Check and remove the prefix if it exists.
    if (str.startsWith(char)) {
      // FIX #2: Remove the full length of the char, not just 1.
      str = str.substringSafe(char.length);
    }
    // Check and remove the suffix if it exists.
    if (str.endsWith(char)) {
      // FIX #2: Remove the full length of the char, not just 1.
      str = str.substringSafe(0, str.length - char.length);
    }
    // Return the processed string.
    return str;
  }

  /// Returns a new string with [start] removed from the beginning, or `null`
  /// if the result is empty.
  ///
  /// When [isCaseSensitive] is `false`, uses case-insensitive matching. When
  /// [trimFirst] is `true`, the string is trimmed before checking.
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
      return startsWith(start) ? substringSafe(start.length).nullIfEmpty() : this;
    }
    // Handle case-insensitive removal.
    return toLowerCase().startsWith(start.toLowerCase())
        ? substringSafe(start.length).nullIfEmpty()
        : this;
  }

  /// Returns a new string with [end] removed from the end, if it exists.
  String removeEnd(String end) =>
      // Check if the string ends with the target and remove it if so.
      endsWith(end) ? substringSafe(0, length - end.length) : this;

  /// Returns a new string with the first character removed.
  String removeFirstChar() =>
      // Return empty if too short, otherwise return the substringSafe from the second character.
      (length < 1) ? '' : substringSafe(1);

  /// Returns a new string with the last character removed.
  String removeLastChar() =>
      // Return empty if too short, otherwise return the substringSafe without the last character.
      (length < 1) ? '' : substringSafe(0, length - 1);

  /// Returns a new string with both the first and last characters removed.
  String removeFirstLastChar() =>
      // Return empty if too short, otherwise return the inner substringSafe.
      (length < 2) ? '' : substringSafe(1, length - 1);

  /// Returns a new string with apostrophe variants replaced by a standard
  /// single quote.
  String normalizeApostrophe() =>
      // Use a regex to find and replace apostrophe variants.
      replaceAll(_apostropheRegex, "'");

  /// Returns a new string with all non-letter characters removed.
  ///
  /// When [allowSpace] is `true`, space characters are preserved.
  String toAlphaOnly({bool allowSpace = false}) =>
      replaceAll(allowSpace ? _alphaOnlyWithSpaceRegex : _alphaOnlyRegex, '');

  /// Returns a new string with all non-alphanumeric characters removed.
  ///
  /// When [allowSpace] is `true`, space characters are preserved.
  String removeNonAlphaNumeric({bool allowSpace = false}) =>
      replaceAll(allowSpace ? _alphaNumericOnlyWithSpaceRegex : _alphaNumericOnlyRegex, '');

  /// Replaces all characters that are not digits (0-9) with the [replacement]
  /// string.
  ///
  /// Returns a new string with every non-digit character replaced by
  /// [replacement].
  ///
  /// For example, `'abc123def'.replaceNonNumbers(replacement: '-')` results
  /// in `'---123---'`.
  String replaceNonNumbers({String replacement = ''}) =>
      // The regex \D matches any non-digit character and replaces it.
      replaceAll(_nonDigitRegex, replacement);

  /// Returns a new string with all non-digit characters removed.
  String removeNonNumbers() =>
      // The regex \D matches any non-digit character.
      replaceAll(_nonDigitRegex, '');

  /// Returns a new string with regex special characters escaped.
  String escapeForRegex() =>
      // The regex finds any special regex character, and the callback prepends a backslash.
      replaceAllMapped(_regexSpecialCharsRegex, (Match m) => '\\${m.group(0) ?? ''}');

  /// Returns a new string with consecutive whitespace collapsed into a single
  /// space, or `null` if the result is empty.
  ///
  /// When [trim] is `true` (default), the result is also trimmed.
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

  /// Returns the result of collapsing consecutive whitespace, or `null` if
  /// empty. Alias for `removeConsecutiveSpaces`.
  ///
  /// When [trim] is `true` (default), the result is also trimmed.
  String? compressSpaces({bool trim = true}) =>
      // Defer to the main implementation.
      removeConsecutiveSpaces(trim: trim);

  /// Returns a list of segments split at capitalized letters (Unicode-aware).
  ///
  /// When [splitNumbers] is `true`, also splits before digits. When
  /// [splitBySpace] is `true`, further splits each segment by whitespace.
  /// Adjacent segments shorter than [minLength] are merged together.
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
      String currentBuffer = intermediateSplit[0];
      // Loop through the segments to check for necessary merges.
      for (int i = 1; i < intermediateSplit.length; i++) {
        final String nextPart = intermediateSplit[i];
        // If either the current or next part is too short, merge them.
        if (currentBuffer.length < minLength || nextPart.length < minLength) {
          currentBuffer = '$currentBuffer$nextPart';
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

  /// Returns the substringSafe before the first occurrence of [find].
  /// Returns the original string if [find] is not found.
  String getEverythingBefore(String find) {
    // Find the index of the target string.
    final int atIndex = indexOf(find);
    // Return the substringSafe before the index, or the original string if not found.
    return atIndex == -1 ? this : substringSafe(0, atIndex);
  }

  /// Returns the substringSafe after the first occurrence of [find].
  /// Returns the original string if [find] is not found.
  String getEverythingAfter(String find) {
    // Find the index of the target string.
    final int atIndex = indexOf(find);
    // Return the substringSafe after the index, or the original string if not found.
    return atIndex == -1 ? this : substringSafe(atIndex + find.length);
  }

  /// Returns the substringSafe after the last occurrence of [find].
  /// Returns the original string if [find] is not found.
  String getEverythingAfterLast(String find) {
    if (find.isEmpty) {
      return this;
    }

    // Find the last index of the target string.
    final int atIndex = lastIndexOf(find);
    // Return the substringSafe after the last index, or the original string if not found.
    return atIndex == -1 ? this : substringSafe(atIndex + find.length);
  }

  /// Safely gets a substring, preventing [RangeError].
  ///
  /// Uses grapheme clusters (user-perceived characters) for proper Unicode
  /// support, including emojis and other multi-code-unit characters.
  ///
  /// [start] is the inclusive start index in grapheme clusters.
  /// [end] is the optional exclusive end index in grapheme clusters. When
  /// omitted, returns from [start] to the end of the string.
  ///
  /// Returns an empty string if [start] is out of bounds or parameters are
  /// invalid.
  ///
  /// **Note**: Indices refer to grapheme clusters, not code units. For example,
  /// '👨‍👩‍👧‍👦' (family emoji) counts as 1 grapheme, not 7 code units.
  ///
  /// **Example:**
  /// ```dart
  /// '🙂hello'.substringSafe(0, 1); // '🙂' (not broken emoji)
  /// '👨‍👩‍👧‍👦abc'.substringSafe(1); // 'abc'
  /// 'hello'.substringSafe(1, 3); // 'el'
  /// ```
  String substringSafe(int start, [int? end]) {
    final Characters chars = characters;
    final int charLength = chars.length;

    // Validate the start index.
    if (start < 0 || start > charLength) return '';
    // If an end index is provided, validate it.
    if (end != null) {
      // Ensure end is not before start.
      if (end < start) return '';
      // Clamp the end index to the character length.
      end = end > charLength ? charLength : end;
    }
    // Return the substring using grapheme-aware getRange.
    return chars.getRange(start, end ?? charLength).string;
  }

  /// Get the last [n] graphemes (user-perceived characters) of a string.
  ///
  /// Uses grapheme clusters for proper Unicode support, including emojis.
  /// Returns the full string if its length is less than [n].
  String lastChars(int n) {
    // Handle invalid length.
    if (n <= 0) return '';
    final int charLength = characters.length;
    // If requested length is greater than or equal to string length, return the whole string.
    if (n >= charLength) return this;
    // Return the last n characters.
    return substringSafe(charLength - n);
  }

  /// Returns this string split into a list of words, or `null` if empty.
  ///
  /// Uses space as the delimiter and filters out empty words.
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

  /// Returns `true` if this string contains only Latin alphabet characters
  /// (a-z, A-Z).
  bool isLatin() =>
      // Use a regular expression to match only alphabetic characters from start to end.
      _latinRegex.hasMatch(this);

  /// Returns `true` if this string starts and ends with a matching bracket
  /// pair: parentheses, square brackets, curly braces, or angle brackets.
  bool isBracketWrapped() {
    // A wrapped string must have at least 2 characters.
    if (length < 2) return false;
    // Check for each pair of matching brackets.
    return (startsWith('(') && endsWith(')')) ||
        (startsWith('[') && endsWith(']')) ||
        (startsWith('{') && endsWith('}')) ||
        (startsWith('<') && endsWith('>'));
  }

  /// Returns `true` if this string equals [other], with options for
  /// case-insensitivity via [ignoreCase] and apostrophe normalization via
  /// [normalizeApostrophe].
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

  /// Returns `true` if this string contains [other] in a case-insensitive
  /// manner.
  ///
  /// An empty string is considered to be contained in any string. Returns
  /// `false` only when [other] is `null`.
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

  /// Returns the first character where this string and [other] differ, or an
  /// empty string if they are identical.
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
    }
    if (other.length > length) {
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

  /// Returns a new string with all invalid Unicode replacement characters
  /// removed.
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
    return switch (toLowerCase()) {
      'a' || 'e' || 'i' || 'o' || 'u' => true,
      _ => false,
    };
  }

  /// Returns true if this string contains any digit characters.
  bool hasAnyDigits() => contains(_anyDigitsRegex);

  /// Returns the last [len] grapheme clusters of this string.
  ///
  /// Uses the `characters` package to correctly handle multi-codepoint
  /// sequences such as emoji with skin-tone modifiers or ZWJ sequences.
  ///
  /// Returns the full string if [len] is greater than the grapheme length.
  String last(int len) {
    if (isEmpty || len <= 0) return '';
    final Characters chars = characters;
    final int charLength = chars.length;
    if (len >= charLength) return this;
    // skip() avoids allocating a full List<String> for large strings
    return chars.skip(charLength - len).string;
  }

  /// Returns a random character from this string.
  String getRandomChar() {
    if (isEmpty) return '';
    final int index = DateTime.now().microsecondsSinceEpoch % length;
    return this[index];
  }

  // cspell: ignore abcabcabc
  /// Returns this string repeated [count] times.
  ///
  /// Uses a `StringBuffer` for efficient concatenation. Returns an empty string
  /// if [count] is zero or negative, or if this string is empty.
  ///
  /// **Example:**
  /// ```dart
  /// 'abc'.repeat(3); // 'abcabcabc'
  /// 'x'.repeat(5); // 'xxxxx'
  /// 'test'.repeat(0); // ''
  /// 'test'.repeat(-1); // ''
  /// ```
  String repeat(int count) {
    if (isEmpty || count <= 0) return '';
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < count; i++) {
      buffer.write(this);
    }
    return buffer.toString();
  }

  /// Returns a new string with all occurrences of [pattern] removed.
  String removeAll(Pattern? pattern) {
    if (pattern == null) return this;
    return replaceAll(pattern, '');
  }

  /// Returns a new string with the last [n] characters replaced by
  /// [replacementChar].
  String replaceLastNCharacters(int n, String replacementChar) {
    if (n <= 0 || n > length) return this;
    return substringSafe(0, length - n) + replacementChar * n;
  }

  /// Returns a new string with hyphens and spaces replaced by non-breaking
  /// equivalents.
  @useResult
  String makeNonBreaking() => replaceAll('-', nonBreakingHyphen).replaceAll(' ', nonBreakingSpace);

  /// Returns a new string with single-character words removed, or `null` if the
  /// result is empty.
  ///
  /// When [trim] is `true` (default), the result is trimmed. When
  /// [removeMultipleSpaces] is `true` (default), consecutive spaces are
  /// collapsed.
  ///
  /// **Example:**
  /// ```dart
  /// 'a hello world'.removeSingleCharacterWords(); // 'hello world'
  /// 'I am 5 years old'.removeSingleCharacterWords(); // 'am years old'
  /// '你 好 test'.removeSingleCharacterWords(); // 'test' (Unicode aware)
  /// 'x y z'.removeSingleCharacterWords(); // null (all removed)
  /// ```
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

  /// Returns a new string with all line breaks replaced by [replacement].
  ///
  /// When [deduplicate] is `true` (default), consecutive runs of the
  /// replacement string are collapsed into a single occurrence.
  ///
  /// **Example:**
  /// ```dart
  /// 'a\n\nb'.replaceLineBreaks(' '); // 'a b' (deduplicated)
  /// 'a\n\nb'.replaceLineBreaks('+'); // 'a+b'
  /// 'a\n\nb'.replaceLineBreaks('.*'); // 'a.*b' (special chars handled)
  /// 'a\n\nb'.replaceLineBreaks(' ', deduplicate: false); // 'a  b'
  /// ```
  String replaceLineBreaks(String? replacement, {bool deduplicate = true}) {
    final String result = replaceAll(_lineBreakRegex, replacement ?? '');
    if (deduplicate && replacement != null && replacement.isNotEmpty) {
      final String pattern = '(?:${RegExp.escape(replacement)})+';
      final RegExp deduplicateRegex = RegExp(pattern);
      return result.replaceAll(deduplicateRegex, replacement);
    }
    return result;
  }

  /// Returns a new string with leading and trailing occurrences of [find]
  /// removed, or `null` if the result is empty.
  ///
  /// When [trim] is `true`, whitespace is also trimmed between removals.
  String? removeLeadingAndTrailing(String? find, {bool trim = false}) {
    if (isEmpty || find == null || find.isEmpty) return this;
    String value = trim ? this.trim() : this;
    while (value.startsWith(find)) {
      value = value.substringSafe(find.length);
      if (trim) value = value.trim();
    }
    while (value.endsWith(find)) {
      value = value.substringSafe(0, value.length - find.length);
      if (trim) value = value.trim();
    }
    return value.isEmpty ? null : value;
  }

  /// Returns the first word of this string, or `null` if empty.
  String? firstWord() {
    if (isEmpty) return null;
    return words()?.firstOrNull;
  }

  /// Returns the second word of this string, or `null` if fewer than two
  /// words.
  String? secondWord() {
    if (isEmpty) return null;
    final List<String>? wordList = words();
    if (wordList == null || wordList.length < 2) return null;
    return wordList[1];
  }

  /// Returns the number of non-overlapping occurrences of [find] in this
  /// string.
  ///
  /// **Example:**
  /// ```dart
  /// 'hello'.count('l'); // 2
  /// 'aaa'.count('aa'); // 1 (non-overlapping)
  /// 'test'.count('x'); // 0
  /// 'hello'.count(''); // 0
  /// ```
  int count(String find) {
    if (find.isEmpty) return 0;
    return split(find).length - 1;
  }

  /// Extracts only ASCII letter characters (A-Z, a-z) from this string.
  ///
  /// Removes all characters that are not ASCII letters using a regex replacement.
  /// Note: This is ASCII-only; Unicode letters like 'é' or '你' are removed.
  ///
  /// **Returns:**
  /// A new string containing only ASCII letters, or empty string if none found.
  ///
  /// **Example:**
  /// ```dart
  /// 'Hello123World!'.lettersOnly(); // 'HelloWorld'
  /// 'abc-def'.lettersOnly(); // 'abcdef'
  /// '123'.lettersOnly(); // ''
  /// 'café'.lettersOnly(); // 'caf' (é removed)
  /// ```
  String lettersOnly() {
    if (isEmpty) return '';
    return replaceAll(_alphaOnlyRegex, '');
  }

  // cspell: ignore elloorld
  /// Extracts only ASCII lowercase letter characters (a-z) from this string.
  ///
  /// Removes all characters that are not lowercase ASCII letters using a regex.
  /// Uppercase letters and Unicode characters are removed.
  ///
  /// **Returns:**
  /// A new string containing only lowercase ASCII letters, or empty if none found.
  ///
  /// **Example:**
  /// ```dart
  /// 'Hello123World!'.lowerCaseLettersOnly(); // 'elloorld'
  /// 'ABC-def'.lowerCaseLettersOnly(); // 'def'
  /// '123'.lowerCaseLettersOnly(); // ''
  /// ```
  String lowerCaseLettersOnly() {
    if (isEmpty) return '';
    return replaceAll(RegExp(r'[^a-z]'), '');
  }

  /// Returns the first [limit] lines of this string.
  String firstLines(int limit) {
    if (isEmpty || limit <= 0) return '';
    final List<String> lines = split(newLine);
    return lines.take(limit).join(newLine);
  }

  /// Returns a new string with each line trimmed and empty lines removed.
  String trimLines() => split(
    newLine,
  ).map((String line) => line.trim()).where((String line) => line.isNotEmpty).join(newLine);

  /// Returns a new string with [insertText] prepended to every line.
  ///
  /// When [prefixEmptyStrings] is `true`, empty strings also receive the
  /// prefix.
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

  /// Returns the index of the second occurrence of [char], or `-1` if not
  /// found.
  int secondIndex(String char) {
    if (char.isEmpty || isEmpty) return -1;
    final int firstIdx = indexOf(char);
    if (firstIdx == -1) return -1;
    return indexOf(char, firstIdx + 1);
  }

  /// Extracts all text within curly braces from this string.
  ///
  /// Uses a non-greedy regex (\{.+?\}) to match multiple brace-enclosed groups
  /// in the order they appear. Adjacent groups like `{a}{b}` are correctly separated.
  ///
  /// Limitation: Does not handle nested braces. For `{a{b}c}`, only `{a{b}` may match.
  ///
  /// **Returns:**
  /// A list of matched strings (including braces), or null if no matches found.
  /// The list preserves the order of matches in the original string.
  ///
  /// **Example:**
  /// ```dart
  /// '{start} middle {end}'.extractCurlyBraces(); // ['{start}', '{end}']
  /// '{a}{b}{c}'.extractCurlyBraces(); // ['{a}', '{b}', '{c}']
  /// '{你好}'.extractCurlyBraces(); // ['{你好}'] (Unicode supported)
  /// 'no braces'.extractCurlyBraces(); // null
  /// ```
  List<String>? extractCurlyBraces() {
    final List<String> matches = _curlyBracesRegex
        .allMatches(this)
        .map((Match m) => m[0])
        .whereType<String>()
        .toList();
    return matches.isEmpty ? null : matches;
  }

  /// Returns this string with [value] appended, or an empty string if this
  /// string is empty.
  String appendNotEmpty(String value) => isEmpty ? '' : this + value;

  /// Returns this string with [value] prepended, or this string unchanged if
  /// empty.
  String prefixNotEmpty(String? value) {
    if (isEmpty || value == null || value.isEmpty) return this;
    return value + this;
  }

  /// Returns the appropriate indefinite article (`'a'` or `'an'`) for this
  /// word, or an empty string if input is empty.
  ///
  /// Uses English grammar heuristics for silent 'h', "you"-sound words,
  /// and vowel/consonant detection.
  ///
  /// **Example:**
  /// ```dart
  /// 'apple'.grammarArticle(); // 'an'
  /// 'hour'.grammarArticle(); // 'an' (silent h)
  /// 'user'.grammarArticle(); // 'a' (you-sound)
  /// 'university'.grammarArticle(); // 'a'
  /// 'one-time'.grammarArticle(); // 'a'
  /// 'elephant'.grammarArticle(); // 'an'
  /// ```
  String grammarArticle() {
    if (isEmpty) return '';
    final String word = trim();
    if (word.isEmpty) return '';
    final String lower = word.toLowerCase();

    if (_silentHPrefixes.any(lower.startsWith)) return 'an';
    if (_youSoundPrefixes.any(lower.startsWith)) return 'a';
    if (lower.startsWith(_wunSoundPrefix)) return 'a';

    return switch (lower[0]) {
      'a' || 'e' || 'i' || 'o' || 'u' => 'an',
      _ => 'a',
    };
  }

  /// Returns the possessive form of this string (e.g., "John's", "boss'").
  ///
  /// When [isLocaleUS] is `true` (default), words ending in 's' get only an
  /// apostrophe ("boss'"). When `false`, they get apostrophe-s ("boss's").
  ///
  /// **Example:**
  /// ```dart
  /// 'John'.possess(); // "John's"
  /// 'boss'.possess(); // "boss'" (US style)
  /// 'boss'.possess(isLocaleUS: false); // "boss's" (non-US)
  /// '  James  '.possess(); // "James'" (trimmed)
  /// ```
  String possess({bool isLocaleUS = true}) {
    if (isEmpty) return this;
    final String base = trim();
    if (base.isEmpty) return base;
    final String last = base.lastChars(1).toLowerCase();
    if (last == 's') {
      return isLocaleUS ? "$base'" : "$base's";
    }
    return "$base's";
  }

  /// Returns the plural form of this string based on [count].
  ///
  /// When [simple] is `true`, just appends 's'. Otherwise, applies English
  /// pluralization rules (e.g., -es, -ies).
  String pluralize(num? count, {bool simple = false}) {
    if (isEmpty || count == 1) return this;
    if (simple) return '${this}s';

    final String lastChar = lastChars(1);
    switch (lastChar) {
      case 's':
      case 'x':
      case 'z':
        return '${this}es';
      case 'y':
        if (length > 2 && this[length - 2].isVowel()) return '${this}s';
        return '${substringSafe(0, length - 1)}ies';
    }

    final String lastTwo = lastChars(2);
    if (lastTwo == 'sh' || lastTwo == 'ch') return '${this}es';
    return '${this}s';
  }

  /// Returns an obscured version of this string using [char] repeated, or
  /// `null` if empty.
  ///
  /// The output length varies by ±[obscureLength] characters using a
  /// time-based jitter to prevent guessing the original string length.
  ///
  /// **Example:**
  /// ```dart
  /// 'password'.obscureText(); // '••••••••••' (length varies: 5-11 chars)
  /// 'secret'.obscureText(char: '*'); // '******' (length varies)
  /// ''.obscureText(); // null
  /// ```
  String? obscureText({String char = '•', int obscureLength = 3}) {
    if (isEmpty) return null;
    final int seed = DateTime.now().microsecondsSinceEpoch;
    final int extraLength = (seed % (2 * obscureLength + 1)) - obscureLength;
    final int finalLength = length + extraLength;
    return char * (finalLength > 0 ? finalLength : 1);
  }

  /// Returns a truncated version of this string with ellipsis, keeping the
  /// first and last [minLength] characters.
  String trimWithEllipsis({int minLength = 5}) {
    if (length < minLength) return ellipsis;
    if (length < (minLength * 2) + 2) {
      return substringSafe(0, minLength) + ellipsis;
    }
    return substringSafe(0, minLength) + ellipsis + substringSafe(length - minLength);
  }

  /// Returns this multiline string collapsed into a single line, truncated to
  /// [cropLength] characters.
  ///
  /// When [appendEllipsis] is `true` (default), an ellipsis is appended if
  /// truncated.
  String collapseMultilineString({required int cropLength, bool appendEllipsis = true}) {
    if (isEmpty) return this;
    final String collapsed = replaceAll(newLine, ' ').replaceAll('  ', ' ');
    if (collapsed.length <= cropLength) return collapsed.trim();

    String cropped = collapsed.substringSafe(0, cropLength + 1);
    while (cropped.isNotEmpty && !cropped.endsWithAny(commonWordEndings)) {
      cropped = cropped.substringSafe(0, cropped.length - 1);
    }
    if (cropped.isNotEmpty) {
      cropped = cropped.substringSafe(0, cropped.length - 1).trim();
    }
    return appendEllipsis ? cropped + ellipsis : cropped;
  }
}
