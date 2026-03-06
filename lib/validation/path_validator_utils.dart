/// Robust file path validators (prevent traversal, normalize) — roadmap #693.
library;

/// Returns true if [path] does not contain '..' segments that escape [root].
bool isPathSafe(String path, String _) {
  final String normalized = path.replaceAll(RegExp(r'[/\\]+'), '/').replaceFirst(RegExp(r'^/'), '');
  final List<String> parts = normalized
      .split('/')
      .where((String s) => s.isNotEmpty && s != '.')
      .toList();
  int depth = 0;
  for (final String p in parts) {
    if (p == '..') {
      depth--;
      if (depth < 0) return false;
    } else {
      depth++;
    }
  }
  return true;
}
