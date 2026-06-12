/// CSV writer with configurable dialect and RFC 4180 auto-quoting — roadmap
/// #622. The inverse of [parseCsvLine] in `csv_parse_utils.dart`.
library;

/// Encodes one row of [fields] as a single CSV line (no trailing newline).
///
/// A field is wrapped in double quotes when it contains the [delimiter], a
/// double quote, a CR, or an LF — exactly the characters that would otherwise
/// corrupt the row structure (a delimiter splits the field, a bare quote
/// confuses the parser, a CR/LF injects a phantom row). Inner quotes are
/// doubled per RFC 4180. Set [forceQuote] to quote every field unconditionally,
/// which some downstream consumers require.
///
/// Example:
/// ```dart
/// writeCsvLine(['a,b', 'c']); // '"a,b",c'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String writeCsvLine(List<String> fields, {String delimiter = ',', bool forceQuote = false}) =>
    fields.map((String f) => _encodeField(f, delimiter, forceQuote)).join(delimiter);

String _encodeField(String field, String delimiter, bool forceQuote) {
  final bool needsQuote =
      forceQuote ||
      field.contains(delimiter) ||
      field.contains('"') ||
      field.contains('\n') ||
      field.contains('\r');
  if (!needsQuote) return field;
  // Double every embedded quote so the parser reads "" as one literal quote.
  return '"${field.replaceAll('"', '""')}"';
}

/// Encodes [rows] as a full CSV document, joining lines with [eol] (default
/// CRLF, the RFC 4180 line terminator). Each row is encoded with [writeCsvLine]
/// using [delimiter] and [forceQuote]. Returns an empty string for no rows.
///
/// Example:
/// ```dart
/// writeCsv([['h1', 'h2'], ['1', '2']]); // 'h1,h2\r\n1,2'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String writeCsv(
  List<List<String>> rows, {
  String delimiter = ',',
  String eol = '\r\n',
  bool forceQuote = false,
}) => rows
    .map((List<String> r) => writeCsvLine(r, delimiter: delimiter, forceQuote: forceQuote))
    .join(eol);
