/// Gap-based sessionization of timestamped items (roadmap #485).
///
/// Groups a flat list of timestamped items into "sessions": runs of items
/// where each consecutive pair is no more than [maxGap] apart. A new session
/// begins whenever the gap to the previous item exceeds [maxGap]. This is the
/// classic analytics sessionization used for clickstreams, login activity, GPS
/// tracks, and log bursts — turning a timeline into discrete bouts of activity.
///
/// Input may be unsorted; both entry points sort by timestamp first, so the
/// returned sessions are always in chronological order.
library;

import 'package:collection/collection.dart';

/// Splits [items] into chronological sessions, starting a new session whenever
/// the gap between an item and its predecessor exceeds [maxGap].
///
/// Items are sorted by [timestamp] first, so unsorted input is handled. Equal
/// timestamps stay in the same session (a zero gap never exceeds a non-negative
/// [maxGap]). Returns an empty list for empty input and one single-item session
/// for one item.
///
/// Example:
/// ```dart
/// final List<List<DateTime>> sessions = clusterIntoSessions<DateTime>(
///   stamps,
///   timestamp: (DateTime d) => d,
///   maxGap: const Duration(minutes: 30),
/// );
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<List<T>> clusterIntoSessions<T>(
  List<T> items, {
  required DateTime Function(T) timestamp,
  required Duration maxGap,
}) {
  final List<T> sorted = _sortedByTimestamp<T>(items, timestamp);
  // firstOrNull keeps the empty case explicit: no items means no sessions.
  final T? head = sorted.firstOrNull;
  if (head == null) {
    return <List<T>>[];
  }
  final List<List<T>> sessions = <List<T>>[];
  // Hold the open session in a local so we never index back into `sessions`
  // with a throwing accessor; it is appended to `sessions` as it is opened.
  List<T> currentSession = <T>[head];
  sessions.add(currentSession);
  DateTime previous = timestamp(head);
  // Walk the rest; a gap larger than maxGap opens a fresh session bucket.
  for (int i = 1; i < sorted.length; i++) {
    final T current = sorted[i];
    final DateTime currentStamp = timestamp(current);
    if (currentStamp.difference(previous) > maxGap) {
      currentSession = <T>[current];
      sessions.add(currentSession);
    } else {
      currentSession.add(current);
    }
    previous = currentStamp;
  }
  return sessions;
}

/// Same sessionization as [clusterIntoSessions], but each session is returned
/// as a record carrying its [start] and [end] timestamps alongside its items.
///
/// [start] is the earliest item's timestamp in the session and [end] the
/// latest; for a single-item session they are equal.
///
/// Example:
/// ```dart
/// final List<({DateTime start, DateTime end, List<Event> items})> s =
///     sessionsWithBounds<Event>(
///   events,
///   timestamp: (Event e) => e.at,
///   maxGap: const Duration(hours: 1),
/// );
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<({DateTime start, DateTime end, List<T> items})> sessionsWithBounds<T>(
  List<T> items, {
  required DateTime Function(T) timestamp,
  required Duration maxGap,
}) {
  final List<List<T>> sessions = clusterIntoSessions<T>(
    items,
    timestamp: timestamp,
    maxGap: maxGap,
  );
  final List<({DateTime start, DateTime end, List<T> items})> out =
      <({DateTime start, DateTime end, List<T> items})>[];
  // Each session is non-empty and timestamp-sorted by construction, so the
  // first item carries the earliest stamp and the last the latest. firstOrNull/
  // lastOrNull read those without a throwing accessor; the null branch can
  // never fire (clusterIntoSessions never emits an empty bucket) but is handled
  // by skipping, which keeps flow analysis happy and avoids an unsafe cast.
  for (final List<T> session in sessions) {
    final T? head = session.firstOrNull;
    final T? tail = session.lastOrNull;
    if (head == null || tail == null) {
      continue;
    }
    out.add(
      (start: timestamp(head), end: timestamp(tail), items: session),
    );
  }
  return out;
}

/// Returns a new list of [items] ordered ascending by [timestamp]; the source
/// list is never mutated so callers keep their original ordering.
/// Audited: 2026-06-12 11:26 EDT
List<T> _sortedByTimestamp<T>(List<T> items, DateTime Function(T) timestamp) =>
    items.toList()..sort(
      (T a, T b) => timestamp(a).compareTo(timestamp(b)),
    );
