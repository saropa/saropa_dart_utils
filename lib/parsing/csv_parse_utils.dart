/// Parse one CSV line (handle quoted fields, commas inside quotes). Roadmap #141.
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
