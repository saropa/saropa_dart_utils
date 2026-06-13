/// Parse query string to map (and back). Roadmap #168.
/// Audited: 2026-06-12 11:26 EDT
Map<String, String> parseQueryString(String query) {
  final Map<String, String> out = <String, String>{};
  if (query.isEmpty) return out;
  // Split on '&' into pairs, then on the FIRST '=' into key/value so a value
  // containing '=' is preserved. Both sides are percent-decoded.
  for (final String pair in query.split('&')) {
    final int eq = pair.indexOf('=');
    if (eq != -1) {
      out[_decode(pair.replaceRange(eq, pair.length, ''))] = _decode(
        pair.replaceRange(0, eq + 1, ''),
      );
    } else if (pair.isNotEmpty) {
      // A bare token with no '=' is a flag key with an empty value.
      out[_decode(pair)] = '';
    }
  }
  return out;
}

/// Percent-decodes [s], falling back to the raw text on a malformed escape.
/// `Uri.decodeComponent` throws `FormatException` on input like `%` or `%zz`;
/// this parser is the no-throw counterpart to [buildQueryString], so a bad
/// escape degrades to the literal text rather than crashing the caller.
/// Audited: 2026-06-12 11:26 EDT
String _decode(String s) {
  try {
    // Translate '+' to space first (application/x-www-form-urlencoded), which
    // Uri.decodeComponent does not do. A literal '+' arrives percent-encoded as
    // %2B (no '+' to replace), so this is safe for buildQueryString round-trips
    // and adds compatibility with form/browser-produced query strings.
    return Uri.decodeComponent(s.replaceAll('+', ' '));
    // ignore: saropa_lints/require_catch_logging -- deliberate graceful fallback: a malformed percent-escape in a query string degrades to its literal text (this is the no-throw counterpart to buildQueryString); logging every bad escape would be noise.
  } on FormatException {
    return s;
  }
}

/// Builds a percent-encoded `key=value&...` query string from [params].
///
/// Both keys and values are component-encoded. Returns an empty string when
/// [params] is empty.
///
/// Example:
/// ```dart
/// buildQueryString({'q': 'a b', 'p': '2'}); // 'q=a%20b&p=2'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String buildQueryString(Map<String, String> params) {
  if (params.isEmpty) return '';
  return params.entries
      .map(
        (MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}

/// Add/remove query params (immutable). Roadmap #169.
/// Audited: 2026-06-12 11:26 EDT
Uri uriWithQueryParams(Uri uri, Map<String, String> add, {Set<String>? remove}) {
  final Map<String, String> params = Map<String, String>.from(uri.queryParameters);
  if (remove != null) {
    for (final String k in remove) {
      params.remove(k);
    }
  }
  // ignore: saropa_lints/prefer_spread_over_addall -- params is mutated by the removal loop above; not a one-shot literal construction
  params.addAll(add);
  return uri.replace(query: buildQueryString(params));
}
