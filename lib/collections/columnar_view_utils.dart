/// Columnar view of list<Map<String, Object?>> for analytics — roadmap #470.
library;

import 'package:collection/collection.dart';

/// Returns a single column [key] from [rows] as List<Object?>.
List<Object?> columnValues(List<Map<String, Object?>> rows, String key) {
  return rows.map((Map<String, Object?> r) => r[key]).toList();
}

/// Returns map of key -> list of values for all keys in [rows].
Map<String, List<Object?>> toColumnar(List<Map<String, Object?>> rows) {
  if (rows.isEmpty) return <String, List<Object?>>{};
  final Map<String, List<Object?>> out = <String, List<Object?>>{};
  final firstRow = rows.firstOrNull;
  if (firstRow == null) return out;
  for (final String k in firstRow.keys) {
    out[k] = columnValues(rows, k);
  }
  return out;
}
