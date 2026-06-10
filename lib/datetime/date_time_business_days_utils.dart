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
  // Zero offset is a no-op: return the original (with its time-of-day intact)
  // rather than the date-only normalization the loop would otherwise impose.
  if (n == 0) return date;
  final DateTime d = DateTime(date.year, date.month, date.day);
  // Sign of n picks the direction; the count is taken as magnitude so one loop
  // body handles both forward and backward stepping.
  final int step = n > 0 ? 1 : -1;
  int remaining = n.abs();
  DateTime current = d;
  // Advance one calendar day per iteration (never n days at once) so weekend
  // days in the span are stepped over without consuming the business-day count;
  // remaining only decrements when the day landed on is a weekday.
  while (remaining > 0) {
    current = DateTime(current.year, current.month, current.day + step);
    if (!current.isWeekend) remaining--;
  }
  return current;
}
