/// Pivot for tabular data (list of maps) — roadmap #469.
///
/// Provides [pivot] (long-to-wide). The inverse `unpivot` (wide-to-long) is not
/// currently implemented despite the roadmap title; callers needing it should
/// reshape manually or track it as a feature gap.
library;

/// Pivot: one row per [rowKey] value, one column per [colKey] value, [valueKey] as cell.
/// Audited: 2026-06-12 11:26 EDT
List<Map<String, Object?>> pivot(
  List<Map<String, Object?>> rows,
  String rowKey,
  String colKey,
  String valueKey,
) {
  final Map<Object?, Map<String, Object?>> out = <Object?, Map<String, Object?>>{};
  for (final Map<String, Object?> r in rows) {
    final Object? rowKeyVal = r[rowKey];
    final Object? colKeyVal = r[colKey];
    final Object? v = r[valueKey];
    final rowMap = out.putIfAbsent(rowKeyVal, () => <String, Object?>{rowKey: rowKeyVal});
    rowMap[colKeyVal.toString()] = v;
  }
  return out.values.toList();
}
