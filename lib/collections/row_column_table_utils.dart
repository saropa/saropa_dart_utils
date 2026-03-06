/// Row-oriented vs column-oriented table conversion — roadmap #525.
library;

import 'package:collection/collection.dart';

/// From columnar map (key -> list of values) to list of row maps.
List<Map<String, Object?>> columnarToRows(Map<String, List<Object?>> columnar) {
  if (columnar.isEmpty) return [];
  final firstCol = columnar.values.firstOrNull;
  if (firstCol == null) return [];
  final int n = firstCol.length;
  final List<Map<String, Object?>> rows = [];
  for (int i = 0; i < n; i++) {
    final Map<String, Object?> rowMap = <String, Object?>{};
    for (final MapEntry<String, List<Object?>> e in columnar.entries) {
      rowMap[e.key] = i < e.value.length ? e.value[i] : null;
    }
    rows.add(rowMap);
  }
  return rows;
}
