/// Extensions for presentation, like adding quotes, truncating text, and formatting.
extension StringFormattingAndWrappingExtensions on String {
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
  String wrapSingleQuotes() => "'$this'";

  /// Wraps the string in double quotes: `"string"`.
  String wrapDoubleQuotes() => '"$this"';

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
