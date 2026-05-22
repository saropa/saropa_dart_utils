/// CSV/TSV dialect detector (roadmap #435).
library;

/// Detected dialect: delimiter, hasHeader.
class CsvDialectUtils {
  /// Creates a detected dialect with the field [delimiter] and whether the
  /// first row is a header ([hasHeader]).
  const CsvDialectUtils({required String delimiter, required bool hasHeader})
    : _delimiter = delimiter,
      _hasHeader = hasHeader;
  final String _delimiter;

  /// The detected field delimiter, e.g. `,` for CSV or `\t` for TSV.
  String get delimiter => _delimiter;
  final bool _hasHeader;

  /// Whether the first row was treated as a header row.
  bool get hasHeader => _hasHeader;

  @override
  String toString() => 'CsvDialectUtils(delimiter: $_delimiter, hasHeader: $_hasHeader)';
}

/// Detects the dialect of a CSV/TSV [sample] by inspecting its first line.
///
/// Counts tabs versus commas in the first line; if tabs are at least as common
/// as commas, the delimiter is tab, otherwise comma. The first row is always
/// reported as a header. An empty [sample] yields a comma delimiter.
///
/// Example:
/// ```dart
/// detectCsvDialect('a\tb\tc').delimiter; // '\t'
/// detectCsvDialect('a,b,c').delimiter; // ','
/// ```
CsvDialectUtils detectCsvDialect(String sample) {
  final String first = sample.split('\n').first;
  final int commas = ','.allMatches(first).length;
  final int tabs = '\t'.allMatches(first).length;
  final String delimiter = tabs >= commas ? '\t' : ',';
  return CsvDialectUtils(delimiter: delimiter, hasHeader: true);
}
