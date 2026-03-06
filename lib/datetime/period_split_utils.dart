/// Period splitting (by month/week) — roadmap #610.
library;

/// Splits [start]..[end] into consecutive months. Returns list of (monthStart, monthEnd).
List<(DateTime, DateTime)> splitByMonth(DateTime start, DateTime end) {
  final List<(DateTime, DateTime)> out = [];
  DateTime cur = DateTime(start.year, start.month, 1);
  final DateTime endMonth = DateTime(end.year, end.month, 1);
  while (cur.isBefore(endMonth) || cur.isAtSameMomentAs(endMonth)) {
    final DateTime next = DateTime(cur.year, cur.month + 1, 1);
    final DateTime segmentEnd = next.isAfter(end) ? end : next.subtract(const Duration(days: 1));
    if (cur.isBefore(end) || cur.isAtSameMomentAs(end))
      out.add((cur, segmentEnd.isBefore(cur) ? cur : segmentEnd));
    cur = next;
  }
  return out;
}
