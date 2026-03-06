/// Rich parser error (line/column, context) — roadmap #647.
library;

/// Parser error with position and snippet.
class ParserError {
  const ParserError(String message, {int? line, int? column, String? snippet})
    : _message = message,
      _line = line,
      _column = column,
      _snippet = snippet;
  final String _message;

  String get message => _message;
  final int? _line;

  int? get line => _line;
  final int? _column;

  int? get column => _column;
  final String? _snippet;

  String? get snippet => _snippet;

  @override
  String toString() {
    if (_line != null && _column != null) return 'Line $_line, column $_column: $_message';
    return _message;
  }
}
