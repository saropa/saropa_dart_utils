/// Simple glob matching (**/*.dart style).
///
/// Tree-shakeable: import only this file if you need glob match.
library;

/// Glob-style pattern matching. Supports * (any sequence), ? (one char), ** (any path).
abstract final class GlobUtils {
  GlobUtils._();

  /// Returns true if [path] matches [pattern].
  ///
  /// [pattern] may contain * (match any chars except /), ? (one char except /),
  /// and ** (match zero or more path segments). Segment separator is /.
  /// Matching is case-sensitive.
  ///
  /// Example:
  /// ```dart
  /// GlobUtils.match('lib/foo.dart', 'lib/*.dart');  // true
  /// GlobUtils.match('a/b/c', 'a/**/c');            // true
  /// ```
  static bool match(String path, String pattern) {
    if (path.isEmpty && pattern.isEmpty) return true;
    if (path.isEmpty || pattern.isEmpty) return false;
    return _matchSegments(path.split('/'), 0, pattern.split('/'), 0);
  }

  static bool _matchSegments(List<String> pathSegs, int pi, List<String> patternSegs, int qi) {
    if (pi >= pathSegs.length && qi >= patternSegs.length) return true;
    if (qi >= patternSegs.length) return false;
    final String pat = patternSegs[qi];
    if (pat == '**') {
      // Trailing "**" matches all remaining path segments, so accept immediately.
      if (qi + 1 >= patternSegs.length) return true;
      // "**" matches zero or more segments: try resuming the pattern after it at
      // every remaining boundary (i == pi consumes zero; i == length consumes the
      // rest). Backtracking is what lets a single "**" span a variable depth.
      for (int i = pi; i <= pathSegs.length; i++) {
        if (_matchSegments(pathSegs, i, patternSegs, qi + 1)) return true;
      }
      return false;
    }
    if (pi >= pathSegs.length) return false;
    if (!_matchSegment(pathSegs[pi], pat)) return false;
    return _matchSegments(pathSegs, pi + 1, patternSegs, qi + 1);
  }

  // Matches one path segment against one glob pattern segment (no '/' inside).
  // '*' matches any run within the segment, '?' exactly one char, anything else
  // is a literal. '*' is the only backtracking point.
  static bool _matchSegment(String seg, String pat) {
    int segmentIdx = 0;
    int patternIdx = 0;
    while (patternIdx < pat.length) {
      if (pat[patternIdx] == '*') {
        // Try matching the rest of the pattern at every split of the remaining
        // segment (shortest match first); succeed if any split works.
        patternIdx++;
        while (segmentIdx <= seg.length) {
          if (_matchSegmentRest(seg, segmentIdx, pat, patternIdx)) return true;
          segmentIdx++;
        }
        return false;
      }
      if (pat[patternIdx] == '?') {
        // One arbitrary character — requires a character to be present.
        if (segmentIdx >= seg.length) return false;
        segmentIdx++;
        patternIdx++;
        continue;
      }
      // Literal char must match exactly.
      if (segmentIdx >= seg.length || seg[segmentIdx] != pat[patternIdx]) return false;
      segmentIdx++;
      patternIdx++;
    }
    // Pattern exhausted: match only if the segment is fully consumed too.
    return segmentIdx >= seg.length;
  }

  static bool _matchSegmentRest(String seg, int si, String pat, int pi) {
    int segIdx = si;
    int patIdx = pi;
    while (patIdx < pat.length) {
      if (pat[patIdx] == '?') {
        if (segIdx >= seg.length) return false;
        segIdx++;
        patIdx++;
        continue;
      }
      if (pat[patIdx] == '*') {
        patIdx++;
        // "*" matches any run within a segment (never crossing '/'): try every
        // split point from zero chars (segIdx) up to the whole remainder
        // (segIdx == length), recursing to match the pattern tail at each. This
        // backtracking resolves patterns with multiple "*" in one segment.
        while (segIdx <= seg.length) {
          if (_matchSegmentRest(seg, segIdx, pat, patIdx)) return true;
          segIdx++;
        }
        return false;
      }
      if (segIdx >= seg.length || seg[segIdx] != pat[patIdx]) return false;
      segIdx++;
      patIdx++;
    }
    // Pattern exhausted: it matches only if the segment was fully consumed too.
    return segIdx >= seg.length;
  }
}
