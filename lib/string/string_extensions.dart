import 'package:characters/characters.dart';

// Re-export split files for backward compatibility
export 'string_analysis_extensions.dart';
export 'string_manipulation_extensions.dart';
export 'string_text_extensions.dart';
import 'package:meta/meta.dart';

/// Extensions for presentation, like adding quotes, truncating text,
/// and formatting.
extension StringExtensions on String {
  static const String accentedQuoteOpening = '\u2018';
  static const String accentedQuoteClosing = '\u2019';
  static const String accentedDoubleQuoteOpening = '\u201C';
  static const String accentedDoubleQuoteClosing = '\u201D';
  static const String ellipsis = '\u2026';
  static const String doubleChevron = '\u00BB';
  static const String apostrophe = '\u2019';

  // https://www.compart.com/en/unicode/category/Pd
  // https://wikipedia.org/wiki/Hyphen
  static const String hyphen = '\u2010';

  /// Soft Hyphen character (U+00AD).
  /// Insert into strings to suggest word break points for automatic
  /// hyphenation by Flutter's text rendering engine.
  static const String softHyphen = '\u00ad';

  static const String newLine = '\n';
  static const String lineBreak = newLine;

  // https://blanktext.net/
  static const String blank = '\u3164';

  // cspell:disable
  /// 'This\u200Bis\u200Ba\u200Bsentence\u200Bwith\u200Bzero-width\u200Bspaces.
  // cspell:enable
  static const String zeroWidth = '\u200B';

  // ref https://stackoverflow.com/questions/64245554
  static const String nonBreakingSpace = '\u00A0';

  /// For not breaking words into newline at hyphen in Text.
  static const String nonBreakingHyphen = '\u2011';

  /// Bullet point character.
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

  /// Returns this string wrapped with [before] prepended and [after]
  /// appended.
  @useResult
  String wrap({String? before, String? after}) {
    final String prefix = before ?? '';
    final String suffix = after ?? '';

    return '$prefix$this$suffix';
  }

  /// Returns this string wrapped with [before] prepended and [after]
  /// appended, or `null` if the string is empty.
  @useResult
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
  @useResult
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
  @useResult
  String wrapDoubleQuotes({bool quoteEmpty = false}) {
    if (isEmpty) {
      return quoteEmpty ? '""' : '';
    }

    return '"$this"';
  }

  /// Returns this string wrapped in accented single quotes.
  ///
  /// If the string is empty, returns the empty quote pair if [quoteEmpty]
  /// is `true`, otherwise returns an empty string.
  @useResult
  String wrapSingleAccentedQuotes({bool quoteEmpty = false}) {
    if (isEmpty) {
      return quoteEmpty ? '$accentedQuoteOpening$accentedQuoteClosing' : '';
    }

    return '$accentedQuoteOpening$this$accentedQuoteClosing';
  }

  /// Returns this string wrapped in accented double quotes.
  ///
  /// If the string is empty, returns the empty quote pair if [quoteEmpty]
  /// is `true`, otherwise returns an empty string.
  @useResult
  String wrapDoubleAccentedQuotes({bool quoteEmpty = false}) {
    if (isEmpty) {
      return quoteEmpty ? '$accentedDoubleQuoteOpening$accentedDoubleQuoteClosing' : '';
    }

    return '$accentedDoubleQuoteOpening$this$accentedDoubleQuoteClosing';
  }

  /// Returns this string enclosed in parentheses, or `null` if empty.
  ///
  /// When [wrapEmpty] is `true`, returns `'()'` for empty strings.
  @useResult
  String? encloseInParentheses({bool wrapEmpty = false}) {
    if (isEmpty) {
      return wrapEmpty ? '()' : null;
    }

    return '($this)';
  }

  /// Returns a new string with a newline character inserted before each
  /// opening parenthesis.
  @useResult
  String insertNewLineBeforeBrackets() => replaceAll('(', '\n(');

  /// Returns the string truncated to [cutoff] graphemes with an ellipsis
  /// appended.
  ///
  /// Uses grapheme clusters for proper Unicode support, including emojis.
  /// Returns the original string if it's shorter than [cutoff].
  @useResult
  String truncateWithEllipsis(int? cutoff) {
    if (isEmpty || cutoff == null || cutoff <= 0) {
      return this;
    }

    if (characters.length <= cutoff) {
      return this;
    }

    return '${substringSafe(0, cutoff)}$ellipsis';
  }

  /// Returns the string truncated to [cutoff] graphemes with an ellipsis,
  /// preserving whole words.
  ///
  /// Truncates at the last full word that fits within [cutoff]. If the first
  /// word is longer than the cutoff, falls back to simple truncation.
  ///
  /// **Example:**
  /// ```dart
  /// 'Hello World'.truncateWithEllipsisPreserveWords(8); // 'Hello…'
  /// 'Hello World'.truncateWithEllipsisPreserveWords(20); // 'Hello World'
  /// ```
  @useResult
  String truncateWithEllipsisPreserveWords(int? cutoff) {
    final int charLength = characters.length;
    if (isEmpty || cutoff == null || cutoff <= 0 || charLength <= cutoff) {
      return this;
    }

    final int searchLength = cutoff + 1 > charLength ? charLength : cutoff + 1;
    final String searchWindow = characters.take(searchLength).toString();
    final int lastSpaceIndex = searchWindow.lastIndexOf(' ');

    if (lastSpaceIndex == -1 || lastSpaceIndex == 0) {
      return '${characters.take(cutoff).toString()}$ellipsis';
    }

    final String trimmed = searchWindow.substringSafe(0, lastSpaceIndex).trimRight();

    return '$trimmed$ellipsis';
  }

  /// Returns a new string with all characters reversed. Handles Unicode
  /// correctly.
  @useResult
  String get reversed => String.fromCharCodes(runes.toList().reversed);

  /// Returns `null` if the string is empty or contains only whitespace.
  ///
  /// - [trimFirst]: If true (default), the string is trimmed before the
  ///   check.
  @useResult
  String? nullIfEmpty({bool trimFirst = true}) {
    if (isEmpty) {
      return null;
    }

    if (trimFirst) {
      final String trimmed = trim();

      return trimmed.isEmpty ? null : trimmed;
    }

    return this;
  }

  /// Safely gets a substring, preventing [RangeError] (returns empty string
  /// for out-of-bounds indices). Prefer this over [String.substring] when
  /// indices may be invalid (e.g. user input or variable length).
  ///
  /// Uses grapheme clusters for proper Unicode support. [start] is the
  /// inclusive start index. [end] is the optional exclusive end index.
  ///
  /// **Example:**
  /// ```dart
  /// '🙂hello'.substringSafe(0, 1); // '🙂'
  /// 'hello'.substringSafe(1, 3); // 'el'
  /// ```
  @useResult
  String substringSafe(int start, [int? end]) {
    final Characters chars = characters;
    final int charLength = chars.length;

    if (start < 0 || start > charLength) {
      return '';
    }

    if (end != null && end < start) {
      return '';
    }

    final int clampedEnd = (end ?? charLength).clamp(start, charLength);

    return chars.getRange(start, clampedEnd).string;
  }

  /// Get the last [n] graphemes (user-perceived characters) of a string.
  ///
  /// Uses grapheme clusters for proper Unicode support, including emojis.
  /// Returns the full string if its length is less than [n].
  @useResult
  String lastChars(int n) {
    if (n <= 0) {
      return '';
    }

    final int charLength = characters.length;
    if (n >= charLength) {
      return this;
    }

    return substringSafe(charLength - n);
  }

  /// Returns the last [len] grapheme clusters of this string.
  ///
  /// Uses the `characters` package to correctly handle multi-codepoint
  /// sequences such as emoji with skin-tone modifiers or ZWJ sequences.
  ///
  /// Returns the full string if [len] is greater than the grapheme length.
  @useResult
  String last(int len) {
    if (isEmpty || len <= 0) {
      return '';
    }

    final Characters chars = characters;
    final int charLength = chars.length;
    if (len >= charLength) {
      return this;
    }

    return chars.skip(charLength - len).string;
  }
}
