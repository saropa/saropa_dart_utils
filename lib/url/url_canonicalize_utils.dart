/// Canonicalize a URL so equivalent links compare equal. Roadmap #175.
///
/// Two URLs can be semantically identical yet differ byte-for-byte —
/// `HTTP://Example.com:80/a?b=2&a=1` versus `http://example.com/a?a=1&b=2`.
/// Canonicalization produces one stable form, which is what you store as a
/// dedupe/cache key or compare for "same page" checks.
library;

/// Returns a canonical form of [uri]:
/// - scheme and host lower-cased (they are case-insensitive),
/// - the scheme's default port removed — Dart's [Uri] does this automatically
///   for http/https/ws/wss (e.g. `:80` on http is dropped on construction),
/// - query parameters sorted by key, and each key's repeated values sorted,
///   so parameter order no longer affects identity,
/// - the fragment removed when [removeFragment] is true (default false; a
///   fragment can be meaningful for SPAs, so it is kept unless asked).
///
/// Path is left as-is — it is case-sensitive in general and normalizing `.`/
/// `..` is a separate concern (see path utilities). A valueless query flag
/// (`?ready`) round-trips as `ready=` because [Uri] models it as an empty
/// value.
///
/// Example:
/// ```dart
/// canonicalizeUrl(Uri.parse('HTTP://Example.com:80/a?b=2&a=1'));
/// // http://example.com/a?a=1&b=2
/// ```
/// Audited: 2026-06-12 11:26 EDT
Uri canonicalizeUrl(Uri uri, {bool removeFragment = false}) {
  // queryParametersAll groups every value per key (so ?tag=a&tag=b is not
  // collapsed); sort the keys and each key's values for a stable ordering.
  final List<MapEntry<String, List<String>>> entries = uri.queryParametersAll.entries.toList()
    ..sort(
      (MapEntry<String, List<String>> a, MapEntry<String, List<String>> b) =>
          a.key.compareTo(b.key),
    );

  final Map<String, dynamic> sortedQuery = <String, dynamic>{
    for (final MapEntry<String, List<String>> e in entries) e.key: (e.value.toList()..sort()),
  };

  // Omit the query entirely when there are no parameters so a query-less URL
  // stays query-less. Default ports need no handling here because Uri already
  // removes them on construction.
  Uri result = uri.replace(
    scheme: uri.scheme.toLowerCase(),
    host: uri.host.toLowerCase(),
    queryParameters: sortedQuery.isEmpty ? null : sortedQuery,
  );

  // Strip the fragment with the dedicated remover, which drops it cleanly;
  // replacing the fragment with an empty value would leave a dangling hash.
  if (removeFragment) {
    result = result.removeFragment();
  }
  return result;
}
