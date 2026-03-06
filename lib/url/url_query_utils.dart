/// Parse query string to map (and back). Roadmap #168.
Map<String, String> parseQueryString(String query) {
  final Map<String, String> out = <String, String>{};
  if (query.isEmpty) return out;
  for (final String pair in query.split('&')) {
    final int eq = pair.indexOf('=');
    if (eq != -1) {
      out[Uri.decodeComponent(pair.replaceRange(eq, pair.length, ''))] = Uri.decodeComponent(
        pair.replaceRange(0, eq + 1, ''),
      );
    } else if (pair.isNotEmpty) {
      out[Uri.decodeComponent(pair)] = '';
    }
  }
  return out;
}

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
    for (final String k in remove) params.remove(k);
  }
  params.addAll(add);
  return uri.replace(query: buildQueryString(params));
}
