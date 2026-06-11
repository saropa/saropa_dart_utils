/// INI / `.env` configuration parser — roadmap #626.
///
/// Reads the two near-universal flat-config formats without a dependency:
/// `[section]` headers with `key=value` lines (INI), and the section-less
/// `KEY=value` files dotenv tools load. One core line walker backs both public
/// entry points. Comments (`#` / `;` full-line), surrounding quotes, and the
/// `export ` prefix are handled; values keep `#` literally (no inline-comment
/// stripping) so passwords, URLs, and color hexes survive unquoted.
library;

/// Section key under which entries appearing before any `[section]` header are
/// collected. Empty string can't collide with a real `[name]` (a header always
/// yields at least the bracket-trimmed text, and `[]` trims to empty only via an
/// explicit empty header, which is degenerate config the caller controls).
const String iniGlobalSection = '';

/// Parses [input] as INI text into `section → key → value`. Entries before the
/// first `[section]` land under [iniGlobalSection] (`''`). A declared but empty
/// `[section]` still appears as an empty map. The separator is the first `=` on
/// the line (so `url=http://x` keeps the colon in the value). Blank lines and
/// full-line `#` / `;` comments are skipped; any other line lacking `=` throws a
/// [FormatException] naming the offending line — strict by design so a typo in
/// config surfaces instead of being silently dropped.
///
/// Set [allowExport] to strip a leading `export ` from keys (shell-style files).
///
/// Example:
/// ```dart
/// parseIni('[db]\nhost = localhost\nport = 5432');
/// // {db: {host: localhost, port: 5432}}
/// ```
Map<String, Map<String, String>> parseIni(String input, {bool allowExport = false}) {
  final Map<String, Map<String, String>> out = <String, Map<String, String>>{};
  String section = iniGlobalSection;
  for (final String raw in input.split('\n')) {
    final String line = raw.trim();
    if (line.isEmpty || _isComment(line)) {
      continue;
    }
    // A `[name]` header opens (or re-opens) a section; create it eagerly so an
    // empty section is still observable, then move on to the next line.
    final String? header = _sectionName(line);
    if (header != null) {
      section = header;
      out.putIfAbsent(section, () => <String, String>{});
      continue;
    }
    final MapEntry<String, String> entry = _entry(raw, line, allowExport: allowExport);
    out.putIfAbsent(section, () => <String, String>{})[entry.key] = entry.value;
  }
  return out;
}

/// Parses [input] as a `.env` file into a flat `key → value` map. `export `
/// prefixes are stripped. `.env` files have no sections, but if `[section]`
/// headers do appear, every section's entries are flattened into one map (later
/// keys win) rather than discarded — so the result is never lossy.
///
/// Example:
/// ```dart
/// parseEnv('export TOKEN="ab\\ncd"\nPORT=8080');
/// // {TOKEN: ab⏎cd, PORT: 8080}
/// ```
Map<String, String> parseEnv(String input) {
  final Map<String, Map<String, String>> sections = parseIni(input, allowExport: true);
  final Map<String, String> flat = <String, String>{};
  // Flatten every section (normally just the global one) so a stray header in a
  // .env file does not silently drop its keys.
  for (final Map<String, String> section in sections.values) {
    flat.addAll(section);
  }
  return flat;
}

/// A full-line comment starts with `#` or `;` (already trimmed). Inline comments
/// are intentionally NOT recognized — a `#` mid-value is data, not a comment.
bool _isComment(String line) => line.startsWith('#') || line.startsWith(';');

/// Returns the trimmed name of a `[section]` header, or null if [line] is not a
/// header. Requires both brackets so a value like `[1, 2]` after a key is not
/// mistaken for a header (it never reaches here — it has an `=` — but the strict
/// shape keeps the check self-contained).
String? _sectionName(String line) {
  if (!line.startsWith('[') || !line.endsWith(']')) {
    return null;
  }
  // ignore: avoid_string_substring -- both brackets confirmed present, so length ≥ 2 and [1, length-1) is in bounds (empty for `[]`)
  return line.substring(1, line.length - 1).trim();
}

/// Splits one assignment line into a trimmed key/value. [raw] is the original
/// (untrimmed) line, passed only to give [FormatException] faithful context.
MapEntry<String, String> _entry(String raw, String line, {required bool allowExport}) {
  final int eq = line.indexOf('=');
  if (eq < 0) {
    throw FormatException('INI/.env line is not a comment, section, or key=value', raw);
  }
  String key = line.substring(0, eq).trim();
  // Shell `export KEY=val` — drop the prefix so the key matches plain lookups.
  if (allowExport && key.startsWith('export ')) {
    key = key.substring('export '.length).trim();
  }
  if (key.isEmpty) {
    throw FormatException('INI/.env assignment has an empty key', raw);
  }
  return MapEntry<String, String>(key, _unquote(line.substring(eq + 1).trim()));
}

/// Strips a single pair of matching surrounding quotes. Double-quoted values
/// interpret backslash escapes; single-quoted values are literal (the dotenv /
/// POSIX convention). An unmatched leading quote is kept verbatim rather than
/// guessed at, so malformed input is preserved for the caller to notice.
String _unquote(String value) {
  if (value.length < 2) {
    return value;
  }
  final String quote = value[0];
  if (quote != '"' && quote != "'") {
    return value;
  }
  if (value[value.length - 1] != quote) {
    return value;
  }
  // ignore: avoid_string_substring -- length ≥ 2 checked above and first/last are the matched quotes, so [1, length-1) is in bounds
  final String inner = value.substring(1, value.length - 1);
  return quote == '"' ? _unescapeDouble(inner) : inner;
}

/// Expands `\n \t \r \\ \"` inside a double-quoted value. An unknown escape
/// keeps the following character and drops the backslash (lenient), and a
/// trailing lone backslash is written as-is.
String _unescapeDouble(String s) {
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final String c = s[i];
    if (c != r'\' || i + 1 >= s.length) {
      buf.write(c);
      continue;
    }
    i++;
    buf.write(_escapeChar(s[i]));
  }
  return buf.toString();
}

/// Maps a single escape letter to its character; unknown letters pass through.
String _escapeChar(String c) {
  // Decodes the character that followed a backslash. Only the standard INI
  // escapes are recognized; an unknown letter passes through verbatim (the
  // default), so `\z` becomes `z` rather than throwing — matching lenient INI
  // readers that treat a stray backslash as a literal prefix.
  switch (c) {
    case 'n':
      return '\n'; // newline
    case 't':
      return '\t'; // tab
    case 'r':
      return '\r'; // carriage return
    case r'\':
      return r'\'; // literal backslash
    case '"':
      return '"'; // literal quote (so it doesn't close a quoted value)
    default:
      return c;
  }
}
