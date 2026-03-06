/// CSV/TSV dialect detector (roadmap #435).
library;

/// Detected dialect: delimiter, hasHeader.
class CsvDialectUtils {
  const CsvDialectUtils({required String delimiter, required bool hasHeader})
    : _delimiter = delimiter,
      _hasHeader = hasHeader;
  final String _delimiter;

  String get delimiter => _delimiter;
  final bool _hasHeader;

  bool get hasHeader => _hasHeader;

  @override
  String toString() => 'CsvDialectUtils(delimiter: $_delimiter, hasHeader: $_hasHeader)';
}

/// Heuristic: count tabs vs commas in first line; if tabs win, delimiter is tab.
CsvDialectUtils detectCsvDialect(String sample) {
  final String first = sample.split('\n').first;
  final int commas = ','.allMatches(first).length;
  final int tabs = '\t'.allMatches(first).length;
  final String delimiter = tabs >= commas ? '\t' : ',';
  return CsvDialectUtils(delimiter: delimiter, hasHeader: true);
}
