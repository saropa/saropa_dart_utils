import 'package:collection/collection.dart';

/// Get/set nested value by path (list of keys).
/// Audited: 2026-06-12 11:26 EDT
Object? getNested(Map<String, dynamic> map, List<String> path, [Object? defaultValue]) {
  // Descend one path segment at a time. The type check guards against indexing
  // into a leaf that turned out not to be a map (a shorter-than-expected path),
  // and a null at any level means the path does not resolve — both fall back to
  // defaultValue rather than throwing. Caveat: a genuine stored null is
  // indistinguishable from "missing" and also yields defaultValue.
  dynamic current = map;
  for (final String key in path) {
    if (current is! Map<String, dynamic>) return defaultValue;
    current = current[key];
    if (current == null) return defaultValue;
  }
  return current;
}

/// Sets [value] at the nested location addressed by [path] in [map], creating
/// intermediate maps as needed. Does nothing if [path] is empty, or stops early
/// if an existing intermediate value along [path] is not a map.
/// Audited: 2026-06-12 11:26 EDT
void setNested(Map<String, dynamic> map, List<String> path, Object? value) {
  if (path.isEmpty) return;
  Map<String, dynamic> current = map;
  bool descended = true;
  for (int i = 0; i < path.length - 1; i++) {
    final String key = path[i];
    final next = current.putIfAbsent(key, () => <String, dynamic>{});
    if (next is Map<String, dynamic>) {
      current = next;
    } else {
      // An existing intermediate is not a map: actually stop (the old code kept
      // `current` at the parent and still wrote lastKey there, silently
      // misplacing the value at the wrong level).
      descended = false;
      break;
    }
  }
  final lastKey = path.lastOrNull;
  if (descended && lastKey != null) current[lastKey] = value;
}
