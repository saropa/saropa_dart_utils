/// Rich parser error (line/column, context) — roadmap #647.
library;

/// Parser error with position and snippet.
class ParserErrorUtils {
  /// Creates a parser error with a human-readable [message] and optional
  /// position ([line], [column]) and source [snippet].
  /// Audited: 2026-06-12 11:26 EDT
  const ParserErrorUtils(String message, {int? line, int? column, String? snippet})
    : _message = message,
      _line = line,
      _column = column,
      _snippet = snippet;
  final String _message;

  /// The human-readable description of what went wrong.
  /// Audited: 2026-06-12 11:26 EDT
  String get message => _message;
  final int? _line;

  /// The 1-based line where the error occurred, or `null` if unknown.
  /// Audited: 2026-06-12 11:26 EDT
  int? get line => _line;
  final int? _column;

  /// The 1-based column where the error occurred, or `null` if unknown.
  /// Audited: 2026-06-12 11:26 EDT
  int? get column => _column;
  final String? _snippet;

  /// The offending source excerpt, or `null` if none was captured.
  /// Audited: 2026-06-12 11:26 EDT
  String? get snippet => _snippet;

  @override
  String toString() {
    if (_line != null && _column != null) return 'Line $_line, column $_column: $_message';
    return _message;
  }
}
