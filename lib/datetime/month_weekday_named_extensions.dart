import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/month_weekday_utils.dart';

/// Named `(year, month)`-keyed calendar helpers for the exact phrasings that
/// daylight-saving and public-holiday rule tables are written in — "2nd Sunday
/// of March", "last Sunday of October", "3rd Monday" — plus February's
/// leap-aware day count and month-boundary days.
///
/// These are a thin, readability-focused layer over [MonthWeekdayUtils]: the
/// core occurrence algorithm already lives there, so this class only adds the
/// named wrappers that read like the rules themselves at the call site instead
/// of forcing a reader to decode `nthWeekdayOfMonth(y, m, 2, DateTime.sunday)`.
///
/// Nullability contract: every 1st/2nd/3rd/4th occurrence and every `last*`
/// occurrence is **non-null** — every weekday occurs at least four times in a
/// month and a "last" always exists, so these can never be absent for a valid
/// 1..12 [month]. Only a genuinely-absent-able 5th occurrence is nullable, and
/// that case is served by [MonthWeekdayUtils.nthWeekdayOfMonth] directly rather
/// than a named wrapper. Callers feeding untrusted month integers should use
/// [MonthWeekdayUtils.nthWeekdayOfMonth] (null-returning) instead.
///
/// All results are LOCAL `DateTime` values at midnight (`.isUtc == false`); the
/// time-of-day is local 00:00, which matters to consumers doing tz-shifting DST
/// math.
///
/// Example:
/// ```dart
/// // US daylight-saving start = 2nd Sunday of March.
/// DayInMonthCalculations.secondSunday(2026, 3); // 2026-03-08
/// // EU/GB daylight-saving end = last Sunday of October.
/// DayInMonthCalculations.lastSunday(2026, 10); // 2026-10-25
/// ```
abstract final class DayInMonthCalculations {
  /// Number of days in February for [year] (28 or 29), leap-year aware.
  ///
  /// Uses the day-0-of-March trick: Dart normalizes day 0 of month 3 to the
  /// last day of February, whose `.day` is February's length. This is correct
  /// across the full Gregorian rule (÷4 leap, ÷100 common, ÷400 leap) and for
  /// year 0 and negative years, because it defers entirely to `DateTime`'s own
  /// calendar rather than re-implementing the leap-year test.
  ///
  /// Example:
  /// ```dart
  /// DayInMonthCalculations.daysInFebruary(2024); // 29 (leap)
  /// DayInMonthCalculations.daysInFebruary(1900); // 28 (century, not ÷400)
  /// ```
  @useResult
  static int daysInFebruary(int year) => DateTime(year, 3, 0).day;

  /// First calendar day of [month] in [year] at local midnight.
  ///
  /// A trivial `DateTime(year, month, 1)`, named so DST/holiday code reads as a
  /// month-boundary intent rather than a bare constructor call. [month] is
  /// 1..12; an out-of-range [month] is normalized by `DateTime` into a
  /// neighboring month, so only pass validated months. For example,
  /// `firstDayOfMonth(2024, 3)` is `DateTime(2024, 3, 1)`.
  @useResult
  static DateTime firstDayOfMonth(int year, int month) => DateTime(year, month);

  /// Last calendar day of [month] in [year] at local midnight.
  ///
  /// Computed as day 0 of the next month, which `DateTime` normalizes to this
  /// month's final day — handling 28/29/30/31 and the December roll-over
  /// (month + 1 = 13 normalizes to next January). [month] is 1..12.
  ///
  /// Example:
  /// ```dart
  /// DayInMonthCalculations.lastDay(2024, 2);  // 2024-02-29 (leap)
  /// DayInMonthCalculations.lastDay(2026, 12); // 2026-12-31 (month-13 path)
  /// ```
  @useResult
  static DateTime lastDay(int year, int month) => DateTime(year, month + 1, 0);

  // ---- Named ordinal-weekday wrappers (the additive readability layer) ----
  //
  // Each delegates to MonthWeekdayUtils.nthWeekdayOfMonth and asserts the
  // occurrence is present via the shared _required guard. The 1st..3rd of any
  // weekday is a calendar invariant (always exists), so a null here would mean
  // an invalid month slipped through — _required converts that into a loud
  // StateError rather than a downstream null-dereference far from the cause.

  /// 1st Monday of [month] in [year]. Always exists for a valid 1..12 [month].
  ///
  /// Example: `DayInMonthCalculations.firstMonday(2024, 1)` // 2024-01-01.
  @useResult
  static DateTime firstMonday(int year, int month) => _required(year, month, 1, DateTime.monday);

  /// 1st Thursday of [month] in [year]. Always exists for a valid [month].
  @useResult
  static DateTime firstThursday(int year, int month) =>
      _required(year, month, 1, DateTime.thursday);

  /// 1st Friday of [month] in [year]. Always exists for a valid [month].
  @useResult
  static DateTime firstFriday(int year, int month) => _required(year, month, 1, DateTime.friday);

  /// 1st Saturday of [month] in [year]. Always exists for a valid [month].
  @useResult
  static DateTime firstSaturday(int year, int month) =>
      _required(year, month, 1, DateTime.saturday);

  /// 1st Sunday of [month] in [year]. Always exists for a valid [month].
  ///
  /// Used by the US daylight-saving END rule (1st Sunday of November).
  @useResult
  static DateTime firstSunday(int year, int month) => _required(year, month, 1, DateTime.sunday);

  /// 2nd Monday of [month] in [year]. Always exists for a valid [month].
  @useResult
  static DateTime secondMonday(int year, int month) => _required(year, month, 2, DateTime.monday);

  /// 2nd Friday of [month] in [year]. Always exists for a valid [month].
  @useResult
  static DateTime secondFriday(int year, int month) => _required(year, month, 2, DateTime.friday);

  /// 2nd Saturday of [month] in [year]. Always exists for a valid [month].
  @useResult
  static DateTime secondSaturday(int year, int month) =>
      _required(year, month, 2, DateTime.saturday);

  /// 2nd Sunday of [month] in [year]. Always exists for a valid [month].
  ///
  /// Used by the US daylight-saving START rule (2nd Sunday of March).
  @useResult
  static DateTime secondSunday(int year, int month) => _required(year, month, 2, DateTime.sunday);

  /// 3rd Monday of [month] in [year]. Always exists for a valid [month].
  @useResult
  static DateTime thirdMonday(int year, int month) => _required(year, month, 3, DateTime.monday);

  /// 3rd Saturday of [month] in [year]. Always exists for a valid [month].
  ///
  /// Non-null: a 3rd occurrence is always present, so unlike the over-cautious
  /// nullable original this returns a plain `DateTime`, matching [thirdMonday].
  @useResult
  static DateTime thirdSaturday(int year, int month) =>
      _required(year, month, 3, DateTime.saturday);

  /// 3rd Sunday of [month] in [year]. Always exists for a valid [month].
  ///
  /// Non-null for the same reason as [thirdSaturday].
  @useResult
  static DateTime thirdSunday(int year, int month) => _required(year, month, 3, DateTime.sunday);

  // ---- Named last-weekday wrappers ----
  //
  // Delegate to MonthWeekdayUtils.lastWeekdayOfMonth, which is always non-null
  // (every weekday occurs at least four times a month). No null guard needed.

  /// Last Monday of [month] in [year]. Always exists.
  @useResult
  static DateTime lastMonday(int year, int month) =>
      MonthWeekdayUtils.lastWeekdayOfMonth(year, month, DateTime.monday);

  /// Last Thursday of [month] in [year]. Always exists.
  ///
  /// Used by the Egypt daylight-saving END rule (last Thursday of October).
  @useResult
  static DateTime lastThursday(int year, int month) =>
      MonthWeekdayUtils.lastWeekdayOfMonth(year, month, DateTime.thursday);

  /// Last Friday of [month] in [year]. Always exists.
  @useResult
  static DateTime lastFriday(int year, int month) =>
      MonthWeekdayUtils.lastWeekdayOfMonth(year, month, DateTime.friday);

  /// Last Saturday of [month] in [year]. Always exists.
  @useResult
  static DateTime lastSaturday(int year, int month) =>
      MonthWeekdayUtils.lastWeekdayOfMonth(year, month, DateTime.saturday);

  /// Last Sunday of [month] in [year]. Always exists.
  ///
  /// Used by the EU/GB daylight-saving rule (last Sunday of March and October).
  @useResult
  static DateTime lastSunday(int year, int month) =>
      MonthWeekdayUtils.lastWeekdayOfMonth(year, month, DateTime.sunday);

  /// Resolves the [n]th [weekday] of [month]/[year], asserting it exists.
  ///
  /// The named 1st/2nd/3rd wrappers above promise non-null because those
  /// occurrences are a calendar invariant. [MonthWeekdayUtils.nthWeekdayOfMonth]
  /// returns nullable (it also serves untrusted input and 5th-occurrence
  /// queries), so this collapses the safe nullable read into one explicit
  /// failure: a `null` can only mean [month] was out of 1..12, and throwing a
  /// named [StateError] here surfaces that bad argument at the call site rather
  /// than as an opaque null-dereference later.
  static DateTime _required(int year, int month, int n, int weekday) {
    final DateTime? result = MonthWeekdayUtils.nthWeekdayOfMonth(year, month, n, weekday);
    if (result == null) {
      throw StateError(
        'No occurrence $n of weekday $weekday in month $month — month must be '
        '${DateConstants.minMonth}..${DateConstants.maxMonth}.',
      );
    }
    return result;
  }
}
