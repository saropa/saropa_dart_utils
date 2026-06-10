/// Holiday-aware business calendar — roadmap #593.
///
/// The free functions in `date_time_business_days_utils.dart` skip weekends
/// only. A [BusinessCalendar] adds two things real-world working-day math needs:
/// a configurable set of holidays, and a configurable definition of "weekend"
/// (some regions rest Friday/Saturday). Construct one with your holiday list and
/// reuse it for every query.
///
/// Dates are compared by calendar day (year/month/day); the time-of-day and time
/// zone of the inputs are ignored, so a holiday given as UTC or local matches a
/// query either way as long as the Y/M/D agree.
library;

/// A working-day calendar parameterized by a holiday set and a weekend
/// definition. Immutable after construction; safe to share.
class BusinessCalendar {
  /// Creates a calendar. [holidays] are matched by calendar day (time ignored).
  /// [weekendDays] are `DateTime.weekday` values (Mon = 1 … Sun = 7), defaulting
  /// to Saturday + Sunday. Pass e.g. `{DateTime.friday, DateTime.saturday}` for
  /// a Fri/Sat weekend.
  BusinessCalendar({
    Iterable<DateTime> holidays = const <DateTime>[],
    Set<int>? weekendDays,
  }) : weekendDays = Set<int>.unmodifiable(
         weekendDays ?? const <int>{DateTime.saturday, DateTime.sunday},
       ),
       _holidays = Set<DateTime>.unmodifiable(<DateTime>{
         for (final DateTime h in holidays) _dateOnly(h),
       });

  /// The `DateTime.weekday` values treated as non-working (default Sat + Sun).
  final Set<int> weekendDays;

  /// Holidays normalized to local midnight (`DateTime(y, m, d)`).
  final Set<DateTime> _holidays;

  /// Whether [date] falls on a configured weekend day.
  bool isWeekend(DateTime date) => weekendDays.contains(date.weekday);

  /// Whether [date]'s calendar day is in the holiday set.
  bool isHoliday(DateTime date) => _holidays.contains(_dateOnly(date));

  /// Whether [date] is a working day: neither a weekend nor a holiday.
  bool isBusinessDay(DateTime date) => !isWeekend(date) && !isHoliday(date);

  /// The first business day strictly after [date].
  DateTime nextBusinessDay(DateTime date) {
    DateTime d = _addDays(_dateOnly(date), 1);
    while (!isBusinessDay(d)) {
      d = _addDays(d, 1);
    }
    return d;
  }

  /// The first business day strictly before [date].
  DateTime previousBusinessDay(DateTime date) {
    DateTime d = _addDays(_dateOnly(date), -1);
    while (!isBusinessDay(d)) {
      d = _addDays(d, -1);
    }
    return d;
  }

  /// Adds [n] business days to [date], skipping weekends and holidays. Negative
  /// [n] moves backward; `n == 0` returns [date] unchanged (time-of-day intact).
  /// The result is date-only at local midnight for any non-zero [n].
  DateTime addBusinessDays(DateTime date, int n) {
    if (n == 0) {
      return date;
    }
    // One sign drives both directions; magnitude is the business-day count. Step
    // a single calendar day per loop so weekend/holiday days in the span are
    // passed over without consuming the count.
    final int step = n > 0 ? 1 : -1;
    int remaining = n.abs();
    DateTime current = _dateOnly(date);
    while (remaining > 0) {
      current = _addDays(current, step);
      if (isBusinessDay(current)) {
        remaining--;
      }
    }
    return current;
  }

  /// Counts business days in `[start, end)` — inclusive of [start], exclusive of
  /// [end]. Returns 0 when [end] is not after [start]. Weekends and holidays are
  /// excluded.
  int businessDaysBetween(DateTime start, DateTime end) {
    final DateTime stop = _dateOnly(end);
    DateTime day = _dateOnly(start);
    if (!day.isBefore(stop)) {
      return 0;
    }
    int count = 0;
    while (day.isBefore(stop)) {
      if (isBusinessDay(day)) {
        count++;
      }
      day = _addDays(day, 1);
    }
    return count;
  }

  /// Lists the business days in `[start, end)` in ascending order — inclusive of
  /// [start], exclusive of [end]. Empty when [end] is not after [start].
  List<DateTime> businessDaysIn(DateTime start, DateTime end) {
    final DateTime stop = _dateOnly(end);
    final List<DateTime> out = <DateTime>[];
    DateTime day = _dateOnly(start);
    while (day.isBefore(stop)) {
      if (isBusinessDay(day)) {
        out.add(day);
      }
      day = _addDays(day, 1);
    }
    return out;
  }
}

/// Strips time and zone, yielding local midnight on the input's calendar day, so
/// holiday storage and lookups share one canonical key.
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar-field day shift (not a `Duration`), so stepping never drifts across
/// a DST boundary. Day overflow/underflow is normalized by the constructor.
DateTime _addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);
