part of 'date_time_relative_predicate_extensions.dart';

/// Descriptive relative-time formatting on [DateTime].
///
/// Companion to [RelativeTimeUtils]; kept in a separate extension only so each
/// source file stays within the project's file-length limit. The callable
/// surface ([relativeTime] on any [DateTime]) is unchanged from when this lived
/// alongside the calendar-day predicates.
extension RelativeTimeFormatUtils on DateTime {
  /// Returns an English relative-time phrase between this [DateTime] and [now]
  /// (defaults to [DateTime.now]).
  ///
  /// - [isDescriptive] — verbose phrasing (`"a moment"`, `"about an hour"`,
  ///   `"5 minutes"`) when `true`; terse tokens (`"now"`, `"~1h"`, `"5 min"`)
  ///   when `false`.
  /// - [isDescriptiveTimeSuffix] — append [relativeTimeSuffixPast] /
  ///   [relativeTimeSuffixFuture] (`"ago"` / `"from now"`) when `true`.
  /// - [roundUp] — round the numeric unit (`89.6 min` → `2 hr` band-permitting)
  ///   instead of flooring.
  ///
  /// Year-level spans use date-based calendar arithmetic (subtract years, back
  /// off one if the anniversary has not yet passed) rather than `days / 365.25`
  /// to avoid off-by-one errors near anniversary boundaries.
  ///
  /// Returns `null` only on the degenerate path where every band produces an
  /// empty string; for ordinary inputs a non-empty phrase is always returned.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime(2024, 6, 15, 12);
  /// DateTime(2024, 6, 15, 11, 55).relativeTime(now: now); // "5 minutes ago"
  /// DateTime(2024, 6, 20).relativeTime(now: DateTime(2024, 6, 15));
  /// //                                                    // "5 days from now"
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String? relativeTime({
    DateTime? now,
    bool isDescriptive = true,
    bool isDescriptiveTimeSuffix = true,
    bool roundUp = false,
  }) {
    // Exact-instant short-circuit must run before defaulting now, so that the
    // documented `this == now` contract holds even when now is passed null.
    if (this == now) {
      return relativeNowTime;
    }

    // Resolve once into a local (not a param reassignment) so a clock tick
    // mid-computation cannot shift the bucket and the original arg is preserved.
    final DateTime resolvedNow = now ?? DateTime.now();

    // Millisecond granularity; microsecond ties are intentionally ignored.
    final int signedElapsed = millisecondsSinceEpoch - resolvedNow.millisecondsSinceEpoch;

    // isBefore (not `signedElapsed < 0`) keeps direction correct at microsecond
    // ties where the millisecond delta can be zero yet the instants still differ.
    final bool isPast = isBefore(resolvedNow);
    final int elapsed = isPast ? signedElapsed.abs() : signedElapsed;

    final String? body = _relativePhraseBody(
      from: this,
      now: resolvedNow,
      elapsed: elapsed,
      isPast: isPast,
      isDescriptive: isDescriptive,
      roundUp: roundUp,
    );

    // Guard before interpolating: only the degenerate empty-band path is null.
    if (body == null || body.isEmpty) {
      return null;
    }

    if (isDescriptiveTimeSuffix) {
      return '$body ${isPast ? relativeTimeSuffixPast : relativeTimeSuffixFuture}';
    }

    return body;
  }
}

/// Builds the (suffix-free) relative phrase, choosing the calendar-year
/// algorithm for year-level spans and falling back to the bucketed
/// [_relativeTimeMessage] otherwise. Split out of
/// [RelativeTimeFormatUtils.relativeTime] to keep that method within the
/// function-length limit.
/// Audited: 2026-06-12 11:26 EDT
String? _relativePhraseBody({
  required DateTime from,
  required DateTime now,
  required int elapsed,
  required bool isPast,
  required bool isDescriptive,
  required bool roundUp,
}) {
  // Year spans use date-based arithmetic instead of days/365.25 to avoid
  // off-by-one errors near anniversary boundaries.
  final num days = elapsed / 1000 / 60 / 60 / 24;
  if (days >= 365) {
    final String? years = _relativeYearMessage(
      fromDate: isPast ? from : now,
      toDate: isPast ? now : from,
      isDescriptive: isDescriptive,
    );
    if (years != null) {
      return years;
    }
  }

  return _relativeTimeMessage(
    elapsed: elapsed,
    isDescriptive: isDescriptive,
    roundUp: roundUp,
  );
}

/// Whole years between two dates using calendar arithmetic: subtract years,
/// then back off one if the anniversary has not yet occurred in [toDate]'s
/// year. Returns `null` for sub-year spans so the caller falls through to the
/// bucketed message (this is the off-by-one fix the date-based path exists for).
/// Audited: 2026-06-12 11:26 EDT
String? _relativeYearMessage({
  required DateTime fromDate,
  required DateTime toDate,
  bool isDescriptive = true,
}) {
  int years = toDate.year - fromDate.year;

  // The anniversary in toDate's year has not arrived yet when toDate's
  // month/day precedes fromDate's — so one fewer whole year has elapsed.
  if (toDate.month < fromDate.month ||
      (toDate.month == fromDate.month && toDate.day < fromDate.day)) {
    years--;
  }

  if (years < 1) {
    return null;
  }

  if (years == 1) {
    return isDescriptive ? 'about a year' : '~1y';
  }

  // Terse abbreviations are never pluralized ("3 y", not "3 ies"); only the
  // descriptive word takes a plural suffix.
  final String unit = isDescriptive ? 'year'.pluralize(years) : 'y';

  return '$years $unit';
}

/// Maps an absolute [elapsed] millisecond span to a bucketed English phrase
/// (seconds → minutes → hours → days → months → years). Bands are split into
/// small helpers below to stay within the function-length limit; the threshold
/// ladder and "about a …" cusps are preserved exactly.
/// Audited: 2026-06-12 11:26 EDT
String _relativeTimeMessage({
  required int elapsed,
  bool isDescriptive = true,
  bool roundUp = false,
}) {
  final num seconds = elapsed / 1000;

  final String? sub = _relativeSubMinuteMessage(seconds, isDescriptive);
  if (sub != null) {
    return sub;
  }

  final num minutes = seconds / 60;

  final String? subHour = _relativeMinuteMessage(minutes, isDescriptive, roundUp);
  if (subHour != null) {
    return subHour;
  }

  final num hours = minutes / 60;

  final String? subDay = _relativeHourMessage(hours, isDescriptive, roundUp);
  if (subDay != null) {
    return subDay;
  }

  return _relativeDayMessage(hours / 24, isDescriptive, roundUp);
}
