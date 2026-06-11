part of 'simple_relative_day_utils.dart';

/// Human-relative calendar-day buckets produced by [getSimpleRelativeDay].
///
/// Each value names one calendar-day relationship between a date and a
/// reference `now`, measured in whole calendar days (time-of-day dropped).
/// The classifier covers BOTH past and future at single-day resolution and
/// returns `null` (no enum value) when the date is more than ~2 months away,
/// so callers get a typed label only when one is actually useful.
///
/// Only the values listed here are ever returned. There are deliberately no
/// `ThisWeek` / `ThisMonth` / coarse-week members: the spec's source carried
/// four such values that the classifier never emitted, and silently shipping
/// unreachable enum cases would mislead `switch` authors into writing dead
/// arms. They were dropped at inclusion time — see the package notes.
///
/// Example:
/// ```dart
/// final DateTime now = DateTime(2024, 12, 29);
/// DateTime(2024, 12, 29).getSimpleRelativeDay(now: now); // Today
/// DateTime(2024, 12, 30).getSimpleRelativeDay(now: now); // Tomorrow
/// DateTime(2025, 1, 1).getSimpleRelativeDay(now: now);   // NextWeekday
/// DateTime(2025, 6, 15).getSimpleRelativeDay(now: now);  // null (too far)
/// ```
enum SimpleRelativeDay {
  /// The date is the same calendar day as `now`.
  today,

  /// The date is exactly one calendar day before `now`.
  yesterday,

  /// The date is exactly one calendar day after `now`.
  tomorrow,

  /// The date is exactly two calendar days before `now`
  /// (the day before yesterday).
  beforeYesterday,

  /// The date is exactly two calendar days after `now`
  /// (the day after tomorrow).
  afterTomorrow,

  /// The date is a named weekday in the past, 3–13 calendar days before `now`
  /// (e.g. "Last Tuesday"). Pair with [RelativeDayResult.weekdayName].
  lastWeekday,

  /// The date is a named weekday in the future, 3–13 calendar days after `now`
  /// (e.g. "Next Tuesday"). Pair with [RelativeDayResult.weekdayName].
  nextWeekday,

  /// The date falls in the previous calendar month relative to `now`.
  lastMonth,

  /// The date falls in the next calendar month relative to `now`.
  nextMonth,
}

/// Outcome of a relative-day classification: the [type] bucket plus an optional
/// [weekdayName] for the [SimpleRelativeDay.lastWeekday] /
/// [SimpleRelativeDay.nextWeekday] buckets.
///
/// [weekdayName] is non-null only when the caller supplied a `weekdayFormatter`
/// to [DateTimeSimpleRelativeDayExtension.getRelativeDayResult] AND the bucket
/// is a weekday bucket. For all exact buckets (`today`, `tomorrow`, …) and for
/// `lastMonth` / `nextMonth`, [weekdayName] is `null` — the formatter is never
/// invoked for those, so callers never pay for a label they cannot use.
///
/// Example:
/// ```dart
/// const RelativeDayResult(SimpleRelativeDay.today);                    // weekdayName == null
/// RelativeDayResult(SimpleRelativeDay.nextWeekday, weekdayName: 'Friday');
/// ```
class RelativeDayResult {
  /// Creates a result for the given [type], with an optional [weekdayName]
  /// that callers attach only for the weekday buckets.
  const RelativeDayResult(this.type, {this.weekdayName});

  /// The classified calendar-day bucket.
  final SimpleRelativeDay type;

  /// Locale-formatted weekday string for weekday buckets, else `null`.
  ///
  /// Supplied verbatim from the caller's `weekdayFormatter`; the library never
  /// formats it itself, so this util stays free of `intl` and app locale state.
  final String? weekdayName;
}
