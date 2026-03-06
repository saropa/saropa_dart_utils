/// Overlap of two date ranges. Returns (start, end) of overlap or null if none.
///
/// Ranges are inclusive: [aStart, aEnd] and [bStart, bEnd].
(DateTime start, DateTime end)? dateRangeOverlap(
  DateTime aStart,
  DateTime aEnd,
  DateTime bStart,
  DateTime bEnd,
) {
  final DateTime overlapStart = aStart.isAfter(bStart) ? aStart : bStart;
  final DateTime overlapEnd = aEnd.isBefore(bEnd) ? aEnd : bEnd;
  if (overlapStart.isAfter(overlapEnd)) return null;
  return (overlapStart, overlapEnd);
}
