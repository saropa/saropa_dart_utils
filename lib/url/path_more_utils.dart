/// URL/Path More: directory from path, base name, path separator, is absolute, etc. Roadmap #336-345.
String pathDirectory(String path) {
  final String p = path.replaceAll(r'\', '/');
  final int i = p.lastIndexOf('/');
  return i <= 0 ? (p.startsWith('/') ? '/' : '') : p.replaceRange(i, p.length, '');
}

String pathBaseName(String path) {
  final String p = path.replaceAll(r'\', '/');
  final int i = p.lastIndexOf('/');
  return i == -1 ? p : p.replaceRange(0, i + 1, '');
}

String get pathSeparator => '/';

bool isPathAbsolute(String path) {
  final String p = path.replaceAll(r'\', '/');
  return p.startsWith('/') || (p.length >= 2 && p[1] == ':');
}

String pathCollapseSeparators(String path) => path.replaceAll(RegExp(r'[/\\]+'), '/');

String pathAppend(String path, String segment) {
  final String p = path.replaceAll(r'\', '/');
  final String s = segment.replaceAll(r'\', '/');
  if (p.endsWith('/')) return p + s;
  if (s.isEmpty) return p;
  if (s.startsWith('/')) return p + s;
  return '$p/$s';
}

const String _kBearerPrefix = 'bearer ';

String? parseBearerToken(String authorizationHeader) {
  final String s = authorizationHeader.trim();
  if (s.toLowerCase().startsWith(_kBearerPrefix))
    return s.replaceRange(0, _kBearerPrefix.length, '').trim();
  return null;
}
