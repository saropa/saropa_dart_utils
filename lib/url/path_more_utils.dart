/// URL/Path More: directory from path, base name, path separator, is absolute, etc. Roadmap #336-345.
/// Audited: 2026-06-12 11:26 EDT
String pathDirectory(String path) {
  final String p = path.replaceAll(r'\', '/');
  final int i = p.lastIndexOf('/');
  return i <= 0 ? (p.startsWith('/') ? '/' : '') : p.replaceRange(i, p.length, '');
}

/// Returns the final segment of [path] (the file or last directory name).
///
/// Both `/` and `\` are accepted as separators. A path with no separator is
/// returned unchanged.
///
/// Example:
/// ```dart
/// pathBaseName('/usr/local/bin/dart'); // 'dart'
/// pathBaseName(r'C:\temp\file.txt'); // 'file.txt'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String pathBaseName(String path) {
  final String p = path.replaceAll(r'\', '/');
  final int i = p.lastIndexOf('/');
  return i == -1 ? p : p.replaceRange(0, i + 1, '');
}

/// The forward-slash separator used by these path helpers.
/// Audited: 2026-06-12 11:26 EDT
String get pathSeparator => '/';

/// Whether [path] is absolute — starts with `/` or has a drive letter (`C:`).
///
/// Both `/` and `\` are accepted as separators.
///
/// Example:
/// ```dart
/// isPathAbsolute('/etc/hosts'); // true
/// isPathAbsolute(r'C:\Windows'); // true
/// isPathAbsolute('docs/readme.md'); // false
/// ```
/// Audited: 2026-06-12 11:26 EDT
bool isPathAbsolute(String path) {
  final String p = path.replaceAll(r'\', '/');
  return p.startsWith('/') || (p.length >= 2 && p[1] == ':');
}

/// Collapses runs of `/` or `\` in [path] into a single forward slash.
///
/// Example:
/// ```dart
/// pathCollapseSeparators('a//b\\\\c'); // 'a/b/c'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String pathCollapseSeparators(String path) => path.replaceAll(RegExp(r'[/\\]+'), '/');

/// Joins [segment] onto [path] with a single forward slash.
///
/// Avoids duplicate separators when [path] ends with or [segment] starts with
/// a slash. An empty [segment] leaves [path] unchanged.
///
/// Example:
/// ```dart
/// pathAppend('docs', 'guide.md'); // 'docs/guide.md'
/// pathAppend('docs/', '/guide.md'); // 'docs//guide.md'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String pathAppend(String path, String segment) {
  final String p = path.replaceAll(r'\', '/');
  final String s = segment.replaceAll(r'\', '/');
  if (p.endsWith('/')) return p + s;
  if (s.isEmpty) return p;
  if (s.startsWith('/')) return p + s;
  return '$p/$s';
}

const String _kBearerPrefix = 'bearer ';

/// Extracts the token from a `Bearer <token>` [authorizationHeader].
///
/// The `Bearer` prefix is matched case-insensitively and surrounding
/// whitespace is trimmed. Returns null when the header is not a bearer token.
///
/// Example:
/// ```dart
/// parseBearerToken('Bearer abc123'); // 'abc123'
/// parseBearerToken('Basic abc123'); // null
/// ```
/// Audited: 2026-06-12 11:26 EDT
String? parseBearerToken(String authorizationHeader) {
  final String s = authorizationHeader.trim();
  if (s.toLowerCase().startsWith(_kBearerPrefix)) {
    return s.replaceRange(0, _kBearerPrefix.length, '').trim();
  }
  return null;
}
