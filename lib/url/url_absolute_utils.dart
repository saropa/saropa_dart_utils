const String _kSchemeHttp = 'http';
const String _kSchemeHttps = 'https';
const String _kSchemeFile = 'file';
const String _kSchemeFtp = 'ftp';

/// Is absolute URL / is relative path. Roadmap #174.
bool isAbsoluteUrl(String url) {
  final String trimmed = url.trim();
  if (trimmed.isEmpty) return false;
  final int colonIndex = trimmed.indexOf(':');
  if (colonIndex <= 0) return false;
  final String scheme = trimmed.replaceRange(colonIndex, trimmed.length, '').toLowerCase();
  return scheme == _kSchemeHttp ||
      scheme == _kSchemeHttps ||
      scheme == _kSchemeFile ||
      scheme == _kSchemeFtp;
}

bool isRelativePath(String path) {
  final String trimmed = path.trim();
  if (trimmed.isEmpty) return true;
  if (trimmed.startsWith('/')) return false;
  return trimmed.length < 2 || trimmed[1] != ':';
}
