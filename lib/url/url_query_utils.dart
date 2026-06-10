/// Parse query string to map (and back). Roadmap #168.
Map<String, String> parseQueryString(String query) {
  final Map<String, String> out = <String, String>{};
  if (query.isEmpty) return out;
  // Split on '&' into pairs, then on the FIRST '=' into key/value so a value
  // containing '=' is preserved. Both sides are percent-decoded.
  for (final String pair in query.split('&')) {
    final int eq = pair.indexOf('=');
    if (eq != -1) {
      out[Uri.decodeComponent(pair.replaceRange(eq, pair.length, ''))] = Uri.decodeComponent(
        pair.replaceRange(0, eq + 1, ''),
      );
    } else if (pair.isNotEmpty) {
      // A bare token with no '=' is a flag key with an empty value.
      out[Uri.decodeComponent(pair)] = '';
    }
  }
  return out;
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
