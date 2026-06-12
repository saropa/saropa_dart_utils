/// Human-readable text for a simple recurrence rule — roadmap #599.
///
/// Turns a [RecurrenceSpec] (frequency + interval + optional day/week/month
/// fields) into a short English phrase such as "every 2 weeks on Tuesday" or
/// "every 2nd Tuesday of the month", for display next to a schedule.
///
/// The output is fixed library English, NOT app-facing i18n copy: these strings
/// describe the data model itself, so plain English literals belong here and are
/// not routed through any translation catalog. Weekday/month numbering follows
/// the `DateTime` convention (1 = Monday .. 7 = Sunday; month 1 = January).
library;

import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';

/// How often a recurrence repeats; the unit the [RecurrenceSpec.interval]
/// multiplies.
enum RecurrenceFrequency {
  /// Repeats every N days.
  daily,

  /// Repeats every N weeks, optionally on a named weekday.
  weekly,

  /// Repeats every N months, on a month-day or an nth weekday-of-month.
  monthly,

  /// Repeats every N years, optionally on a fixed month + day.
  yearly,
}

/// An immutable description of a simple recurrence. Only the fields relevant to
/// [frequency] are read by [humanizeRecurrence]; the others may stay `null`.
@immutable
class RecurrenceSpec {
  /// Creates a spec. [interval] is the "every N" multiplier (default 1) and must
  /// be >= 1 — a zero or negative interval has no meaning ("every 0 days").
  ///
  /// Validation is an initializer-list `assert` (matching the sibling value
  /// types `OpenWindow`/`QuietWindow`): throwing from the constructor body would
  /// leave a partially built object, so a bad interval is treated as a
  /// programming error caught in debug rather than a recoverable runtime fault.
  const RecurrenceSpec(
    this.frequency, {
    this.interval = 1,
    this.weekday,
    this.weekOfMonth,
    this.monthDay,
    this.month,
  }) : assert(interval >= 1, 'interval must be >= 1');

  /// The repeat unit (daily/weekly/monthly/yearly).
  final RecurrenceFrequency frequency;

  /// The "every N" multiplier; 1 means every single unit.
  final int interval;

  /// Weekday for weekly / nth-weekday recurrences (1 = Monday .. 7 = Sunday),
  /// or `null` when the recurrence has no weekday component.
  final int? weekday;

  /// Which occurrence of [weekday] within the month (1..5 for "2nd Tuesday"),
  /// or `null` for a plain weekly recurrence.
  final int? weekOfMonth;

  /// Day of month (1..31) for monthly-by-date or yearly recurrences, or `null`.
  final int? monthDay;

  /// Month (1..12) for yearly recurrences, or `null`.
  final int? month;
}

/// A short English phrase describing [spec], e.g. "every 2 weeks on Tuesday".
///
/// The phrasing per frequency:
/// - daily: "every day" / "every 2 days"
/// - weekly: "weekly on Monday" / "every 2 weeks on Tuesday" (drops the "on …"
///   when [RecurrenceSpec.weekday] is null)
/// - monthly: "monthly on the 15th" (by [RecurrenceSpec.monthDay]) or
///   "every 2nd Tuesday of the month" (by week-of-month + weekday)
/// - yearly: "yearly on March 5" (by [RecurrenceSpec.month] + monthDay)
///
/// Example:
/// ```dart
/// humanizeRecurrence(
///   RecurrenceSpec(RecurrenceFrequency.weekly, interval: 2, weekday: DateTime.tuesday),
/// ); // 'every 2 weeks on Tuesday'
/// ```
String humanizeRecurrence(RecurrenceSpec spec) {
  // Dispatch on frequency; each branch reads only the fields it needs.
  switch (spec.frequency) {
    case RecurrenceFrequency.daily:
      return _everyUnit(spec.interval, 'day', 'days');
    case RecurrenceFrequency.weekly:
      return _weekly(spec);
    case RecurrenceFrequency.monthly:
      return _monthly(spec);
    case RecurrenceFrequency.yearly:
      return _yearly(spec);
  }
}

/// "every <singular>" for interval 1, otherwise "every N <plural>".
String _everyUnit(int interval, String singular, String plural) =>
    interval == 1 ? 'every $singular' : 'every $interval $plural';

/// Weekly phrasing, appending " on <Weekday>" only when a weekday is set.
String _weekly(RecurrenceSpec spec) {
  // "weekly" reads better than "every week" for the interval-1 case.
  final String base = spec.interval == 1 ? 'weekly' : 'every ${spec.interval} weeks';
  final String? dayName = WeekdayUtils.getDayLongName(spec.weekday);
  return dayName == null ? base : '$base on $dayName';
}

/// Monthly phrasing: nth-weekday-of-month when both week + weekday are present,
/// otherwise by month-day, otherwise the bare interval phrase.
String _monthly(RecurrenceSpec spec) {
  final String? dayName = WeekdayUtils.getDayLongName(spec.weekday);

  // "every 2nd Tuesday of the month" needs both the ordinal week and a weekday.
  if (spec.weekOfMonth != null && dayName != null) {
    return 'every ${_ordinal(spec.weekOfMonth!)} $dayName of the month';
  }
  final int? monthDay = spec.monthDay;
  if (monthDay != null) {
    final String base = spec.interval == 1 ? 'monthly' : 'every ${spec.interval} months';
    return '$base on the ${_ordinal(monthDay)}';
  }
  return _everyUnit(spec.interval, 'month', 'months');
}

/// Yearly phrasing "yearly on <Month> <day>", falling back to the bare interval
/// phrase when the month is missing.
String _yearly(RecurrenceSpec spec) {
  final int? month = spec.month;
  final int? monthDay = spec.monthDay;
  // getMonthLongName takes a non-null month, so guard before looking it up.
  final String? monthName = month == null ? null : MonthUtils.getMonthLongName(month);
  if (monthName == null || monthDay == null) {
    return _everyUnit(spec.interval, 'year', 'years');
  }
  final String base = spec.interval == 1 ? 'yearly' : 'every ${spec.interval} years';
  return '$base on $monthName $monthDay';
}

/// English ordinal for [n] (1 -> "1st", 2 -> "2nd", 3 -> "3rd", 11 -> "11th",
/// 21 -> "21st"). The 11/12/13 exception always takes "th" regardless of the
/// last digit, which is why the teens are checked before the ones digit.
String _ordinal(int n) {
  final int lastTwo = n % 100;
  // 11th, 12th, 13th are irregular and override the ones-digit rule below.
  if (lastTwo >= 11 && lastTwo <= 13) {
    return '${n}th';
  }
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}
