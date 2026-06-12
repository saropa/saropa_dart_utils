/// Calendar diff: added / removed / changed events between two snapshots —
/// roadmap #608.
///
/// Given an "before" and "after" list of events keyed by a stable id, this
/// classifies each event into added (only in after), removed (only in before),
/// or changed (same id, but a differing start, end, or title). It is the core
/// of sync reconciliation, "what changed since last refresh" banners, and
/// calendar-merge conflict UIs — logic apps routinely reimplement with ad-hoc
/// map juggling.
///
/// Identity is the [CalendarEvent.id]; equality for the changed/unchanged
/// decision compares start, end, and title. Two events with the same id are
/// assumed to be the same logical event observed at two times.
library;

/// A minimal calendar event: a stable [id] plus its [start], [end], and
/// [title]. Apps with richer models can map to and from this for diffing.
class CalendarEvent {
  /// Creates an event. [end] should not precede [start]; this is not enforced
  /// because a diff over malformed data should still classify, not throw.
  const CalendarEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
  });

  /// Stable identity used to pair events across the two snapshots.
  final String id;

  /// Event start instant.
  final DateTime start;

  /// Event end instant.
  final DateTime end;

  /// Human-readable title.
  final String title;

  /// True when [other] has the same start, end, and title (id is identity, not
  /// content, so it is excluded from the content comparison).
  bool sameContentAs(CalendarEvent other) =>
      start == other.start && end == other.end && title == other.title;

  @override
  String toString() => 'CalendarEvent(id: $id, title: $title)';
}

/// One event that changed: its [before] and [after] states (same id).
typedef CalendarChange = ({CalendarEvent before, CalendarEvent after});

/// The classified difference between two calendar snapshots.
typedef CalendarDiff = ({
  List<CalendarEvent> added,
  List<CalendarEvent> removed,
  List<CalendarChange> changed,
});

/// Diffs [before] against [after], pairing events by [CalendarEvent.id].
///
/// Duplicate ids within a single snapshot keep the last occurrence (later
/// entries win), matching map-insert semantics. Order of the returned lists
/// follows iteration over the respective input snapshots.
///
/// Example:
/// ```dart
/// final CalendarDiff d = diffCalendars(before, after);
/// d.added.length;   // events only in `after`
/// d.changed.first;  // (before: ..., after: ...) for a moved event
/// ```
CalendarDiff diffCalendars(List<CalendarEvent> before, List<CalendarEvent> after) {
  final Map<String, CalendarEvent> beforeById = <String, CalendarEvent>{
    for (final CalendarEvent e in before) e.id: e,
  };
  final Map<String, CalendarEvent> afterById = <String, CalendarEvent>{
    for (final CalendarEvent e in after) e.id: e,
  };
  // Added / changed: walk the after snapshot, comparing to the before map.
  final List<CalendarEvent> added = <CalendarEvent>[];
  final List<CalendarChange> changed = <CalendarChange>[];
  for (final CalendarEvent a in afterById.values) {
    final CalendarEvent? b = beforeById[a.id];
    if (b == null) {
      added.add(a);
    } else if (!b.sameContentAs(a)) {
      changed.add((before: b, after: a));
    }
  }
  // Removed: before entries with no surviving id in after.
  final List<CalendarEvent> removed = <CalendarEvent>[
    for (final CalendarEvent b in beforeById.values)
      if (!afterById.containsKey(b.id)) b,
  ];
  return (added: added, removed: removed, changed: changed);
}
