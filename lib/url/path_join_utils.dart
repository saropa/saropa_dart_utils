/// Join path segments (cross-platform, no double slash). Roadmap #161.
String pathJoin(Iterable<String> segments) {
  final List<String> parts = <String>[];
  for (final String s in segments) {
    final String t = s.replaceAll(r'\', '/').replaceAll(RegExp(r'/+'), '/').trim();
    if (t.isEmpty) continue;
    if (t == '.') continue;
    if (t == '..') {
      if (parts.isNotEmpty) parts.removeLast();
      continue;
    }
    parts.add(t);
  }
  return parts.join('/');
}

/// Normalize path (resolve . and ..). Roadmap #162.
String pathNormalize(String path) {
  final String p = path.replaceAll(r'\', '/').replaceAll(RegExp(r'/+'), '/');
  final List<String> parts = p.split('/');
  final List<String> out = <String>[];
  for (final String seg in parts) {
    if (seg.isEmpty || seg == '.') continue;
    if (seg == '..') {
      if (out.isNotEmpty) out.removeLast();
      continue;
    }
    out.add(seg);
  }
  return out.join('/');
}

/// Relative path from base to target. Roadmap #163.
String pathRelative(String base, String target) {
  final List<String> b = pathNormalize(base).split('/').where((String s) => s.isNotEmpty).toList();
  final List<String> t = pathNormalize(
    target,
  ).split('/').where((String s) => s.isNotEmpty).toList();
  int i = 0;
  while (i < b.length && i < t.length && b[i] == t[i]) i++;
  final List<String> ups = List<String>.filled(b.length - i, '..');
  final List<String> rest = t.sublist(i);
  return pathJoin(<String>[...ups, ...rest]);
}
