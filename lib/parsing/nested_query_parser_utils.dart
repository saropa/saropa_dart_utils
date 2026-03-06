/// Query string parser with nested keys (a[b][c]) — roadmap #628.
library;

import 'package:collection/collection.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Parses [queryString] into a nested map. Nested keys use bracket notation; all values are strings.
Map<String, Object?> parseNestedQuery(String queryString) {
  final Map<String, Object?> root = <String, Object?>{};
  if (queryString.isEmpty) return root;
  for (final String pair in queryString.split('&')) {
    final int eq = pair.indexOf('=');
    if (eq < 0) continue;
    final String keyStr = Uri.decodeComponent(pair.substringSafe(0, eq));
    final String value = Uri.decodeComponent(pair.substringSafe(eq + 1));
    final List<String> keySegments = keyStr.replaceAll(']', '').split('[');
    Map<String, Object?> current = root;
    for (int i = 0; i < keySegments.length - 1; i++) {
      final String k = keySegments[i];
      final child = current.putIfAbsent(k, () => <String, Object?>{});
      if (child is Map<String, Object?>) current = child;
    }
    final lastKey = keySegments.lastOrNull;
    if (lastKey != null) current[lastKey] = value;
  }
  return root;
}
