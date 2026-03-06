/// Robust file path validators (prevent traversal, normalize) — roadmap #693.
library;

/// Returns true if [path] does not contain '..' segments that escape [root].
bool isPathSafe(String path, String root) {
  final String pathNorm =
      path.replaceAll(RegExp(r'[/\\]+'), '/').replaceFirst(RegExp(r'^/'), '');
  final String rootNorm =
      root.replaceAll(RegExp(r'[/\\]+'), '/').replaceFirst(RegExp(r'^/'), '');
  final List<String> rootParts = rootNorm
      .split('/')
      .where((String s) => s.isNotEmpty && s != '.')
      .toList();
  final List<String> parts = pathNorm
      .split('/')
      .where((String s) => s.isNotEmpty && s != '.')
      .toList();
  int depth = rootParts.length;
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
