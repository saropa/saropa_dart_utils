import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Parsing More: parse int with base, validate URL/IP, parse port, validate hex, etc. Roadmap #326-335.
/// Audited: 2026-06-12 11:26 EDT
int? parseIntBase(String s, int radix) {
  if (radix < 2 || radix > 36) return null;
  return int.tryParse(s, radix: radix);
}

/// Returns `true` if [s] begins with an `http://` or `https://` scheme.
///
/// A loose check: it only verifies the scheme prefix (case-insensitive) and
/// does not validate the host, path, or overall URL structure.
///
/// Example:
/// ```dart
/// isValidUrlLoose('https://example.com'); // true
/// isValidUrlLoose('ftp://example.com'); // false
/// ```
/// Audited: 2026-06-12 11:26 EDT
bool isValidUrlLoose(String s) => s.startsWith(RegExp(r'https?://', caseSensitive: false));

/// Returns `true` if [s] is a dotted-quad IPv4 address.
///
/// Requires exactly four parts separated by dots, each a decimal integer in the
/// range 0–255. Returns `false` for any other shape or out-of-range octet.
///
/// Example:
/// ```dart
/// isValidIpv4('192.168.0.1'); // true
/// isValidIpv4('256.0.0.1'); // false
/// ```
/// Audited: 2026-06-12 11:26 EDT
bool isValidIpv4(String s) {
  final List<String> parts = s.split('.');
  if (parts.length != 4) return false;
  for (final String p in parts) {
    final int? n = int.tryParse(p);
    if (n == null || n < 0 || n > 255) return false;
  }
  return true;
}

/// Extracts the port number from a `host:port` string in [hostPort].
///
/// Splits on the last colon so IPv6-style hosts do not break the host portion.
/// Returns `null` if there is no colon or the trailing segment is not an
/// integer.
///
/// Example:
/// ```dart
/// parsePortFromHostPort('example.com:8080'); // 8080
/// parsePortFromHostPort('example.com'); // null
/// ```
/// Audited: 2026-06-12 11:26 EDT
int? parsePortFromHostPort(String hostPort) {
  final int colon = hostPort.lastIndexOf(':');
  if (colon == -1) return null;
  return int.tryParse(hostPort.substringSafe(colon + 1));
}

/// Parses `key=value` lines from [input] into a map.
///
/// Splits [input] on newlines; each non-empty line is split on the first
/// occurrence of [separator] (default `=`), trimming whitespace from both key
/// and value. Blank lines and lines starting with `#` are skipped, as are lines
/// without the separator. Later duplicate keys overwrite earlier ones.
///
/// Example:
/// ```dart
/// parseKeyValueLines('a = 1\n# note\nb=2'); // {'a': '1', 'b': '2'}
/// ```
/// Audited: 2026-06-12 11:26 EDT
Map<String, String> parseKeyValueLines(String input, {String separator = '='}) {
  final Map<String, String> out = <String, String>{};
  for (final String line in input.split('\n')) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final int i = trimmed.indexOf(separator);
    if (i == -1) continue;
    out[trimmed.substringSafe(0, i).trim()] = trimmed.substringSafe(i + separator.length).trim();
  }
  return out;
}

/// Returns `true` if [s] consists only of hexadecimal digits.
///
/// Accepts upper- and lower-case `0-9A-F`. An empty string is not valid. When
/// [length] is given, [s] must have exactly that many characters.
///
/// Example:
/// ```dart
/// isValidHexString('1aF'); // true
/// isValidHexString('1aF', length: 2); // false
/// ```
/// Audited: 2026-06-12 11:26 EDT
bool isValidHexString(String s, {int? length}) {
  if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(s)) return false;
  if (length != null && s.length != length) return false;
  return true;
}

/// Parses the dot-separated integers in [s] into a list.
///
/// Splits on `.` and keeps only the segments that parse as integers; non-numeric
/// segments are silently dropped. Returns an empty list when nothing parses.
///
/// Example:
/// ```dart
/// parseDottedDecimal('1.20.3'); // [1, 20, 3]
/// parseDottedDecimal('1.x.3'); // [1, 3]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> parseDottedDecimal(String s) =>
    s.split('.').map((String x) => int.tryParse(x)).whereType<int>().toList();
