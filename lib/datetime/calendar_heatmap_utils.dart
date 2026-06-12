/// GitHub-style contribution-heatmap data builders — roadmap #603.
///
/// Aggregates timestamped events into per-day counts, lays them out as a
/// week-by-week grid for a contribution-graph widget, and summarizes the
/// totals. All keying is DATE-ONLY: every event's time component is dropped and
/// it is bucketed under local midnight of its calendar date, so two events at
/// 09:00 and 23:00 on the same day count as that one day.
///
/// The grid is column-major by week: each inner list is one calendar week of 7
/// day-counts, aligned so index 0 is the configured `weekStartsOn` weekday.
/// Days before `start` or after `end` within a partial first/last week are
/// padded with 0, so every row is always length 7.
library;

/// Strips the time component, normalizing to local midnight on the same date.
/// Audited: 2026-06-12 11:26 EDT
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Counts how many [events] fall on each calendar date, keyed by date-only
/// local midnight (the time of day is ignored).
///
/// Example:
/// ```dart
/// dailyCounts(<DateTime>[DateTime(2026, 3, 1, 9), DateTime(2026, 3, 1, 23)]);
/// // { 2026-03-01: 2 }
/// ```
/// Audited: 2026-06-12 11:26 EDT
Map<DateTime, int> dailyCounts(Iterable<DateTime> events) {
  final Map<DateTime, int> counts = <DateTime, int>{};
  // Collapse each event to its date key so same-day events accumulate together.
  for (final DateTime event in events) {
    final DateTime key = _dateOnly(event);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

/// A list of weeks (each a length-7 list of counts) covering [start]..[end]
/// inclusive, with each inner row beginning on [weekStartsOn].
///
/// Missing days read 0. The first row is back-padded to the most recent
/// [weekStartsOn] on/before [start], and the last row is forward-padded to the
/// end of its week, so the grid is rectangular (every row length 7). [daily] is
/// the date-keyed map from [dailyCounts]; its keys are matched date-only.
///
/// Example:
/// ```dart
/// final Map<DateTime, int> d = dailyCounts(<DateTime>[DateTime(2026, 3, 3)]);
/// heatmapGrid(d, DateTime(2026, 3, 2), DateTime(2026, 3, 8));
/// // single week starting Monday 2026-03-02, with a 1 on Tuesday.
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<List<int>> heatmapGrid(
  Map<DateTime, int> daily,
  DateTime start,
  DateTime end, {
  int weekStartsOn = DateTime.monday,
}) {
  final DateTime gridStart = _weekStart(_dateOnly(start), weekStartsOn);
  final DateTime lastDay = _dateOnly(end);

  final List<List<int>> weeks = <List<int>>[];
  List<int> week = <int>[];
  DateTime day = gridStart;

  // Walk whole weeks of 7 days until we have passed [end]; the last week is
  // completed even when [end] lands mid-week, keeping every row length 7.
  while (!day.isAfter(lastDay) || week.isNotEmpty) {
    week.add(day.isBefore(_dateOnly(start)) ? 0 : (daily[day] ?? 0));
    // Step with calendar fields, NOT `day.add(Duration(days: 1))`: a fixed 24h
    // step on a LOCAL midnight lands at 01:00 across a spring-forward DST day,
    // which then misses the date-only midnight keys in `daily` and reads 0.
    day = DateTime(day.year, day.month, day.day + 1);
    if (week.length == DateTime.daysPerWeek) {
      weeks.add(week);
      week = <int>[];
    }
  }
  return weeks;
}

/// Summary stats for a date-keyed count map: the busiest day's [maxCount], the
/// [total] across all days, and the number of [activeDays] with a non-zero
/// count.
///
/// An empty map yields `(maxCount: 0, total: 0, activeDays: 0)`.
/// Audited: 2026-06-12 11:26 EDT
({int maxCount, int total, int activeDays}) heatmapStats(Map<DateTime, int> daily) {
  int maxCount = 0;
  int total = 0;
  int activeDays = 0;

  // A day is "active" only when its count is positive; a stored 0 does not count.
  for (final int count in daily.values) {
    total += count;
    if (count > 0) {
      activeDays++;
    }
    if (count > maxCount) {
      maxCount = count;
    }
  }
  return (maxCount: maxCount, total: total, activeDays: activeDays);
}

/// The most recent [weekStartsOn] weekday on or before [date]. Stepping back by
/// the positive modulus aligns any date to its week's first column; the `+ 7`
/// keeps the result non-negative when [date]'s weekday precedes [weekStartsOn].
/// Audited: 2026-06-12 11:26 EDT
DateTime _weekStart(DateTime date, int weekStartsOn) {
  final int offset = (date.weekday - weekStartsOn + DateTime.daysPerWeek) % DateTime.daysPerWeek;
  // Calendar-field step (not `subtract(Duration(days: offset))`) so the week
  // start stays at local midnight even when the span crosses a DST boundary.
  return DateTime(date.year, date.month, date.day - offset);
}
