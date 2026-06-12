/// Parse common HTTP caching headers without any HTTP dependency — roadmap #632.
///
/// Pure string parsing for the directives a client most often inspects:
/// `Cache-Control` (and its `max-age`), `ETag` (strong vs weak), and the
/// numeric form of `Retry-After`. No `dart:io`/`package:http` types are used,
/// so these helpers run on every platform including web. Malformed input
/// yields `null` rather than throwing, so callers can fall back to a default.
library;

/// Parses a `Cache-Control` [header] into a directive map.
///
/// Each comma-separated directive is lower-cased. A `key=value` directive maps
/// to its value (surrounding double quotes stripped); a bare flag directive
/// such as `no-cache` maps to `null`. Empty directives are skipped.
///
/// Example:
/// ```dart
/// parseCacheControl('no-cache, max-age=600');
/// // {'no-cache': null, 'max-age': '600'}
/// ```
Map<String, String?> parseCacheControl(String header) {
  final Map<String, String?> directives = <String, String?>{};
  // Split on commas; a directive is either a bare flag or a key=value pair.
  for (final String raw in header.split(',')) {
    final String token = raw.trim();
    if (token.isEmpty) {
      continue;
    }
    final int eq = token.indexOf('=');
    // No '=' means a bare flag directive (e.g. no-cache) with a null value.
    if (eq < 0) {
      directives[token.toLowerCase()] = null;
      continue;
    }
    // eq is an in-range index from indexOf, so both substrings below are bounded.
    // ignore: avoid_string_substring -- eq provably within length (indexOf + guard)
    final String key = token.substring(0, eq).trim().toLowerCase();
    // ignore: avoid_string_substring -- eq + 1 <= length (eq is a valid index)
    final String value = token.substring(eq + 1).trim();
    directives[key] = _unquote(value);
  }
  return directives;
}

/// Returns the `max-age` seconds from a `Cache-Control` [cacheControl] string,
/// or `null` if the directive is absent or its value is not a non-negative int.
int? parseMaxAge(String cacheControl) {
  final String? value = parseCacheControl(cacheControl)['max-age'];
  if (value == null) {
    return null;
  }
  final int? seconds = int.tryParse(value);
  // A negative max-age is not meaningful; reject it like a parse failure.
  if (seconds == null || seconds < 0) {
    return null;
  }
  return seconds;
}

/// Parses an `ETag` [header] into its weakness flag and unquoted tag value.
///
/// Handles strong tags (`"abc"`) and weak tags (`W/"abc"`). Returns `null` when
/// the value is not wrapped in the required double quotes.
///
/// Example:
/// ```dart
/// parseETag('W/"abc"'); // (weak: true, value: 'abc')
/// parseETag('"abc"');   // (weak: false, value: 'abc')
/// ```
({bool weak, String value})? parseETag(String header) {
  String token = header.trim();
  bool weak = false;
  // A leading W/ (case-sensitive per RFC 7232) marks a weak validator.
  if (token.startsWith('W/')) {
    weak = true;
    // 'W/' is provably the first two chars, so index 2 is within length.
    // ignore: avoid_string_substring -- startsWith('W/') guarantees length >= 2
    token = token.substring(2);
  }
  // The remaining tag must be a quoted string of at least the two quotes.
  if (token.length < 2 || !token.startsWith('"') || !token.endsWith('"')) {
    return null;
  }
  // Strip the surrounding quotes; bounds [1, length - 1) are valid given length >= 2.
  // ignore: avoid_string_substring -- length >= 2 with both quote bounds checked
  final String value = token.substring(1, token.length - 1);
  return (weak: weak, value: value);
}

/// Parses the numeric (delta-seconds) form of a `Retry-After` [header] into a
/// [Duration], or `null` when it is not a non-negative integer.
///
/// The HTTP-date form (e.g. `Wed, 21 Oct 2015 07:28:00 GMT`) is intentionally
/// unsupported and returns `null`; parsing dates would require a timezone-aware
/// formatter this dependency-free helper deliberately avoids.
Duration? parseRetryAfterSeconds(String header) {
  final int? seconds = int.tryParse(header.trim());
  // Reject the HTTP-date form and any malformed/negative value as null.
  if (seconds == null || seconds < 0) {
    return null;
  }
  return Duration(seconds: seconds);
}

/// Strips one layer of surrounding double quotes from [value], if present.
String _unquote(String value) {
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    // Bounds [1, length - 1) are valid given length >= 2 and both quotes checked.
    // ignore: avoid_string_substring -- length >= 2 with both quote bounds checked
    return value.substring(1, value.length - 1);
  }
  return value;
}
