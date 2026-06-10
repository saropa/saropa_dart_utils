import 'package:collection/collection.dart';

/// Get/set nested value by path (list of keys).
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
void setNested(Map<String, dynamic> map, List<String> path, Object? value) {
  if (path.isEmpty) return;
  Map<String, dynamic> current = map;
  for (int i = 0; i < path.length - 1; i++) {
    final String key = path[i];
    final next = current.putIfAbsent(key, () => <String, dynamic>{});
    if (next is Map<String, dynamic>) current = next;
  }
  final lastKey = path.lastOrNull;
  if (lastKey != null) current[lastKey] = value;
}
