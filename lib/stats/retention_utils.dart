/// Retention curves (N-day retention) — roadmap #581.
library;

import 'package:collection/collection.dart';

/// [events] = list of (userId, date). Returns map: dayIndex -> retained count (users who had event on day0 and on dayIndex).
Map<int, int> retentionByDay(List<(Object, DateTime)> events) {
  if (events.isEmpty) return <int, int>{};
  final Map<Object, List<DateTime>> byUser = <Object, List<DateTime>>{};
  for (final (Object u, DateTime d) in events) {
    byUser.putIfAbsent(u, () => []).add(d);
  }
  final Map<int, int> out = <int, int>{};
  for (final List<DateTime> dates in byUser.values) {
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
