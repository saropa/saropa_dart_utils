/// Retention curves (N-day retention) — roadmap #581.
library;

import 'package:collection/collection.dart';

/// [events] = list of (userId, date). Returns map: dayIndex -> retained count (users who had event on day0 and on dayIndex).
Map<int, int> retentionByDay(List<(Object, DateTime)> events) {
  if (events.isEmpty) return <int, int>{};
  // Cohort-style retention: bucket every event by its user, then measure each
  // event's day offset from THAT user's first activity. The result maps
  // day-since-first -> number of events on that relative day (day 0 = every
  // user's first day), independent of calendar dates.
  final Map<Object, List<DateTime>> byUser = <Object, List<DateTime>>{};
  for (final (Object u, DateTime d) in events) {
    byUser.putIfAbsent(u, () => <DateTime>[]).add(d);
  }
  final Map<int, int> out = <int, int>{};
  for (final List<DateTime> dates in byUser.values) {
    // Sort so the earliest timestamp is the user's day-0 anchor.
    dates.sort();
    final DateTime? d0 = dates.firstOrNull;
    if (d0 == null) continue;
    for (final DateTime d in dates) {
      final int day = d.difference(d0).inDays;
      out[day] = (out[day] ?? 0) + 1;
    }
  }
  return out;
}
