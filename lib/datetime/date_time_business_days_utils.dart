import 'package:saropa_dart_utils/datetime/date_time_bounds_extensions.dart';

/// Business days between two dates (excludes weekends; no holiday support).
///
/// [start] and [end] are date-only (time ignored). Count is exclusive of [end].
int businessDaysBetween(DateTime start, DateTime end) {
  final DateTime s = DateTime(start.year, start.month, start.day);
  final DateTime e = DateTime(end.year, end.month, end.day);
  if (!s.isBefore(e)) return 0;
  int count = 0;
  DateTime d = s;
  while (d.isBefore(e)) {
    if (!d.isWeekend) count++;
    d = DateTime(d.year, d.month, d.day + 1);
  }
  return count;
}

/// Adds [n] business days to [date] (skips weekends). Negative [n] goes backward.
DateTime addBusinessDays(DateTime date, int n) {
  if (n == 0) return date;
  final DateTime d = DateTime(date.year, date.month, date.day);
  int step = n > 0 ? 1 : -1;
  int remaining = n.abs();
  DateTime current = d;
  while (remaining > 0) {
    current = DateTime(current.year, current.month, current.day + step);
    if (!current.isWeekend) remaining--;
  }
  return current;
}
