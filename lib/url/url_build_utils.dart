import 'package:saropa_dart_utils/url/url_query_utils.dart';

const String _kSchemeHttp = 'http';
const String _kSchemeHttps = 'https';

/// Build URL from base + path + query. Strip fragment. Roadmap #170, #173.
/// Only http and https bases are allowed (SSRF safety).
Uri buildUri(String base, {String path = '', Map<String, String>? query}) {
  final Uri? baseUri = Uri.tryParse(base);
  if (baseUri == null || !baseUri.hasScheme) {
    throw FormatException('Invalid base URL: $base');
  }
  final String scheme = baseUri.scheme.toLowerCase();
  if (scheme != _kSchemeHttp && scheme != _kSchemeHttps) {
    throw FormatException('Base URL scheme must be http or https: $base');
  }
  final Uri resolved = path.isEmpty ? baseUri : baseUri.resolveUri(Uri(path: path));
  final Uri noFrag = resolved.replace(fragment: '');
  if (query == null || query.isEmpty) return noFrag;
  return noFrag.replace(query: buildQueryString(query));
}

Uri stripFragment(Uri uri) => uri.replace(fragment: '');
