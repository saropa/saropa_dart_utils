/// A single row that failed structural validation during [parseCsv], kept so
/// the import can continue and report every bad row at once instead of aborting
/// on the first one.
class CsvRowError {
  /// Records that [line] at 1-based [lineNumber] failed for [message].
  /// Audited: 2026-06-12 11:26 EDT
  const CsvRowError(this.lineNumber, this.line, this.message);

  /// 1-based line number in the original input (blank lines are counted, so
  /// this maps back to what the user sees in their file).
  final int lineNumber;

  /// The raw source line that failed.
  final String line;

  /// Human-readable reason the row was rejected.
  final String message;

  @override
  String toString() => 'CsvRowError(line $lineNumber: $message)';
}

/// The outcome of [parseCsv]: the successfully-parsed [rows] plus a per-row
/// [errors] list for the rows that failed validation.
class CsvParseResult {
  /// Wraps the good [rows] and the rejected-row [errors].
  /// Audited: 2026-06-12 11:26 EDT
  const CsvParseResult(this.rows, this.errors);

  /// Rows that parsed and passed validation, in source order. A rejected row is
  /// NOT included here — look it up in [errors] by line number.
  final List<List<String>> rows;

  /// One entry per rejected row, in source order.
  final List<CsvRowError> errors;

  /// `true` when at least one row was rejected.
  /// Audited: 2026-06-12 11:26 EDT
  bool get hasErrors => errors.isNotEmpty;
}

/// Parses a multi-line CSV [input], collecting per-row errors instead of
/// throwing on the first bad row — the shape a user-facing import needs so it
/// can surface every problem at once.
///
/// Rows are split on `\n` (a trailing `\r` is stripped, so CRLF files work) and
/// each non-blank line is parsed with [parseCsvLine]. Blank lines are skipped
/// silently (not an error). Two structural problems send a row to
/// [CsvParseResult.errors] rather than [CsvParseResult.rows]:
///
/// - **Unterminated quote** — an odd number of `"` characters on the line (a
///   valid line always has an even count: wrapping quotes and doubled escapes
///   both come in pairs). This parser is line-oriented and does not support a
///   quoted field that spans physical newlines.
/// - **Column-count mismatch** — when an expected column count is known, a row
///   with a different field count is rejected. The expected count is
///   [expectedColumns] when given, otherwise the first non-blank row's count
///   when [hasHeader] is `true`. With neither, only quote validation runs.
///
/// When [hasHeader] is `true` the header row is still returned as the first
/// entry of [CsvParseResult.rows] (the caller knows it is the header).
/// Audited: 2026-06-12 11:26 EDT
CsvParseResult parseCsv(
  String input, {
  String delimiter = ',',
  bool hasHeader = false,
  int? expectedColumns,
}) {
  final List<List<String>> rows = <List<String>>[];
  final List<CsvRowError> errors = <CsvRowError>[];
  int? expected = expectedColumns;

  final List<String> lines = input.split('\n');
  for (int i = 0; i < lines.length; i++) {
    // Strip a trailing CR so Windows CRLF input does not leave '\r' on the last
    // field of every row.
    final String line = lines[i].endsWith('\r')
        ? lines[i].substring(0, lines[i].length - 1)
        : lines[i];

    // Skip blank lines silently — they are padding, not malformed data.
    if (line.isEmpty) {
      continue;
    }

    // An odd quote count means a quoted field was never closed on this line.
    if ('"'.allMatches(line).length.isOdd) {
      errors.add(CsvRowError(i + 1, line, 'unterminated quote'));
      continue;
    }

    final List<String> fields = parseCsvLine(line, delimiter: delimiter);

    // The first surviving row sets the expected width when a header is declared
    // and no explicit count was given.
    expected ??= hasHeader ? fields.length : null;

    if (expected != null && fields.length != expected) {
      errors.add(
        CsvRowError(
          i + 1,
          line,
          'expected $expected columns, found ${fields.length}',
        ),
      );
      continue;
    }

    rows.add(fields);
  }

  return CsvParseResult(rows, errors);
}

/// Parse one CSV line (handle quoted fields, commas inside quotes). Roadmap #141.
/// Audited: 2026-06-12 11:26 EDT
List<String> parseCsvLine(String line, {String delimiter = ','}) {
  final StringBuffer current = StringBuffer();
  bool isInQuotes = false;
  final List<String> fields = <String>[];
  for (int i = 0; i < line.length; i++) {
    final String c = line[i];
    if (c == '"') {
      // RFC 4180: a doubled quote ("") inside a quoted field is a literal quote.
      // Consume both characters and emit one; otherwise the quote just toggles
      // whether we are inside a quoted field (so delimiters within are ignored).
      if (isInQuotes && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else {
        isInQuotes = !isInQuotes;
      }
    } else if (isInQuotes) {
      current.write(c);
    } else if (c == delimiter) {
      fields.add(current.toString());
      current.clear();
    } else {
      current.write(c);
    }
  }
  fields.add(current.toString());
  return fields;
}
