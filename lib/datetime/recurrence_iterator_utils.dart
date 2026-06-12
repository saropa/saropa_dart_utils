/// Expand a parsed RRULE into concrete occurrences — roadmap #592.
///
/// The companion to `parseRrule` (#591): given a [RecurrenceRule] and a start
/// instant, lazily generate the dates it describes. The result is a lazy
/// `Iterable` (a `sync*` generator), so an unbounded rule is safe — bound it
/// with the rule's own `count`/`until`, the [expandRecurrence] `limit`, or a
/// `.take(n)` on the result. A rule with none of those and no `.take` iterates
/// forever, by design.
///
/// Scope matches the #591 parser subset: FREQ daily/weekly/monthly/yearly with
/// INTERVAL, BYDAY, BYMONTHDAY (incl. negative from month-end), BYMONTH, and
/// WKST. The [start] instant supplies the time-of-day and UTC-ness of every
/// occurrence and acts as DTSTART (occurrences before it are skipped).
library;

import 'package:saropa_dart_utils/datetime/rrule_parse_utils.dart';

/// Lazily yields the occurrences of [rule] at and after [start], in ascending
/// order. [limit] caps the number emitted (in addition to any `count`/`until`
/// on the rule); the first limit reached wins.
///
/// Example:
/// ```dart
/// final rule = parseRrule('FREQ=WEEKLY;BYDAY=MO,WE;COUNT=4');
/// expandRecurrence(rule, DateTime(2026, 1, 5)).toList();
/// // Mon Jan 5, Wed Jan 7, Mon Jan 12, Wed Jan 14
/// ```
/// Audited: 2026-06-12 11:26 EDT
Iterable<DateTime> expandRecurrence(
  RecurrenceRule rule,
  DateTime start, {
  int? limit,
}) sync* {
  int emitted = 0;
  // Counts periods that produced nothing since the last yield. An IMPOSSIBLE
  // rule (e.g. BYMONTHDAY=30;BYMONTH=2 — Feb 30 never exists) yields forever-
  // nothing, so without this bound even `.take(n)` would hang. A long empty run
  // with nothing emitted means no occurrence will ever appear. Valid infinite
  // rules yield regularly, resetting the counter, so they still iterate forever.
  int emptyPeriods = 0;
  DateTime anchor = start;
  // Walk one FREQ×INTERVAL period at a time; each period yields its sorted
  // candidate dates. Periods advance monotonically forward, so the first
  // candidate past `until` ends the whole sequence.
  while (true) {
    bool yieldedThisPeriod = false;
    for (final DateTime occurrence in _candidatesFor(rule, start, anchor)) {
      if (occurrence.isBefore(start)) {
        continue;
      }
      final DateTime? until = rule.until;
      if (until != null && occurrence.isAfter(until)) {
        return;
      }
      yield occurrence;
      emitted++;
      yieldedThisPeriod = true;
      if (_reachedLimit(rule, limit, emitted)) {
        return;
      }
    }
    anchor = _advanceAnchor(rule, anchor);
    // Stop once the period itself is past `until` (an impossible rule never
    // emits, so the per-occurrence `until` check above can never fire for it).
    final DateTime? until = rule.until;
    if (until != null && anchor.isAfter(until)) {
      return;
    }
    if (yieldedThisPeriod) {
      emptyPeriods = 0;
    } else if (++emptyPeriods >= _maxEmptyPeriods) {
      return;
    }
  }
}

/// Consecutive empty periods after which an apparently-impossible rule (one that
/// can never produce an occurrence) is abandoned. Generous enough that any valid
/// sparse rule (e.g. a Feb-29 yearly rule, empty in non-leap years) keeps going.
const int _maxEmptyPeriods = 100000;

/// True once the rule's `count` or the caller's [limit] (whichever exists and is
/// hit first) has been reached.
/// Audited: 2026-06-12 11:26 EDT
bool _reachedLimit(RecurrenceRule rule, int? limit, int emitted) {
  final int? count = rule.count;
  if (count != null && emitted >= count) {
    return true;
  }
  return limit != null && emitted >= limit;
}

/// The sorted candidate occurrences within the period represented by [anchor].
/// Audited: 2026-06-12 11:26 EDT
List<DateTime> _candidatesFor(RecurrenceRule rule, DateTime start, DateTime anchor) {
  // Dispatch to the frequency-specific generator. Each returns the occurrences
  // that fall inside the single period [anchor] names (one day, one week, one
  // month, one year) — the caller advances [anchor] and calls again to page
  // through the series, so this only ever produces one period's worth.
  switch (rule.frequency) {
    case RecurFrequency.daily:
      return _dailyCandidates(rule, start, anchor);
    case RecurFrequency.weekly:
      return _weeklyCandidates(rule, start, anchor);
    case RecurFrequency.monthly:
      return _monthlyCandidates(rule, start, anchor);
    case RecurFrequency.yearly:
      return _yearlyCandidates(rule, start, anchor);
  }
}

/// Advances [anchor] to the next period start (interval units of the frequency).
/// Day/month overflow is left to the `DateTime` constructor to normalize.
/// Audited: 2026-06-12 11:26 EDT
DateTime _advanceAnchor(RecurrenceRule rule, DateTime anchor) {
  switch (rule.frequency) {
    case RecurFrequency.daily:
      return _addDays(anchor, rule.interval);
    case RecurFrequency.weekly:
      return _addDays(anchor, 7 * rule.interval);
    case RecurFrequency.monthly:
      return _dateWith(anchor, anchor.year, anchor.month + rule.interval, 1);
    case RecurFrequency.yearly:
      return _dateWith(anchor, anchor.year + rule.interval, 1, 1);
  }
}

/// DAILY: the single anchor day, kept only if it passes every active BY filter.
/// Audited: 2026-06-12 11:26 EDT
List<DateTime> _dailyCandidates(RecurrenceRule rule, DateTime start, DateTime anchor) {
  // DAILY produces at most the anchor day itself. Each active BY* filter is an
  // independent gate: if the day fails any one, the period yields nothing (empty
  // list), and the iterator moves to the next interval. An absent filter (empty
  // list) is treated as "matches everything", so it's skipped.

  // BYMONTH: drop the day unless its month is in the allowed set.
  if (rule.byMonths.isNotEmpty && !rule.byMonths.contains(anchor.month)) {
    return const <DateTime>[];
  }
  // BYDAY: drop unless the day's weekday is listed (ISO weekday, Mon=1..Sun=7).
  if (rule.byWeekDays.isNotEmpty &&
      !rule.byWeekDays.any((RecurWeekday d) => d.isoWeekday == anchor.weekday)) {
    return const <DateTime>[];
  }
  // BYMONTHDAY: drop unless the day-of-month is in the resolved set (which
  // expands negatives like -1 to the actual last day for this month/year).
  if (rule.byMonthDays.isNotEmpty &&
      !_resolvedDays(rule, anchor.year, anchor.month).contains(anchor.day)) {
    return const <DateTime>[];
  }
  // Passed every active filter: emit the day, carrying [start]'s time-of-day.
  return <DateTime>[_dateWith(start, anchor.year, anchor.month, anchor.day)];
}

/// WEEKLY: each BYDAY weekday within the anchor's week (BYDAY empty → the start's
/// weekday), positioned relative to WKST, then BYMONTH-filtered and sorted.
/// Audited: 2026-06-12 11:26 EDT
List<DateTime> _weeklyCandidates(RecurrenceRule rule, DateTime start, DateTime anchor) {
  final List<RecurWeekday> days = rule.byWeekDays.isEmpty
      ? <RecurWeekday>[RecurWeekday.values[start.weekday - 1]]
      : rule.byWeekDays;
  final DateTime weekStart = _weekStartDate(anchor, rule.weekStart);
  final List<DateTime> out = <DateTime>[];
  for (final RecurWeekday day in days) {
    final int offset = (day.isoWeekday - rule.weekStart.isoWeekday + 7) % 7;
    final DateTime date = _addDays(weekStart, offset);
    if (rule.byMonths.isEmpty || rule.byMonths.contains(date.month)) {
      out.add(date);
    }
  }
  return out..sort();
}

/// MONTHLY: each BYMONTHDAY in the anchor's month (empty → the start's day),
/// dropping days that don't exist that month, BYMONTH-filtered and sorted.
/// Audited: 2026-06-12 11:26 EDT
List<DateTime> _monthlyCandidates(RecurrenceRule rule, DateTime start, DateTime anchor) {
  if (rule.byMonths.isNotEmpty && !rule.byMonths.contains(anchor.month)) {
    return const <DateTime>[];
  }
  final List<DateTime> out = <DateTime>[
    for (final int day in _resolvedDays(rule, anchor.year, anchor.month, fallback: start.day))
      _dateWith(start, anchor.year, anchor.month, day),
  ];
  return out..sort();
}

/// YEARLY: the cross product of BYMONTH (empty → start's month) and BYMONTHDAY
/// (empty → start's day) within the anchor's year, invalid days dropped, sorted.
/// Audited: 2026-06-12 11:26 EDT
List<DateTime> _yearlyCandidates(RecurrenceRule rule, DateTime start, DateTime anchor) {
  final List<int> months = rule.byMonths.isEmpty ? <int>[start.month] : rule.byMonths;
  final List<DateTime> out = <DateTime>[];
  for (final int month in months) {
    for (final int day in _resolvedDays(rule, anchor.year, month, fallback: start.day)) {
      out.add(_dateWith(start, anchor.year, month, day));
    }
  }
  return out..sort();
}

/// Resolves BYMONTHDAY entries (or [fallback] when BYMONTHDAY is empty) to real
/// day numbers for [year]/[month], discarding any that don't exist that month.
/// Negative entries count from the month end (-1 = last day).
/// Audited: 2026-06-12 11:26 EDT
Iterable<int> _resolvedDays(RecurrenceRule rule, int year, int month, {int? fallback}) {
  final List<int> raw = rule.byMonthDays.isEmpty
      ? <int>[if (fallback != null) fallback]
      : rule.byMonthDays;
  final int lastDay = DateTime(year, month + 1, 0).day;
  return raw.map((int r) => _resolveDay(r, lastDay)).whereType<int>();
}

/// Maps one BYMONTHDAY value to a 1..[lastDay] day, or null if it falls outside
/// the month (e.g. day 31 in a 30-day month, or a negative beyond the start).
/// Audited: 2026-06-12 11:26 EDT
int? _resolveDay(int raw, int lastDay) {
  if (raw > 0) {
    return raw <= lastDay ? raw : null;
  }
  final int fromEnd = lastDay + 1 + raw;
  return fromEnd >= 1 ? fromEnd : null;
}

/// The date of the WKST-aligned start of the week containing [date].
/// Audited: 2026-06-12 11:26 EDT
DateTime _weekStartDate(DateTime date, RecurWeekday weekStart) {
  final int back = (date.weekday - weekStart.isoWeekday + 7) % 7;
  return _addDays(date, -back);
}

/// Builds a date at [year]/[month]/[day] carrying [reference]'s time-of-day and
/// UTC-ness, so every occurrence keeps the start instant's clock and zone.
/// Audited: 2026-06-12 11:26 EDT
DateTime _dateWith(DateTime reference, int year, int month, int day) {
  if (reference.isUtc) {
    return DateTime.utc(
      year,
      month,
      day,
      reference.hour,
      reference.minute,
      reference.second,
      reference.millisecond,
      reference.microsecond,
    );
  }
  return DateTime(
    year,
    month,
    day,
    reference.hour,
    reference.minute,
    reference.second,
    reference.millisecond,
    reference.microsecond,
  );
}

/// Shifts [date] by [days], preserving its time-of-day and UTC-ness. Built from
/// calendar fields (not a `Duration`) so it never drifts across a DST boundary.
/// Audited: 2026-06-12 11:26 EDT
DateTime _addDays(DateTime date, int days) =>
    _dateWith(date, date.year, date.month, date.day + days);
