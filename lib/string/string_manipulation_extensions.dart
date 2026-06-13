import 'package:characters/characters.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

final RegExp _apostropheRegex = RegExp('[\u2018\u2019]');

final RegExp _alphaOnlyRegex = RegExp('[^A-Za-z]');

final RegExp _lowerCaseOnlyRegex = RegExp(r'[^a-z]');

final RegExp _alphaOnlyWithSpaceRegex = RegExp('[^A-Za-z ]');

final RegExp _alphaNumericOnlyRegex = RegExp('[^A-Za-z0-9]');

final RegExp _alphaNumericOnlyWithSpaceRegex = RegExp('[^A-Za-z0-9 ]');

final RegExp _nonDigitRegex = RegExp(r'\D');

final RegExp _lineBreakRegex = RegExp('\n');

/// Extensions on [String] for character manipulation, removal, and cleaning.
extension StringManipulationExtensions on String {
  /// Returns a new string with [newChar] inserted at the specified [position].
  ///
  /// Returns the original string if [position] is out of bounds.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String insert(String newChar, int position) {
    if (position < 0 || position > length) {
      return this;
    }

    return substringSafe(0, position) + newChar + substringSafe(position);
  }

  /// Returns a new string with the last occurrence of [target] removed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeLastOccurrence(String target) {
    final int lastIndex = lastIndexOf(target);
    if (lastIndex == -1) {
      return this;
    }

    return substringSafe(0, lastIndex) + substringSafe(lastIndex + target.length);
  }

  /// Returns a new string with the outer matching bracket pair removed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeMatchingWrappingBrackets() {
    if (!isBracketWrapped()) return this;
    // Slice by grapheme count, not code-unit `length`: `substringSafe` is
    // grapheme-indexed, so a code-unit length over astral content removed the
    // wrong span (e.g. '(😀)' kept the trailing bracket).
    final int graphemeCount = characters.length;
    return substringSafe(1, graphemeCount - 1);
  }

  /// Returns `true` if this string starts and ends with a matching bracket
  /// pair: parentheses, square brackets, curly braces, or angle brackets.
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
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
  ///
  /// Suffix matching is UTF-16 code-unit based (via [String.endsWith]), so the
  /// cut point `length - end.length` is a guaranteed-valid code-unit boundary.
  /// Uses plain [String.substring] (not the grapheme-aware `substringSafe`)
  /// because the latter would reinterpret that code-unit index as a grapheme
  /// index, refusing to split a base+combining-mark cluster and leaving the
  /// suffix un-stripped. Code-unit slicing keeps the contract consistent: a
  /// bare combining mark passed as [end] is stripped, matching `endsWith`.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeEnd(String end) => endsWith(end) ? substring(0, length - end.length) : this;

  /// Removes [find] from the end of this string, tolerating a null/empty
  /// [find], and signals "no source to strip from" with `null`.
  ///
  /// The nullable-aware companion to [removeEnd]. The three-way result lets a
  /// caller distinguish "stripped to nothing" (`''`) from "there was no source
  /// string to strip" (`null`) — a distinction a plain `String removeEnd`
  /// cannot express. Branch semantics:
  ///
  /// - When [find] is `null` or empty, there is nothing to strip: returns this
  ///   string unchanged (including when this string is itself empty).
  /// - When this string is empty AND [find] is a real, non-empty suffix,
  ///   returns `null` — an empty source cannot carry the requested suffix, so
  ///   `null` (rather than `''`) marks the "no source" case distinctly. This
  ///   asymmetry is deliberate; do not "normalize" it to `''`.
  /// - Otherwise delegates to [removeEnd], so only ONE trailing occurrence is
  ///   removed and a whole-string match strips to `''` (NOT `null`).
  ///
  /// Matching is case-sensitive UTF-16 code-unit suffix matching (inherited
  /// from [removeEnd]/[String.endsWith]), NOT grapheme-aware: stripping a
  /// combining mark or a fragment of a surrogate pair can split a cluster.
  ///
  /// Example:
  /// ```dart
  /// 'hello.txt'.removeEndNullable('.txt'); // 'hello'
  /// 'hello'.removeEndNullable(null);       // 'hello' (nothing to strip)
  /// 'abc'.removeEndNullable('abc');        // ''     (stripped to nothing)
  /// ''.removeEndNullable('x');             // null   (no source to strip)
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String? removeEndNullable(String? find) => find == null || find.isEmpty
      ? this
      : isEmpty
      ? null
      : removeEnd(find);

  /// Returns a new string with the first character removed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeFirstChar() => (length < 1) ? '' : substringSafe(1);

  /// Returns a new string with the last grapheme cluster removed.
  ///
  /// Counts by grapheme cluster (via [substringSafe]), so a trailing emoji or
  /// base+combining-mark sequence is removed whole and never split into an
  /// orphaned surrogate or a stranded mark. Empty in, empty out.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeLastChar() {
    // Grapheme length, not String.length: substringSafe is grapheme-indexed, so
    // passing a code-unit count would miscount whenever the trailing grapheme
    // spans multiple code units.
    final int graphemeCount = characters.length;
    return graphemeCount < 1 ? '' : substringSafe(0, graphemeCount - 1);
  }

  /// Returns a new string with the last [count] grapheme clusters removed.
  ///
  /// Bounds-safe: a [count] of zero or negative is a no-op (returns this
  /// string unchanged), and a [count] greater than or equal to the grapheme
  /// length returns an empty string rather than throwing.
  ///
  /// Counts by grapheme cluster (user-perceived characters), not UTF-16 code
  /// units, so a trailing emoji or base+combining-mark sequence is removed as a
  /// single unit and never split into an orphaned surrogate or a stranded mark.
  ///
  /// **Example:**
  /// ```dart
  /// 'Hello'.removeLastChars(2); // 'Hel'
  /// 'a😀'.removeLastChars(1);   // 'a'   (whole emoji removed, not split)
  /// 'Hi'.removeLastChars(5);    // ''
  /// 'Hi'.removeLastChars(0);    // 'Hi'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeLastChars(int count) {
    if (count <= 0) {
      return this;
    }

    // Count user-perceived characters, not UTF-16 code units: the slice below
    // is grapheme-indexed (substringSafe), so bounding by String.length would
    // mix code-unit arithmetic with grapheme indexing and miscount whenever a
    // trailing grapheme spans multiple code units (emoji, combining marks).
    final int graphemeCount = characters.length;
    if (graphemeCount <= count) {
      return '';
    }

    return substringSafe(0, graphemeCount - count);
  }

  /// Returns a new string with both the first and last characters removed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeFirstLastChar() {
    // Count and slice by grapheme (like removeLastChars above), not code-unit
    // `length`: feeding a code-unit length into the grapheme-indexed
    // substringSafe removed the wrong span for astral content
    // (e.g. 'a😀b'.removeFirstLastChar() returned '😀b' instead of '😀').
    final int graphemeCount = characters.length;
    return graphemeCount < 2 ? '' : substringSafe(1, graphemeCount - 1);
  }

  /// Returns a new string with apostrophe variants replaced by a standard
  /// single quote.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String normalizeApostrophe() => replaceAll(_apostropheRegex, "'");

  /// Returns a new string with all non-letter characters removed.
  ///
  /// When [allowSpace] is `true`, space characters are preserved.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String toAlphaOnly({bool allowSpace = false}) =>
      replaceAll(allowSpace ? _alphaOnlyWithSpaceRegex : _alphaOnlyRegex, '');

  /// Returns a new string with all non-alphanumeric characters removed.
  ///
  /// When [allowSpace] is `true`, space characters are preserved.
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String replaceNonNumbers({String replacement = ''}) => replaceAll(_nonDigitRegex, replacement);

  /// Returns a new string with all non-digit characters removed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeNonNumbers() => replaceAll(_nonDigitRegex, '');

  // escapeForRegex intentionally lives only on StringRegexExtensions
  // (string_regex_extensions.dart): that copy has the canonical regex, full
  // dartdoc, an empty-string guard, and tests. The duplicate here (with its own
  // _regexSpecialCharsRegex) collided with it (ambiguous_extension_member_access
  // for barrel consumers) and was pure duplication. Removed under BUG-003 — do
  // not re-add a same-named String method here.

  /// Returns a new string with all occurrences of [pattern] removed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeAll(Pattern? pattern) {
    if (pattern == null) {
      return this;
    }

    return replaceAll(pattern, '');
  }

  /// Returns a new string with the last [n] characters replaced by
  /// [replacementChar].
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String replaceLastNCharacters(int n, String replacementChar) {
    if (n <= 0 || n > length) {
      return this;
    }

    return substringSafe(0, length - n) + replacementChar * n;
  }

  /// Returns a new string with hyphens and spaces replaced by non-breaking
  /// equivalents.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String makeNonBreaking() => replaceAll(
    '-',
    StringExtensions.nonBreakingHyphen,
  ).replaceAll(' ', StringExtensions.nonBreakingSpace);

  /// Returns a new string with all line breaks replaced by [replacement].
  ///
  /// When [deduplicate] is `true` (default), consecutive runs of the
  /// replacement string are collapsed into a single occurrence.
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String getEverythingBefore(String find) {
    final int atIndex = indexOf(find);

    return atIndex == -1 ? this : substringSafe(0, atIndex);
  }

  /// Returns the substringSafe after the first occurrence of [find].
  /// Returns the original string if [find] is not found.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String getEverythingAfter(String find) {
    final int atIndex = indexOf(find);

    return atIndex == -1 ? this : substringSafe(atIndex + find.length);
  }

  /// Returns the substringSafe after the last occurrence of [find].
  /// Returns the original string if [find] is not found.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String getEverythingAfterLast(String find) {
    if (find.isEmpty) {
      return this;
    }

    final int atIndex = lastIndexOf(find);

    return atIndex == -1 ? this : substringSafe(atIndex + find.length);
  }

  /// Returns a random character from this string.
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String appendNotEmpty(String value) => isEmpty ? '' : this + value;

  /// Returns this string with [value] prepended, or this string unchanged if
  /// empty.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String prefixNotEmpty(String? value) {
    if (isEmpty || value == null || value.isEmpty) {
      return this;
    }

    return value + this;
  }
}
