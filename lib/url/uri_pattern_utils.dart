/// URI path-template matcher with typed params — roadmap #630.
library;

/// A compiled path template such as `/users/{id}/posts/{slug}` that matches
/// concrete request paths and extracts the named segment parameters.
///
/// Routers everywhere re-implement this with ad-hoc splitting or a hand-rolled
/// regex. This keeps it segment-based (no regex surprises) and supports a typed
/// constraint: `{id:int}` only matches a segment that parses as an integer, so
/// `/users/abc` will not match `/users/{id:int}`. Captured values are the raw
/// path segments (not percent-decoded) — decode at the call site if needed.
///
/// Example:
/// ```dart
/// UriPattern('/users/{id:int}/posts/{slug}').match('/users/42/posts/hello');
/// // {id: '42', slug: 'hello'}
/// ```
class UriPattern {
  /// Compiles [template] into matchable segments. Leading/trailing slashes and
  /// empty segments are ignored, so `/a/b/` and `a/b` compile identically.
  UriPattern(String template) : _segments = _compile(template);

  final List<_Segment> _segments;

  static List<String> _splitPath(String path) =>
      path.split('/').where((String s) => s.isNotEmpty).toList();

  static List<_Segment> _compile(String template) =>
      _splitPath(template).map(_Segment.parse).toList();

  /// Matches [path] against this template. Returns the captured params keyed by
  /// name, or null when the path does not match — a different segment count, a
  /// literal segment mismatch, or a typed param whose value fails its
  /// constraint. A template with no params returns an empty map on a match.
  Map<String, String>? match(String path) {
    final List<String> parts = _splitPath(path);
    if (parts.length != _segments.length) return null;
    final Map<String, String> params = <String, String>{};
    for (int i = 0; i < _segments.length; i++) {
      if (!_segments[i].accept(parts[i], params)) return null;
    }
    return params;
  }
}

/// One compiled template segment: either a literal to match exactly or a named
/// (optionally `:int`-typed) parameter to capture. A null [_paramName] marks a
/// literal segment; a non-null one marks a capture.
class _Segment {
  const _Segment(this._literal, this._paramName, {required this.isIntOnly});

  factory _Segment.parse(String raw) {
    // A param is wrapped in braces: `{name}` or `{name:int}`. Anything else is
    // a literal segment that must match the request path verbatim.
    final bool isParam = raw.startsWith('{') && raw.endsWith('}');
    if (!isParam) return _Segment(raw, null, isIntOnly: false);
    // Braces are guaranteed present (len >= 2), so this strip is in-bounds.
    // ignore: avoid_string_substring -- guarded by isParam above
    final String inner = raw.substring(1, raw.length - 1);
    final int colon = inner.indexOf(':');
    if (colon < 0) return _Segment(null, inner, isIntOnly: false);
    // colon is a valid index from indexOf, so both halves are in-bounds.
    // ignore: avoid_string_substring -- colon in [0, length)
    final String name = inner.substring(0, colon);
    // ignore: avoid_string_substring -- colon + 1 <= length
    final bool isIntOnly = inner.substring(colon + 1) == 'int';
    return _Segment(null, name, isIntOnly: isIntOnly);
  }

  final String? _literal;
  final String? _paramName;

  /// Whether a captured value must parse as an integer to match.
  final bool isIntOnly;

  bool accept(String value, Map<String, String> out) {
    final String? name = _paramName;
    if (name == null) return value == _literal;
    if (isIntOnly && int.tryParse(value) == null) return false;
    out[name] = value;
    return true;
  }
}
