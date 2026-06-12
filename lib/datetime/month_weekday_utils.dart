import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';

/// One day, used to step off a month boundary.
/// Audited: 2026-06-12 11:26 EDT
const Duration _oneDay = Duration(days: 1);

/// Static `(year, month)`-keyed weekday-occurrence helpers, the no-seed
/// counterpart to the `DateTime.getNthWeekdayOfMonthInYear` instance extension.
///
/// Calendar-construction code (DST rules, public-holiday tables) computes
/// occurrences for an arbitrary year/month pair and has no seed `DateTime` to
/// hang the instance method on; these statics take the year/month explicitly so
/// no throwaway `DateTime(year, month)` is needed at every call site.
abstract final class MonthWeekdayUtils {
  /// Returns the [n]th [weekday] in [month] of [year], or `null` when that
  /// occurrence does not exist (e.g. a 5th Friday in a month with only four).
  ///
  /// [n] is 1-based (1 = first). [month] is 1..12 and [weekday] is a
  /// `DateTime` weekday constant (1 = Monday .. 7 = Sunday). Out-of-range [n],
  /// [month], or [weekday] returns `null` rather than silently computing a
  /// neighboring month — these statics take untrusted calendar input, so an
  /// invalid argument must not produce a plausible-but-wrong date.
  ///
  /// Example:
  /// ```dart
  /// // 2nd Sunday of March 2026 (US daylight-saving start).
  /// MonthWeekdayUtils.nthWeekdayOfMonth(2026, 3, 2, DateTime.sunday);
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  static DateTime? nthWeekdayOfMonth(int year, int month, int n, int weekday) {
    // Guard explicitly: DateTime(year, month) would normalize an out-of-range
    // month into a different one, so the underlying extension's own
    // month-mismatch check could not catch it. Reject up front instead.
    if (n < 1 ||
        month < DateConstants.minMonth ||
        month > DateConstants.maxMonth ||
        weekday < DateTime.monday ||
        weekday > DateTime.sunday) {
      return null;
    }

    // Reuse the instance algorithm with a seed date for the requested month.
    return DateTime(year, month).getNthWeekdayOfMonthInYear(n, weekday);
  }

  /// Returns the last [weekday] in [month] of [year] — always a real date, since
  /// every weekday occurs at least four times a month.
  ///
  /// [month] is 1..12 and [weekday] is a `DateTime` weekday constant
  /// (1 = Monday .. 7 = Sunday).
  ///
  /// Example:
  /// ```dart
  /// // Last Sunday of October 2026 (EU daylight-saving end).
  /// MonthWeekdayUtils.lastWeekdayOfMonth(2026, 10, DateTime.sunday);
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  static DateTime lastWeekdayOfMonth(int year, int month, int weekday) {
    // Day 0 of the NEXT month is the last day of THIS month (handles 28/29/30/31
    // and the December roll-over, where month + 1 = 13 normalizes to January).
    final DateTime lastDayOfMonth = DateTime(year, month + 1).subtract(_oneDay);

    // Step back to the most recent matching weekday. The +7 keeps the modulus
    // non-negative when the month ends earlier in the week than [weekday].
    final int daysToSubtract =
        (lastDayOfMonth.weekday - weekday + DateConstants.daysPerWeek) % DateConstants.daysPerWeek;

    return lastDayOfMonth.subtract(Duration(days: daysToSubtract));
  }
}
