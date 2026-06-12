/// Columnar view of list<Map<String, Object?>> for analytics — roadmap #470.
library;

import 'package:collection/collection.dart';

/// Returns a single column [key] from [rows] as List<Object?>.
/// Audited: 2026-06-12 11:26 EDT
List<Object?> columnValues(List<Map<String, Object?>> rows, String key) =>
    rows.map((Map<String, Object?> r) => r[key]).toList();

/// Returns map of key -> list of values, using the keys of the FIRST row as the
/// column schema. Keys that appear only in later rows are NOT included; rows
/// missing a first-row key contribute `null` for that column. Pre-normalize the
/// rows (union their keys) if every key must appear.
/// Audited: 2026-06-12 11:26 EDT
Map<String, List<Object?>> toColumnar(List<Map<String, Object?>> rows) {
  // Inverse of columnarToRows: turn row maps into column-major lists. The first
  // row defines the column set (and order); each column pulls its value from
  // every row via columnValues, so the schema is taken from row 0.
  if (rows.isEmpty) return <String, List<Object?>>{};
  final Map<String, List<Object?>> out = <String, List<Object?>>{};
  final firstRow = rows.firstOrNull;
  if (firstRow == null) return out;
  for (final String k in firstRow.keys) {
    out[k] = columnValues(rows, k);
  }
  return out;
}
