# SPEC: DayInMonthCalculations (named weekday-of-month wrappers + daysInFebruary) — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/datetime/month_weekday_named_extensions.dart (or extend lib/datetime/month_weekday_utils.dart)
**Portability:** Pure Dart. No Flutter, no external packages. Uses only `DateTime`, `Duration`, and `DateTime` weekday constants.

## Purpose — what it does + why it is general-purpose (not proprietary)

`DayInMonthCalculations` is a `(year, month)`-keyed set of calendar helpers for computing named weekday occurrences within a month, plus February day count and month-boundary days. Its sole real use cases in calendar code are **DST rule tables** (e.g. EU/GB DST = last Sunday of March/October, US DST = 2nd Sunday of March, EG DST = last Thursday of October) and **public-holiday tables** (e.g. 3rd Monday, last Friday). None of it references contacts, Saropa formats, l10n, icons, or app state — it is pure date arithmetic over arbitrary year/month integers.

**Relationship to the existing library core (partial overlap — this is the additive layer):**

The library ALREADY has the core in `lib/datetime/month_weekday_utils.dart`:

- `MonthWeekdayUtils.nthWeekdayOfMonth(year, month, n, weekday)` → equivalent to `DayInMonthCalculations.nthWeekday(...)`.
- `MonthWeekdayUtils.lastWeekdayOfMonth(year, month, weekday)` → equivalent to `DayInMonthCalculations.lastWeekday(...)`.

So the core algorithm is **already in the library — do NOT re-add it.** Notable behavioral difference: the library `nthWeekdayOfMonth` RETURNS `null` for out-of-range `n`/`month`/`weekday`, whereas the Saropa `nthWeekday` THROWS `ArgumentError` for `nth < 1 || nth > 5`. The library's null-return policy is the better contract for untrusted calendar input; the named wrappers below should delegate to it.

**Net-new value this util adds (the convenience layer):**

1. **Named ordinal-weekday wrappers** — `firstMonday`, `secondMonday`, `thirdMonday`, `firstThursday`, `firstFriday`, `firstSaturday`, `secondFriday`, `secondSaturday`, `thirdSaturday`, `firstSunday`, `secondSunday`, `thirdSunday`. These read at the call site exactly as DST/holiday rules are written ("2nd Sunday of March") instead of forcing the reader to decode `nthWeekdayOfMonth(y, m, 2, DateTime.sunday)`.
2. **Named "last weekday" wrappers** — `lastMonday`, `lastFriday`, `lastSaturday`, `lastSunday`, `lastThursday`. Same readability win for the last-occurrence DST patterns.
3. **`daysInFebruary(year)`** — leap-year-aware February day count via the `DateTime(year, 3, 0).day` trick. Not present in the core.
4. **`firstDayOfMonth(year, month)`** and **`lastDay(year, month)`** — month-boundary helpers. (Check library overlap before adding — see Bulletproofing note; `lastDay` may already exist as a bounds extension.)

The wrappers split into two semantic groups for nullability:

- **Non-null** (always exists): 1st/2nd/3rd occurrences and every `last*` — every weekday occurs at least 4 times a month, so positions 1..4 and "last" can never be absent. These return `DateTime` (Saropa uses `!`).
- **Nullable** (may not exist): `thirdSaturday`, `thirdSunday` in the Saropa source return nullable even though a 3rd occurrence ALWAYS exists — this is over-cautious and inconsistent with `thirdMonday` (non-null). For the library, every 1st/2nd/3rd should be **non-null**; only a 5th occurrence is genuinely absent-able. See Bulletproofing.

## Source (from Saropa Contacts) — general-purpose members, verbatim (no debug logging present to strip)

```dart
class DayInMonthCalculations {
  // Calculate the number of days in February for the given year.
  // This clever trick works because of how the DateTime class in Dart
  // handles "out-of-range" day values: day 0 of March is the last day of
  // February, whose .day is February's length (28 or 29).
  static int daysInFebruary(int year) => DateTime(year, 3, 0).day;

  /// Generic helper to calculate the nth weekday of a given month.
  /// Returns null if the nth occurrence doesn't exist in the requested month
  /// (e.g., 5th Monday in February when there are only 4).
  ///
  /// NOTE: the library already has this as
  /// `MonthWeekdayUtils.nthWeekdayOfMonth(year, month, n, weekday)`, which
  /// returns null (rather than throwing) for out-of-range arguments. Delegate
  /// the wrappers below to it; do NOT re-add this method.
  static DateTime? nthWeekday({
    required int year,
    required int month,
    required int nth,
    required int weekday,
  }) {
    // Basic validation (can have up to 5 of a weekday in a month)
    if (nth < 1 || nth > 5) {
      throw ArgumentError('nth must be between 1 and 5, inclusive.');
    }

    final DateTime first = firstDayOfMonth(year, month);

    final int daysToAdd = (weekday - first.weekday + 7) % 7 + (nth - 1) * 7;

    final DateTime result = first.add(Duration(days: daysToAdd));

    // Validate result is still in the requested month
    if (result.month != month) {
      return null;
    }

    return result;
  }

  static DateTime firstDayOfMonth(int year, int month) => DateTime(year, month, 1);

  // ---- Named ordinal-weekday wrappers (NET-NEW: the additive value) ----

  /// First Monday of the month. First occurrence always exists.
  static DateTime firstMonday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 1, weekday: DateTime.monday)!;

  static DateTime firstThursday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 1, weekday: DateTime.thursday)!;

  static DateTime firstFriday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 1, weekday: DateTime.friday)!;

  static DateTime firstSaturday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 1, weekday: DateTime.saturday)!;

  /// 3rd Saturday. (Saropa returns nullable; a 3rd occurrence always exists —
  /// the library should make this non-null. See Bulletproofing.)
  static DateTime? thirdSaturday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 3, weekday: DateTime.saturday);

  /// 2nd Monday. Second occurrence always exists.
  static DateTime secondMonday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 2, weekday: DateTime.monday)!;

  static DateTime secondFriday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 2, weekday: DateTime.friday)!;

  static DateTime secondSaturday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 2, weekday: DateTime.saturday)!;

  /// 3rd Monday. Third occurrence always exists.
  static DateTime thirdMonday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 3, weekday: DateTime.monday)!;

  static DateTime firstSunday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 1, weekday: DateTime.sunday)!;

  /// 3rd Sunday. (Saropa returns nullable; see thirdSaturday note.)
  static DateTime? thirdSunday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 3, weekday: DateTime.sunday);

  /// Used by US DST pattern (2nd Sunday of March).
  static DateTime secondSunday(int year, int month) =>
      nthWeekday(year: year, month: month, nth: 2, weekday: DateTime.sunday)!;

  // ---- Month-boundary + last-weekday wrappers ----

  /// Last calendar day of the month (day 0 of the next month).
  static DateTime lastDay(int year, int month) => DateTime(year, month + 1, 0);

  /// NOTE: the library already has this as
  /// `MonthWeekdayUtils.lastWeekdayOfMonth(year, month, weekday)`. Delegate the
  /// last* wrappers to it; do NOT re-add this method.
  static DateTime lastWeekday({
    required int year,
    required int month,
    required int weekday,
  }) {
    final DateTime lastDayOfMonth = lastDay(year, month);

    // How many days to step back to reach the last matching weekday.
    final int daysToSubtract = (lastDayOfMonth.weekday - weekday + 7) % 7;

    return lastDayOfMonth.subtract(Duration(days: daysToSubtract));
  }

  static DateTime lastMonday(int year, int month) =>
      lastWeekday(year: year, month: month, weekday: DateTime.monday);

  static DateTime lastFriday(int year, int month) =>
      lastWeekday(year: year, month: month, weekday: DateTime.friday);

  /// Used by EU/GB DST pattern (last Sunday of March/October).
  static DateTime lastSunday(int year, int month) =>
      lastWeekday(year: year, month: month, weekday: DateTime.sunday);

  /// Used by EG DST pattern (last Thursday of October).
  static DateTime lastThursday(int year, int month) =>
      lastWeekday(year: year, month: month, weekday: DateTime.thursday);

  static DateTime lastSaturday(int year, int month) =>
      lastWeekday(year: year, month: month, weekday: DateTime.saturday);
}
```

### Excluded members + why

None of the source is proprietary; the entire class is general-purpose date math. The only members that should NOT be ported as-is (because the library already owns them) are:

| Member | Why excluded from new code |
|---|---|
| `nthWeekday(...)` | Already covered by `MonthWeekdayUtils.nthWeekdayOfMonth` (which returns null instead of throwing — the better contract). Wrappers delegate to it. |
| `lastWeekday(...)` | Already covered by `MonthWeekdayUtils.lastWeekdayOfMonth`. Wrappers delegate to it. |
| `lastDay(...)` / `firstDayOfMonth(...)` | Verify against existing `date_time_bounds_extensions.dart` first — a `startOfMonth`/`endOfMonth` may already exist. If so, reuse rather than duplicate. |

No l10n, Crashlytics, debug logging, Font Awesome, or app search syntax appears in this file — nothing to strip beyond the notes above.

## Test cases — existing tests verbatim (from Saropa Contacts)

From `d:/src/contacts/test/lib/utils/primitive/date_time/date_time_primitive_test.dart`:

```dart
group('DayInMonthCalculations', () {
  test('daysInFebruary returns correct days', () {
    expect(DayInMonthCalculations.daysInFebruary(2024), 29); // Leap year
    expect(DayInMonthCalculations.daysInFebruary(2023), 28);
  });

  test('firstDayOfMonth returns first day', () {
    expect(DayInMonthCalculations.firstDayOfMonth(2024, 3), DateTime(2024, 3, 1));
  });

  test('firstMonday returns correct date', () {
    // January 2024 starts on Monday
    expect(DayInMonthCalculations.firstMonday(2024, 1), DateTime(2024, 1, 1));
    // February 2024 first Monday is Feb 5
    expect(DayInMonthCalculations.firstMonday(2024, 2), DateTime(2024, 2, 5));
  });

  test('secondMonday returns correct date', () {
    expect(DayInMonthCalculations.secondMonday(2024, 1), DateTime(2024, 1, 8));
  });

  test('thirdMonday returns correct date', () {
    expect(DayInMonthCalculations.thirdMonday(2024, 1), DateTime(2024, 1, 15));
  });

  test('lastDay returns correct date', () {
    expect(DayInMonthCalculations.lastDay(2024, 1), DateTime(2024, 1, 31));
    expect(DayInMonthCalculations.lastDay(2024, 2), DateTime(2024, 2, 29)); // Leap year
    expect(DayInMonthCalculations.lastDay(2023, 2), DateTime(2023, 2, 28));
  });

  test('lastMonday returns correct date', () {
    // January 2024 last Monday is Jan 29
    expect(DayInMonthCalculations.lastMonday(2024, 1), DateTime(2024, 1, 29));
  });

  test('nthWeekday returns null for overflow', () {
    // February 2024 has only 4 Mondays (5th, 12th, 19th, 26th)
    expect(
      DayInMonthCalculations.nthWeekday(year: 2024, month: 2, nth: 5, weekday: DateTime.monday),
      isNull,
    );
  });

  test('nthWeekday throws for invalid nth', () {
    expect(
      () => DayInMonthCalculations.nthWeekday(
        year: 2024,
        month: 1,
        nth: 0,
        weekday: DateTime.monday,
      ),
      throwsArgumentError,
    );
    expect(
      () => DayInMonthCalculations.nthWeekday(
        year: 2024,
        month: 1,
        nth: 6,
        weekday: DateTime.monday,
      ),
      throwsArgumentError,
    );
  });

  test('thirdSaturday returns correct date or null', () {
    // September 2024: First Saturday is Sep 7, third is Sep 21
    expect(DayInMonthCalculations.thirdSaturday(2024, 9), DateTime(2024, 9, 21));
  });
});
```

> Note: the `nthWeekday throws for invalid nth` test encodes the THROW contract. If the wrappers delegate to `MonthWeekdayUtils.nthWeekdayOfMonth` (which returns null), this test must be rewritten to assert `isNull` instead of `throwsArgumentError` — decide the contract before porting.

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**Real DST anchor dates (the actual reason this util exists — verify against tz database):**

- US DST start = 2nd Sunday of March: `secondSunday(2026, 3)` == `DateTime(2026, 3, 8)`; `secondSunday(2025, 3)` == `DateTime(2025, 3, 9)`.
- US DST end = 1st Sunday of November: `firstSunday(2026, 11)` == `DateTime(2026, 11, 1)`.
- EU/GB DST start = last Sunday of March: `lastSunday(2026, 3)` == `DateTime(2026, 3, 29)`; `lastSunday(2025, 3)` == `DateTime(2025, 3, 30)`.
- EU/GB DST end = last Sunday of October: `lastSunday(2026, 10)` == `DateTime(2026, 10, 25)`.
- EG DST end = last Thursday of October: `lastThursday(2026, 10)` == `DateTime(2026, 10, 29)`.

**Leap years and February boundaries (`daysInFebruary`):**

- Standard leap (÷4): `daysInFebruary(2024)` == 29, `daysInFebruary(2028)` == 29.
- Common year: `daysInFebruary(2023)` == 28, `daysInFebruary(2025)` == 28.
- Century non-leap (÷100, not ÷400): `daysInFebruary(1900)` == 28, `daysInFebruary(2100)` == 28.
- Century leap (÷400): `daysInFebruary(2000)` == 29, `daysInFebruary(2400)` == 29.
- Year 0 / year 1 / negative years (Dart `DateTime` supports them): `daysInFebruary(0)` == 29 (year 0 is divisible by 400), `daysInFebruary(-4)` behavior — assert it doesn't throw.
- `lastDay` for every month: 31-day (Jan/Mar/May/Jul/Aug/Oct/Dec), 30-day (Apr/Jun/Sep/Nov), Feb leap/common.

**5th-occurrence existence (the only genuinely nullable case):**

- 5th Monday of a 31-day month that starts on Monday DOES exist: `nthWeekdayOfMonth(2024, 1, 5, DateTime.monday)` == `DateTime(2024, 1, 29)`.
- 5th Monday of February 2024 does NOT exist → null.
- For EVERY weekday, find one month where the 5th exists and one where it doesn't; assert non-null vs null.
- 4th occurrence ALWAYS exists for every weekday/month — assert never null across all 12 months of a sample year.

**Nullability-consistency fix (decide and lock with tests):**

- `thirdSaturday` / `thirdSunday` currently return nullable but a 3rd occurrence is always present. Add a property-style test asserting 1st/2nd/3rd/4th are non-null for all 7 weekdays across all 12 months of several years — and make the library wrappers non-null accordingly. Reserve nullable return ONLY for explicit 5th-occurrence queries.

**Argument-validation edge cases (match whichever contract is chosen):**

- `n`/`nth` boundaries: 0 (invalid), 1 (min valid), 5 (max valid), 6 (invalid), negative, very large.
- `month` boundaries: 0, 1, 12, 13, negative, very large — confirm month-normalization does NOT silently compute a neighboring month (the library guards this by rejecting out-of-range month up front; assert that).
- `weekday` boundaries: 0, 1 (Monday), 7 (Sunday), 8, negative — assert rejection / null rather than a wrong date.

**DateTime construction subtleties:**

- All results are LOCAL `DateTime` (constructed via `DateTime(...)`, not `.utc`). Add a test documenting that the returned `.isUtc` is `false`, so consumers in DST-shifting zones know the time-of-day is local midnight. (A `nthWeekdayOfMonthUtc` variant could be a follow-up if needed for tz-safe DST math — note as open question, do not implement speculatively.)
- Confirm time-of-day is exactly midnight (`hour`/`minute`/`second`/`millisecond` all 0) for every helper — month arithmetic via `add`/`subtract(Duration(days:))` must not introduce a 23:00 offset across a DST fold (it won't for `days`, but assert it).

**Extremes:**

- Far-future / far-past years: `firstMonday(9999, 12)`, `lastSunday(1, 1)` — assert no throw and correct weekday.
- December roll-over in `lastDay` / `lastWeekday`: `lastDay(2026, 12)` == `DateTime(2026, 12, 31)` (month + 1 = 13 normalizes to next January day 0). Explicit test for the month-13 path.

(Not applicable to this integer/DateTime util: empty/null strings, unicode/emoji, infinity/NaN, locale — all inputs are `int`; note in the test file header that these axes are intentionally out of scope.)
