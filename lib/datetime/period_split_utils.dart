/// Period splitting (by month/week) — roadmap #610.
library;

/// Splits [start]..[end] into consecutive months. Returns list of (monthStart, monthEnd).
/// Audited: 2026-06-12 11:26 EDT
List<(DateTime, DateTime)> splitByMonth(DateTime start, DateTime end) {
  final List<(DateTime, DateTime)> out = <(DateTime, DateTime)>[];
  DateTime cur = DateTime(start.year, start.month, 1);
  final DateTime endMonth = DateTime(end.year, end.month, 1);
  while (cur.isBefore(endMonth) || cur.isAtSameMomentAs(endMonth)) {
    final DateTime next = DateTime(cur.year, cur.month + 1, 1);
    // Last day of the current month via calendar fields (day 0 of next month),
    // NOT `next.subtract(Duration(days: 1))`: a fixed 24h step on a LOCAL
    // DateTime drifts off midnight across a DST boundary.
    final DateTime monthEnd = DateTime(cur.year, cur.month + 1, 0);
    final DateTime segmentEnd = next.isAfter(end) ? end : monthEnd;
    if (cur.isBefore(end) || cur.isAtSameMomentAs(end)) {
      out.add((cur, segmentEnd.isBefore(cur) ? cur : segmentEnd));
    }
    cur = next;
  }
  return out;
}
