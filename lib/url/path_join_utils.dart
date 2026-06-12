/// Join path segments (cross-platform, no double slash). Roadmap #161.
String pathJoin(Iterable<String> segments) {
  final List<String> parts = <String>[];
  for (final String s in segments) {
    // Normalize each segment to forward slashes, collapse runs of '/', and trim.
    final String t = s.replaceAll(r'\', '/').replaceAll(RegExp(r'/+'), '/').trim();
    // Drop no-op segments: empty and '.' (current dir) contribute nothing.
    if (t.isEmpty) continue;
    if (t == '.') continue;
    if (t == '..') {
      // '..' pops the previous segment. NOTE: a leading '..' with nothing to pop
      // is discarded — this join does not emit leading parent references.
      if (parts.isNotEmpty) parts.removeLast();
      continue;
    }
    parts.add(t);
  }
  return parts.join('/');
}

/// Normalize path (resolve . and ..). Roadmap #162.
String pathNormalize(String path) {
  // Normalize separators (backslash -> '/', collapse runs), then resolve the
  // segments: '.' and empty drop out, '..' pops the previous real segment.
  final String p = path.replaceAll(r'\', '/').replaceAll(RegExp(r'/+'), '/');
  final List<String> parts = p.split('/');
  final List<String> out = <String>[];
  for (final String seg in parts) {
    if (seg.isEmpty || seg == '.') continue;
    if (seg == '..') {
      // Pop the parent; a leading '..' with nothing to pop is dropped (this does
      // not produce '../' prefixes, matching pathJoin's behavior).
      if (out.isNotEmpty) out.removeLast();
      continue;
    }
    out.add(seg);
  }
  return out.join('/');
}

/// Relative path from base to target. Roadmap #163.
String pathRelative(String base, String target) {
  // Normalize then drop empty segments so leading/trailing/double slashes do not
  // create phantom segments that would throw off the common-prefix match below.
  final List<String> b = pathNormalize(base).split('/').where((String s) => s.isNotEmpty).toList();
  final List<String> t = pathNormalize(
    target,
  ).split('/').where((String s) => s.isNotEmpty).toList();
  // Advance through the shared leading segments; i ends at the first point where
  // base and target diverge (or the end of the shorter path).
  int i = 0;
  while (i < b.length && i < t.length && b[i] == t[i]) {
    i++;
  }
  // Climb out of every base segment past the divergence with "..", then descend
  // into target's remaining segments — that concatenation is the relative path.
  final List<String> ups = List<String>.filled(b.length - i, '..');
  final List<String> rest = t.sublist(i);
  // Join directly rather than via pathJoin: pathJoin treats a leading '..' as a
  // pop with nothing above it and discards it, which would erase the very
  // climb-out segments computed above (the bug where 'a/b/c' -> 'a/b/d' yielded
  // 'd' instead of '../d'). The segments are already clean — target was
  // normalized, base segments were consumed, and ups are literal '..' — so no
  // pathJoin re-normalization is needed. Identical paths leave both lists empty,
  // which joins to '' (the documented same-location result).
  return <String>[...ups, ...rest].join('/');
}
