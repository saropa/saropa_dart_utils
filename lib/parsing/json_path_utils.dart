/// Read a value from decoded JSON by a simple dotted/indexed path. Roadmap #157.
///
/// Supports the common subset used for config and API plucking:
/// `$.a.b`, `a.b[0]`, `[0].name`, `a.b[2].c`. A leading `$` is optional. It is
/// deliberately NOT full JSONPath — no wildcards, recursive descent (`..`),
/// filters, or slices — because that complexity is rarely needed and would
/// pull in a parser. For anything missing along the path, it returns `null`
/// rather than throwing, so callers can use `??` for defaults.
library;

/// Returns the value at [path] within decoded JSON [json] (maps/lists/scalars
/// as produced by `jsonDecode`), or `null` if any segment is missing or the
/// path is malformed.
///
/// Map keys are matched as strings; list indices must be non-negative and in
/// range. A bracket segment like `[2]` indexes a list; a bare name indexes a
/// map.
///
/// Example:
/// ```dart
/// final data = {'users': [{'name': 'Ada'}, {'name': 'Lin'}]};
/// getByJsonPath(data, r'$.users[1].name'); // 'Lin'
/// getByJsonPath(data, 'users[5].name');    // null (out of range)
/// ```
Object? getByJsonPath(Object? json, String path) {
  final List<Object> segments = _parseJsonPath(path);

  Object? current = json;
  for (final Object segment in segments) {
    if (current == null) {
      return null;
    }
    // An int segment indexes a list; a String segment keys a map. A mismatch
    // (e.g. indexing a map, or out-of-range list access) resolves to null.
    if (segment is int) {
      if (current is List && segment >= 0 && segment < current.length) {
        current = current[segment];
      } else {
        return null;
      }
    } else {
      if (current is Map && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return null;
      }
    }
  }
  return current;
}

/// Splits [path] into an ordered list of segments: `String` for map keys,
/// `int` for list indices. Returns an empty list for an empty / `$`-only path.
List<Object> _parseJsonPath(String path) {
  String p = path.trim();
  if (p.startsWith(r'$')) {
    p = p.substring(1);
  }
  if (p.startsWith('.')) {
    p = p.substring(1);
  }
  if (p.isEmpty) {
    return <Object>[];
  }

  final List<Object> segments = <Object>[];
  for (final String dotted in p.split('.')) {
    if (dotted.isEmpty) {
      continue;
    }
    // Each dotted token may carry trailing index brackets: name[0][1].
    final int firstBracket = dotted.indexOf('[');
    // firstBracket is an indexOf result guarded by the < 0 check, so it is a
    // valid in-bounds end index — substring cannot throw here.
    // ignore: avoid_string_substring -- index provably in range (indexOf + guard)
    final String name = firstBracket < 0 ? dotted : dotted.substring(0, firstBracket);
    if (name.isNotEmpty) {
      segments.add(name);
    }
    if (firstBracket >= 0) {
      _appendBracketIndices(dotted.substring(firstBracket), segments);
    }
  }
  return segments;
}

/// Parses a run of `[n][m]...` brackets, appending each index as an int.
void _appendBracketIndices(String brackets, List<Object> out) {
  int i = 0;
  while (i < brackets.length) {
    if (brackets[i] != '[') {
      break;
    }
    final int close = brackets.indexOf(']', i);
    if (close < 0) {
      break;
    }
    final int? index = int.tryParse(brackets.substring(i + 1, close).trim());
    if (index != null) {
      out.add(index);
    }
    i = close + 1;
  }
}
