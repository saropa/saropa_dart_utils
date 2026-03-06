import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

final RegExp _apostropheRegex = RegExp('[\u2018\u2019]');

final RegExp _alphaOnlyRegex = RegExp('[^A-Za-z]');

final RegExp _lowerCaseOnlyRegex = RegExp(r'[^a-z]');

final RegExp _alphaOnlyWithSpaceRegex = RegExp('[^A-Za-z ]');

final RegExp _alphaNumericOnlyRegex = RegExp('[^A-Za-z0-9]');

final RegExp _alphaNumericOnlyWithSpaceRegex = RegExp('[^A-Za-z0-9 ]');

final RegExp _nonDigitRegex = RegExp(r'\D');

final RegExp _regexSpecialCharsRegex = RegExp(r'[.*+?^${}()|[\]\\]');

final RegExp _lineBreakRegex = RegExp('\n');

/// Extensions on [String] for character manipulation, removal, and cleaning.
extension StringManipulationExtensions on String {
  /// Returns a new string with [newChar] inserted at the specified [position].
  ///
  /// Returns the original string if [position] is out of bounds.
  @useResult
  String insert(String newChar, int position) {
    if (position < 0 || position > length) {
      return this;
    }

    return substringSafe(0, position) + newChar + substringSafe(position);
  }

  /// Returns a new string with the last occurrence of [target] removed.
  @useResult
  String removeLastOccurrence(String target) {
    final int lastIndex = lastIndexOf(target);
    if (lastIndex == -1) {
      return this;
    }

    return substringSafe(0, lastIndex) + substringSafe(lastIndex + target.length);
  }

  /// Returns a new string with the outer matching bracket pair removed.
  @useResult
  String removeMatchingWrappingBrackets() =>
      isBracketWrapped() ? substringSafe(1, length - 1) : this;

  /// Returns `true` if this string starts and ends with a matching bracket
  /// pair: parentheses, square brackets, curly braces, or angle brackets.
  @useResult
  bool isBracketWrapped() {
    if (length < 2) {
      return false;
    }

    return (startsWith('(') && endsWith(')')) ||
        (startsWith('[') && endsWith(']')) ||
        (startsWith('{') && endsWith('}')) ||
        (startsWith('<') && endsWith('>'));
  }

  /// Returns a new string with [char] removed from the beginning and/or end.
  ///
  /// When [trimFirst] is `true` (default), the string is trimmed before
  /// checking.
  @useResult
  String removeWrappingChar(String char, {bool trimFirst = true}) {
    String str = trimFirst ? trim() : this;
    if (str.startsWith(char)) {
      str = str.substringSafe(char.length);
    }

    if (str.endsWith(char)) {
      str = str.substringSafe(0, str.length - char.length);
    }

    return str;
  }

  /// Returns a new string with [start] removed from the beginning, or `null`
  /// if the result is empty.
  ///
  /// When [isCaseSensitive] is `false`, uses case-insensitive matching. When
  /// [trimFirst] is `true`, the string is trimmed before checking.
  @useResult
  String? removeStart(
    String? start, {
    bool isCaseSensitive = true,
    bool trimFirst = false,
  }) {
    if (trimFirst) {
      return trim().removeStart(start, isCaseSensitive: isCaseSensitive);
    }

    if (start == null || start.isEmpty) {
      return this;
    }

    if (isCaseSensitive) {
      return startsWith(start) ? substringSafe(start.length).nullIfEmpty() : this;
    }

    return toLowerCase().startsWith(start.toLowerCase())
        ? substringSafe(start.length).nullIfEmpty()
        : this;
  }

  /// Returns a new string with [end] removed from the end, if it exists.
  @useResult
  String removeEnd(String end) => endsWith(end) ? substringSafe(0, length - end.length) : this;

  /// Returns a new string with the first character removed.
  @useResult
  String removeFirstChar() => (length < 1) ? '' : substringSafe(1);

  /// Returns a new string with the last character removed.
  @useResult
  String removeLastChar() => (length < 1) ? '' : substringSafe(0, length - 1);

  /// Returns a new string with both the first and last characters removed.
  @useResult
  String removeFirstLastChar() => (length < 2) ? '' : substringSafe(1, length - 1);

  /// Returns a new string with apostrophe variants replaced by a standard
  /// single quote.
  @useResult
  String normalizeApostrophe() => replaceAll(_apostropheRegex, "'");

  /// Returns a new string with all non-letter characters removed.
  ///
  /// When [allowSpace] is `true`, space characters are preserved.
  @useResult
  String toAlphaOnly({bool allowSpace = false}) =>
      replaceAll(allowSpace ? _alphaOnlyWithSpaceRegex : _alphaOnlyRegex, '');

  /// Returns a new string with all non-alphanumeric characters removed.
  ///
  /// When [allowSpace] is `true`, space characters are preserved.
  @useResult
  String removeNonAlphaNumeric({bool allowSpace = false}) => replaceAll(
    allowSpace ? _alphaNumericOnlyWithSpaceRegex : _alphaNumericOnlyRegex,
    '',
  );

  /// Replaces all characters that are not digits (0-9) with the [replacement]
  /// string.
  ///
  /// For example, `'abc123def'.replaceNonNumbers(replacement: '-')` results
  /// in `'---123---'`.
  @useResult
  String replaceNonNumbers({String replacement = ''}) => replaceAll(_nonDigitRegex, replacement);

  /// Returns a new string with all non-digit characters removed.
  @useResult
  String removeNonNumbers() => replaceAll(_nonDigitRegex, '');

  /// Returns a new string with regex special characters escaped.
  ///
  /// Backslashes and other regex metacharacters are escaped so the string
  /// can be used as a literal pattern.
  @useResult
  String escapeForRegex() => replaceAllMapped(
    _regexSpecialCharsRegex,
    (Match m) => '\\${m.group(0) ?? ''}',
  );

  /// Returns a new string with all occurrences of [pattern] removed.
  @useResult
  String removeAll(Pattern? pattern) {
    if (pattern == null) {
      return this;
    }

    return replaceAll(pattern, '');
  }

  /// Returns a new string with the last [n] characters replaced by
  /// [replacementChar].
  @useResult
  String replaceLastNCharacters(int n, String replacementChar) {
    if (n <= 0 || n > length) {
      return this;
    }

    return substringSafe(0, length - n) + replacementChar * n;
  }

  /// Returns a new string with hyphens and spaces replaced by non-breaking
  /// equivalents.
  @useResult
  String makeNonBreaking() => replaceAll(
    '-',
    StringExtensions.nonBreakingHyphen,
  ).replaceAll(' ', StringExtensions.nonBreakingSpace);

  /// Returns a new string with all line breaks replaced by [replacement].
  ///
  /// When [deduplicate] is `true` (default), consecutive runs of the
  /// replacement string are collapsed into a single occurrence.
  @useResult
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
  @useResult
  String? removeLeadingAndTrailing(String? find, {bool trim = false}) {
    if (isEmpty || find == null || find.isEmpty) {
      return this;
    }

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

  /// Extracts only ASCII letter characters (A-Z, a-z) from this string.
  ///
  /// Note: This is ASCII-only; Unicode letters like 'é' or '你' are removed.
  ///
  /// **Example:**
  /// ```dart
  /// 'Hello123World!'.lettersOnly(); // 'HelloWorld'
  /// 'abc-def'.lettersOnly(); // 'abcdef'
  /// '123'.lettersOnly(); // ''
  /// 'café'.lettersOnly(); // 'caf' (é removed)
  /// ```
  @useResult
  String lettersOnly() {
    if (isEmpty) {
      return '';
    }

    return replaceAll(_alphaOnlyRegex, '');
  }

  // cspell: ignore elloorld
  /// Extracts only ASCII lowercase letter characters (a-z) from this string.
  ///
  /// **Example:**
  /// ```dart
  /// 'Hello123World!'.lowerCaseLettersOnly(); // 'elloorld'
  /// 'ABC-def'.lowerCaseLettersOnly(); // 'def'
  /// '123'.lowerCaseLettersOnly(); // ''
  /// ```
  @useResult
  String lowerCaseLettersOnly() {
    if (isEmpty) {
      return '';
    }

    return replaceAll(_lowerCaseOnlyRegex, '');
  }

  /// Returns the substring before the first occurrence of [find].
  ///
  /// Returns the original string if [find] is not found.
  @useResult
  String getEverythingBefore(String find) {
    final int atIndex = indexOf(find);

    return atIndex == -1 ? this : substringSafe(0, atIndex);
  }

  /// Returns the substringSafe after the first occurrence of [find].
  /// Returns the original string if [find] is not found.
  @useResult
  String getEverythingAfter(String find) {
    final int atIndex = indexOf(find);

    return atIndex == -1 ? this : substringSafe(atIndex + find.length);
  }

  /// Returns the substringSafe after the last occurrence of [find].
  /// Returns the original string if [find] is not found.
  @useResult
  String getEverythingAfterLast(String find) {
    if (find.isEmpty) {
      return this;
    }

    final int atIndex = lastIndexOf(find);

    return atIndex == -1 ? this : substringSafe(atIndex + find.length);
  }

  /// Returns a random character from this string.
  @useResult
  String getRandomChar() {
    if (isEmpty) {
      return '';
    }

    final int index = DateTime.now().microsecondsSinceEpoch % length;

    return this[index];
  }

  // cspell: ignore abcabcabc
  /// Returns this string repeated [count] times.
  ///
  /// **Example:**
  /// ```dart
  /// 'abc'.repeat(3); // 'abcabcabc'
  /// 'x'.repeat(5); // 'xxxxx'
  /// 'test'.repeat(0); // ''
  /// ```
  @useResult
  String repeat(int count) {
    if (isEmpty || count <= 0) {
      return '';
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < count; i++) {
      buffer.write(this);
    }

    return buffer.toString();
  }

  /// Returns this string with [value] appended, or an empty string if this
  /// string is empty.
  @useResult
  String appendNotEmpty(String value) => isEmpty ? '' : this + value;

  /// Returns this string with [value] prepended, or this string unchanged if
  /// empty.
  @useResult
  String prefixNotEmpty(String? value) {
    if (isEmpty || value == null || value.isEmpty) {
      return this;
    }

    return value + this;
  }
}
