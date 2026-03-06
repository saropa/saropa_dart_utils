import 'package:collection/collection.dart';

/// Get/set nested value by path (list of keys).
Object? getNested(Map<String, dynamic> map, List<String> path, [Object? defaultValue]) {
  dynamic current = map;
  for (final String key in path) {
    if (current is! Map<String, dynamic>) return defaultValue;
    current = current[key];
    if (current == null) return defaultValue;
  }
  return current;
}

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
