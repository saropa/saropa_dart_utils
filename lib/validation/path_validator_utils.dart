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
  // Track nesting depth relative to the filesystem root, starting inside root.
  // Each normal segment descends; each ".." ascends. The path escapes only if it
  // climbs above the root itself (depth < 0) — climbing back to or within root is
  // safe, so the test is the running minimum, not the final depth.
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
