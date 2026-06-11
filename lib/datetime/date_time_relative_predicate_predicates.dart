part of 'date_time_relative_predicate_extensions.dart';

/// Calendar-day predicates and a descriptive relative-time formatter on
/// [DateTime].
///
/// The four predicates ([isTomorrow], [isYesterday], [isOlderThanToday],
/// [isOlderThanYesterday]) and [relativeTime] each accept an optional `now`
/// reference (defaulting to [DateTime.now]) so callers can pin a deterministic
/// clock in tests instead of mutating global time.
///
/// Note the two predicate families treat time zones differently and this is
/// intentional: [isTomorrow] / [isYesterday] compare on calendar fields via
/// [DateTimeComparisonExtensions.isSameDateOnly] (so a UTC receiver and a local
/// `now` are compared by their displayed year/month/day, ignoring the offset),
/// while [isOlderThanToday] / [isOlderThanYesterday] use the instant comparison
/// [DateTime.isBefore] (which is offset-aware). Mixing UTC and local across the
/// two families therefore yields different answers — pass a `now` in the same
/// zone as the receiver to keep results unambiguous.
extension RelativeTimeUtils on DateTime {
  /// Returns `true` if this [DateTime] is the calendar day after [now].
  ///
  /// Compares date-only (year/month/day), so the time component is irrelevant:
  /// `23:59` on the next day still counts as tomorrow. Pass [now] to pin the
  /// clock for deterministic tests.
  ///
  /// Not DST-safe across a transition: `now.add(Duration(days: 1))` advances a
  /// fixed 24h, so on a "spring forward" (23h) or "fall back" (25h) local day
  /// the resulting wall-clock date can land on the wrong calendar day.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime(2024, 6, 15);
  /// DateTime(2024, 6, 16).isTomorrow(now: now); // true
  /// DateTime(2024, 6, 15).isTomorrow(now: now); // false
  /// ```
  @useResult
  bool isTomorrow({DateTime? now}) {
    final DateTime tomorrow = (now ?? DateTime.now()).add(const Duration(days: 1));

    return isSameDateOnly(tomorrow);
  }

  /// Returns `true` if this [DateTime] is the calendar day before [now].
  ///
  /// Compares date-only (year/month/day), so the time component is irrelevant:
  /// `00:01` on the prior day still counts as yesterday. Pass [now] to pin the
  /// clock for deterministic tests.
  ///
  /// Not DST-safe across a transition (see [isTomorrow]): the fixed 24h shift
  /// can land on the wrong calendar day on a "spring forward" / "fall back"
  /// local day.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime(2024, 3, 1);
  /// DateTime(2024, 2, 29).isYesterday(now: now); // true (leap day)
  /// ```
  @useResult
  bool isYesterday({DateTime? now}) {
    final DateTime yesterday = (now ?? DateTime.now()).subtract(const Duration(days: 1));

    return isSameDateOnly(yesterday);
  }

  /// Returns `true` if this [DateTime] is strictly before the start of today
  /// (midnight at the beginning of [now]'s calendar day).
  ///
  /// The boundary is exclusive: the exact start-of-today instant
  /// (`00:00:00.000`) returns `false`; one microsecond earlier returns `true`.
  /// Any time later in today also returns `false`. Pass [now] to pin the clock.
  ///
  /// Uses the offset-aware [DateTime.isBefore] (instant comparison), unlike the
  /// field-based [isYesterday] / [isTomorrow] — see the extension-level note on
  /// mixing UTC and local receivers.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime(2024, 6, 15, 12);
  /// DateTime(2024, 6, 14).isOlderThanToday(now: now);        // true
  /// DateTime(2024, 6, 15, 8).isOlderThanToday(now: now);     // false
  /// ```
  @useResult
  bool isOlderThanToday({DateTime? now}) {
    final DateTime resolvedNow = now ?? DateTime.now();

    // Midnight at the start of now's day; any instant before it is "older than
    // today". Building the boundary from fields drops the time-of-day of now.
    final DateTime startOfToday = DateTime(
      resolvedNow.year,
      resolvedNow.month,
      resolvedNow.day,
    );

    return isBefore(startOfToday);
  }

  /// Returns `true` if this [DateTime] is strictly before the start of
  /// yesterday (midnight at the beginning of the day before [now]).
  ///
  /// The boundary is exclusive: the exact start-of-yesterday instant returns
  /// `false` (it is yesterday, not older than yesterday); the entirety of
  /// yesterday and today also return `false`. Pass [now] to pin the clock.
  ///
  /// Uses the offset-aware [DateTime.isBefore] (instant comparison) — see the
  /// extension-level note on mixing UTC and local receivers.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime(2024, 6, 15, 12);
  /// DateTime(2024, 6, 13).isOlderThanYesterday(now: now); // true
  /// DateTime(2024, 6, 14).isOlderThanYesterday(now: now); // false (yesterday)
  /// ```
  @useResult
  bool isOlderThanYesterday({DateTime? now}) {
    final DateTime resolvedNow = now ?? DateTime.now();

    final DateTime startOfToday = DateTime(
      resolvedNow.year,
      resolvedNow.month,
      resolvedNow.day,
    );

    // Subtracting a day from a midnight boundary is DST-safe here because the
    // comparison is by instant, not by wall-clock field, so a 23h/25h local day
    // cannot move the boundary onto the wrong side of the receiver.
    final DateTime startOfYesterday = startOfToday.subtract(const Duration(days: 1));

    return isBefore(startOfYesterday);
  }
}
