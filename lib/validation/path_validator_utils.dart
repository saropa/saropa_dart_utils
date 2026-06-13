/// Robust file path validators (prevent traversal, normalize) — roadmap #693.
library;

/// Returns true if [path] does not contain '..' segments that escape [root].
/// Audited: 2026-06-12 11:26 EDT
bool isPathSafe(String path, String root) {
  final String pathNorm = path.replaceAll(RegExp(r'[/\\]+'), '/').replaceFirst(RegExp(r'^/'), '');
  final String rootNorm = root.replaceAll(RegExp(r'[/\\]+'), '/').replaceFirst(RegExp(r'^/'), '');
  final List<String> rootParts = rootNorm
      .split('/')
      .where((String s) => s.isNotEmpty && s != '.')
      .toList();
  final List<String> parts = pathNorm
      .split('/')
      .where((String s) => s.isNotEmpty && s != '.')
      .toList();
  // Track nesting depth relative to the ROOT directory: start at the root's own
  // depth and require we never climb above it. The previous check (`depth < 0`)
  // measured against the FILESYSTEM root, so a path could ascend rootParts.length
  // levels above the supplied root undetected — e.g. isPathSafe('../secret',
  // 'home/user') resolved to 'home/secret' (a sibling of the root) yet returned
  // true. Escaping the root the instant depth drops below rootDepth is correct.
  final int rootDepth = rootParts.length;
  int depth = rootDepth;
  for (final String p in parts) {
    if (p == '..') {
      depth--;
      if (depth < rootDepth) return false;
    } else {
      depth++;
    }
  }
  return true;
}
