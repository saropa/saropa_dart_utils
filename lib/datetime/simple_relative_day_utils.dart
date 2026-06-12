/// Calendar-day relative classification (`Today` / `Yesterday` / `Next Tuesday`
/// / `Last Month`) — pure-Dart, locale-free, with a `null` escape hatch for
/// dates outside a ~2-month window.
library;

// The public result types ([SimpleRelativeDay], [RelativeDayResult]) live in a
// part so each file stays under the project's 200-line cap while the classifier
// keeps direct access to them and to the private [_toDateOnly] helper below
// (parts share one library scope, so nothing here needs to be made public to
// split the file).
part 'simple_relative_day_types.dart';

/// Normalizes a [DateTime] to UTC midnight on its calendar date.
///
/// The result is always a UTC value built from the receiver's year/month/day,
/// so two normalized dates are always an exact multiple of 24 hours apart and
/// `Duration.inDays` returns the true calendar-day count. Building LOCAL
/// midnights instead would break across a DST boundary: a local spring-forward
/// day is only 23 hours, so `inDays` would truncate a one-calendar-day gap to
/// zero (Mar 10 → Mar 11 2024 in a US zone). Reading only the calendar fields
/// also makes the delta independent of the receiver's UTC-vs-local kind, so a
/// kind mismatch no longer shifts the day count by the zone offset.
/// Audited: 2026-06-12 11:26 EDT
DateTime _toDateOnly(DateTime value) => DateTime.utc(value.year, value.month, value.day);

/// Classifies a [DateTime] into a [SimpleRelativeDay] bucket relative to `now`.
extension DateTimeSimpleRelativeDayExtension on DateTime {
  /// Returns the [SimpleRelativeDay] bucket for this date relative to [now].
  ///
  /// [now] defaults to [DateTime.now] when omitted. Returns `null` when the
  /// date is outside the classifiable ~2-month window (same calendar month but
  /// beyond ±2 weeks, or more than one calendar month away) — there is no
  /// useful single relative label for such dates.
  ///
  /// Time-of-day is dropped, so the result reflects calendar days. Pass [now]
  /// and the receiver as the same UTC/local kind: a kind mismatch shifts the
  /// day delta by the zone offset and can misbucket a boundary date.
  ///
  /// Example:
  /// ```dart
  /// final DateTime now = DateTime(2024, 12, 29);
  /// DateTime(2024, 12, 28).getSimpleRelativeDay(now: now); // yesterday
  /// DateTime(2024, 11, 15).getSimpleRelativeDay(now: now); // lastMonth
  /// DateTime(2025, 3, 15).getSimpleRelativeDay(now: now);  // null
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  SimpleRelativeDay? getSimpleRelativeDay({DateTime? now}) => getRelativeDayResult(now: now)?.type;

  /// Returns the full [RelativeDayResult] (bucket plus optional weekday name)
  /// for this date relative to [now].
  ///
  /// [now] defaults to [DateTime.now] when omitted. [weekdayFormatter] is the
  /// caller-supplied label source for the weekday buckets — the library stays
  /// `intl`-free and never touches app locale state by delegating the weekday
  /// string to the caller. When the bucket is not a weekday bucket the
  /// formatter is never called, so a `null` formatter is safe for all other
  /// buckets. Returns `null` for dates outside the classifiable window
  /// (see [getSimpleRelativeDay]).
  ///
  /// A throwing [weekdayFormatter] propagates: the library does not swallow it,
  /// so a caller's locale failure surfaces rather than silently yielding a
  /// weekday bucket with a `null` name.
  ///
  /// Example:
  /// ```dart
  /// final DateTime now = DateTime(2024, 12, 29); // Sunday
  /// final RelativeDayResult? r = DateTime(2025, 1, 1).getRelativeDayResult(
  ///   now: now,
  ///   weekdayFormatter: (d) => 'Wednesday',
  /// );
  /// r?.type;        // nextWeekday
  /// r?.weekdayName; // 'Wednesday'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  RelativeDayResult? getRelativeDayResult({
    DateTime? now,
    String Function(DateTime)? weekdayFormatter,
  }) {
    final DateTime today = _toDateOnly(now ?? DateTime.now());
    final DateTime dateOnly = _toDateOnly(this);

    // Whole calendar days: both operands are UTC midnight, so they are an exact
    // multiple of 24 hours apart and a DST "short day" cannot truncate the
    // count (see _toDateOnly for why local midnights would misreport here).
    final int daysDiff = dateOnly.difference(today).inDays;

    // Ordered cheapest-first: the exact single-day buckets and the named
    // weekday window never touch month math; the month boundary is the last
    // resort. The first non-null wins, so the buckets stay mutually exclusive.
    return _exactBucket(daysDiff) ??
        _weekdayWindowBucket(daysDiff, dateOnly, weekdayFormatter) ??
        _monthBucket(dateOnly, today);
  }

  /// Maps the four single-day offsets that need no weekday name, else `null`.
  ///
  /// Split out so [getRelativeDayResult] stays within the project's per-function
  /// length limit and so the cheap exact matches are checked before the more
  /// expensive weekday/month logic runs.
  /// Audited: 2026-06-12 11:26 EDT
  RelativeDayResult? _exactBucket(int daysDiff) {
    // Ordered nearest-first; each offset is mutually exclusive by construction.
    switch (daysDiff) {
      case 0:
        return const RelativeDayResult(SimpleRelativeDay.today);
      case 1:
        return const RelativeDayResult(SimpleRelativeDay.tomorrow);
      case -1:
        return const RelativeDayResult(SimpleRelativeDay.yesterday);
      case 2:
        return const RelativeDayResult(SimpleRelativeDay.afterTomorrow);
      case -2:
        return const RelativeDayResult(SimpleRelativeDay.beforeYesterday);
      default:
        return null;
    }
  }

  /// Maps the ±3..±13 named-weekday window, else `null` so the caller falls
  /// through to the month boundary.
  ///
  /// The weekday string is computed only inside this window and at most once, so
  /// a `null` formatter never runs for the exact/month buckets and a throwing
  /// formatter only fires when a weekday label was genuinely requested.
  /// Audited: 2026-06-12 11:26 EDT
  RelativeDayResult? _weekdayWindowBucket(
    int daysDiff,
    DateTime dateOnly,
    String Function(DateTime)? weekdayFormatter,
  ) {
    // Three through thirteen days ahead collapse to a single named-weekday
    // bucket. The original source split this span into two adjacent ranges that
    // both produced the same bucket; unifying them is a no-op simplification.
    if (daysDiff >= 3 && daysDiff <= 13) {
      return RelativeDayResult(
        SimpleRelativeDay.nextWeekday,
        weekdayName: weekdayFormatter?.call(dateOnly),
      );
    }
    if (daysDiff <= -3 && daysDiff >= -13) {
      return RelativeDayResult(
        SimpleRelativeDay.lastWeekday,
        weekdayName: weekdayFormatter?.call(dateOnly),
      );
    }

    return null;
  }

  /// Maps the ±1 calendar-month boundary, else `null`.
  ///
  /// The month delta folds the year into the count so a December-to-January
  /// rollover yields positive one rather than negative eleven; a bare
  /// month-number subtraction would misclassify every cross-year pair. A zero
  /// delta (same month, beyond the two-week window) and any delta of two or
  /// more months both return `null`: there is no compact relative label for
  /// those, so the caller can fall back to an absolute date.
  /// Audited: 2026-06-12 11:26 EDT
  RelativeDayResult? _monthBucket(DateTime dateOnly, DateTime today) {
    final int monthDiff = (dateOnly.year - today.year) * 12 + dateOnly.month - today.month;

    if (monthDiff == 1) {
      return const RelativeDayResult(SimpleRelativeDay.nextMonth);
    }
    if (monthDiff == -1) {
      return const RelativeDayResult(SimpleRelativeDay.lastMonth);
    }

    return null;
  }
}
