/// Query string parser with nested keys (a[b][c]) — roadmap #628.
library;

import 'package:collection/collection.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Parses [queryString] into a nested map. Nested keys use bracket notation; all values are strings.
/// Audited: 2026-06-12 11:26 EDT
Map<String, Object?> parseNestedQuery(String queryString) {
  final Map<String, Object?> root = <String, Object?>{};
  if (queryString.isEmpty) return root;
  for (final String pair in queryString.split('&')) {
    final int eq = pair.indexOf('=');
    if (eq < 0) continue;
    final String keyStr = Uri.decodeComponent(pair.substringSafe(0, eq));
    final String value = Uri.decodeComponent(pair.substringSafe(eq + 1));
    // Bracket notation a[b][c] becomes ['a','b','c']: dropping every ']' then
    // splitting on '[' yields one segment per nesting level without a regex.
    final List<String> keySegments = keyStr.replaceAll(']', '').split('[');
    Map<String, Object?> current = root;
    // Walk all but the final segment, creating intermediate maps as we descend;
    // the last segment is the leaf that actually holds the value (set below).
    bool descended = true;
    for (int i = 0; i < keySegments.length - 1; i++) {
      final String k = keySegments[i];
      final child = current.putIfAbsent(k, () => <String, Object?>{});
      if (child is Map<String, Object?>) {
        current = child;
      } else {
        // An intermediate level already holds a scalar (e.g. `a=1` then
        // `a[b]=2`): we cannot nest under it. Skip this pair rather than leaking
        // the leaf into the wrong (root) level and corrupting the structure.
        descended = false;
        break;
      }
    }
    final lastKey = keySegments.lastOrNull;
    if (descended && lastKey != null) current[lastKey] = value;
  }
  return root;
}
