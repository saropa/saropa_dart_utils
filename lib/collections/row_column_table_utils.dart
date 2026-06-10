/// Row-oriented vs column-oriented table conversion — roadmap #525.
library;

import 'package:collection/collection.dart';

/// From columnar map (key -> list of values) to list of row maps.
List<Map<String, Object?>> columnarToRows(Map<String, List<Object?>> columnar) {
  // Transpose column-major data (column name -> values) into row maps.
  if (columnar.isEmpty) return <Map<String, Object?>>[];
  // The first column sets the row count; ragged columns are tolerated below.
  final firstCol = columnar.values.firstOrNull;
  if (firstCol == null) return <Map<String, Object?>>[];
  final int n = firstCol.length;
  final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
  for (int i = 0; i < n; i++) {
    final Map<String, Object?> rowMap = <String, Object?>{};
    // Pull row i from every column; a column shorter than the first yields null
    // so all rows keep the same key set.
    for (final MapEntry<String, List<Object?>> e in columnar.entries) {
      rowMap[e.key] = i < e.value.length ? e.value[i] : null;
    }
    rows.add(rowMap);
  }
  return rows;
}
