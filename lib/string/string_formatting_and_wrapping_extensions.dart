/// Extensions for presentation, like adding quotes, truncating text, and formatting.
extension StringFormattingAndWrappingExtensions on String {
  static const String accentedQuoteOpening = '‘';
  static const String accentedQuoteClosing = '’';
  static const String accentedDoubleQuoteOpening = '“';
  static const String accentedDoubleQuoteClosing = '”';

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

  /// Truncates the string to [maxLength] and appends an ellipsis '…'.
  ///
  /// Returns the original string if it's shorter than [maxLength].
  String truncateWithEllipsis(int maxLength) =>
      maxLength <= 0 || length <= maxLength ? this : '${substring(0, maxLength)}…';
}


