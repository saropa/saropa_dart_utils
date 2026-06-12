/// Monthly billing-anniversary math with end-of-month clamping — roadmap #609.
///
/// Answers "when does the subscription bill this month?", "what is the next
/// billing date on/after some instant?", and "which [start, end) cycle is a
/// given day inside?" for a fixed monthly anchor day (1..31).
///
/// The hard case is an anchor past a short month's length: anchor 31 cannot bill
/// on February 31. The rule here is LAST-DAY CLAMPING — the anchor is clamped
/// down to the month's final day (Feb -> 28 or 29, April -> 30), so the bill
/// always lands on a real date and never silently rolls into the next month the
/// way `DateTime(2024, 2, 31)` would. All values are local date-only (the time
/// component is dropped); callers working in a single zone get stable results.
library;

/// Validates the billing anchor day, throwing in release builds (unlike
/// `assert`, which the compiler strips, letting bad input through unchecked).
void _checkAnchor(int anchorDay) {
  if (anchorDay < 1 || anchorDay > 31) {
    throw ArgumentError.value(anchorDay, 'anchorDay', 'must be 1..31');
  }
}

/// Strips the time component, normalizing to local midnight on the same date.
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Number of days in [month] of [year]. Day 0 of the next month is the last day
/// of this month, which handles 28/29/30/31 and the December roll-over
/// (`month + 1 == 13` normalizes to the next January) without a leap-year table.
int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// The billing date for [anchorDay] within [month] of [year], with the anchor
/// CLAMPED to the month's length so it is always a real date.
///
/// For example anchor 31 yields Jan 31, Feb 28 (or 29 in a leap year), Apr 30.
/// [anchorDay] must be 1..31; out-of-range input is a programming error.
///
/// Example:
/// ```dart
/// // Anchor 31 in February 2024 (leap) clamps to the 29th.
/// billingDateInMonth(2024, 2, 31); // 2024-02-29
/// ```
DateTime billingDateInMonth(int year, int month, int anchorDay) {
  _checkAnchor(anchorDay);

  // Clamp the anchor down to the last day so a short month never overflows into
  // the following month (the failure DateTime(year, month, 31) would cause).
  final int lastDay = _daysInMonth(year, month);
  final int day = anchorDay < lastDay ? anchorDay : lastDay;
  return DateTime(year, month, day);
}

/// The next billing date strictly on or after the date part of [from] for
/// [anchorDay].
///
/// If [from]'s date is already the (clamped) billing day of its own month, that
/// same date is returned; otherwise the search advances to the next month whose
/// clamped anchor is on/after [from]. [anchorDay] must be 1..31.
///
/// Example:
/// ```dart
/// // Anchor 15, from the 20th -> next month's 15th.
/// nextBillingDate(DateTime(2026, 3, 20), 15); // 2026-04-15
/// ```
DateTime nextBillingDate(DateTime from, int anchorDay) {
  _checkAnchor(anchorDay);

  final DateTime fromDate = _dateOnly(from);
  final DateTime thisMonth = billingDateInMonth(fromDate.year, fromDate.month, anchorDay);

  // This month's billing date already satisfies "on or after from".
  if (!thisMonth.isBefore(fromDate)) {
    return thisMonth;
  }
  return billingDateInMonth(fromDate.year, fromDate.month + 1, anchorDay);
}

/// [count] consecutive monthly billing dates beginning with the next billing
/// date on/after [start], each clamped to its month's length.
///
/// [anchorDay] must be 1..31 and [count] must be >= 0 (a zero count yields an
/// empty list).
///
/// Example:
/// ```dart
/// // Three billings from Jan 31 2024, showing the Feb clamp.
/// billingSchedule(DateTime(2024, 1, 31), 31, 3);
/// // [2024-01-31, 2024-02-29, 2024-03-31]
/// ```
List<DateTime> billingSchedule(DateTime start, int anchorDay, int count) {
  _checkAnchor(anchorDay);
  if (count < 0) {
    throw ArgumentError.value(count, 'count', 'must be >= 0');
  }

  final List<DateTime> dates = <DateTime>[];
  DateTime current = nextBillingDate(start, anchorDay);

  // Step a whole calendar month each iteration by re-clamping the anchor against
  // the FOLLOWING month, never by adding 30/31 days (which would drift the day).
  for (int i = 0; i < count; i++) {
    dates.add(current);
    current = billingDateInMonth(current.year, current.month + 1, anchorDay);
  }
  return dates;
}

/// The half-open `[start, end)` billing cycle that contains [on] for
/// [anchorDay].
///
/// `start` is the billing date on/before [on]'s date; `end` is the next billing
/// date (the start of the following cycle), so the range is half-open and two
/// adjacent cycles never both claim the boundary day. [anchorDay] must be 1..31.
///
/// Example:
/// ```dart
/// // Anchor 15, the 20th falls in the cycle that opened on the 15th.
/// currentCycle(DateTime(2026, 3, 20), 15);
/// // (start: 2026-03-15, end: 2026-04-15)
/// ```
({DateTime start, DateTime end}) currentCycle(DateTime on, int anchorDay) {
  _checkAnchor(anchorDay);

  final DateTime onDate = _dateOnly(on);
  final DateTime thisMonth = billingDateInMonth(onDate.year, onDate.month, anchorDay);

  // The cycle start is this month's billing date if [on] is on/after it,
  // otherwise the previous month's billing date.
  final DateTime start = thisMonth.isAfter(onDate)
      ? billingDateInMonth(onDate.year, onDate.month - 1, anchorDay)
      : thisMonth;
  final DateTime end = billingDateInMonth(start.year, start.month + 1, anchorDay);
  return (start: start, end: end);
}
