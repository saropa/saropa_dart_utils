# SPEC: LocalDateTimeUtils (isLeapYear, isValidDateParts, monthDayCountNullable) — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** `lib/datetime/date_time_utils.dart` (extend existing `DateTimeUtils`)
**Portability:** pure Dart. No Flutter, no external packages. (`date_time_utils_local.dart` pulls in `dart:io`, but its only member — `isDeviceDateMonthFirst` — is out of scope; see below.)

## Purpose — what it does + why it is general-purpose (not proprietary)

`LocalDateTimeUtils` is a small calendar-math helper used by Saropa Contacts to
validate user-entered date parts (birthdays, anniversaries) before constructing a
`DateTime`. It carries three pure functions:

- `isLeapYear(int year)` — proleptic Gregorian leap-year test.
- `isValidDateParts({...})` — range-validates each `DateTime` component
  independently; null components are skipped; `day` requires `month` and respects
  per-month / leap-year day counts.
- `monthDayCountNullable({int? year, required int month})` — days in a month, with
  a **nullable** year. When `year` is null, February returns 28 (cannot resolve a
  leap year without the year). Unlike the library's `monthDayCount`, it does **not**
  throw on an out-of-range `month`.

All three are general calendar arithmetic with no contact-domain, l10n, or
formatting concerns — they belong in a date library.

**Overlap with installed saropa_dart_utils 1.4.1:** the library already ships
`DateTimeUtils.isLeapYear({required int year})`, `DateTimeUtils.isValidDateParts({...})`,
and `DateTimeUtils.monthDayCount({required int year, required int month})` in
`lib/datetime/date_time_utils.dart`, with semantics equivalent to (and slightly
more robust than) the Contacts copies:

- `isLeapYear` — identical formula. Library is keyword-arg; Contacts is positional.
  **Already in library.**
- `isValidDateParts` — identical ranges (year 0–9999, month 1–12, hour 0–23,
  etc.). Library additionally falls back to a `defaultLeapYearCheckYear` when `day`
  is validated with `month` set but `year` null, so `isValidDateParts(month: 2, day: 29)`
  is accepted by the library (leap-year-tolerant) but **rejected** by Contacts
  (which requires `year` non-null to allow day 29). Net behavior difference noted;
  **library version is the keeper.** **Already in library.**
- `monthDayCount` (library) **throws `ArgumentError`** on `month` outside 1–12 and
  requires a non-null `year`. The Contacts `monthDayCountNullable` is the **net-new
  variant**: nullable `year` (Feb → 28 when unknown) and **non-throwing** on bad
  `month` (returns 30 for any non-31-day, non-Feb month, including out-of-range).

**Net-new for the library: only `monthDayCountNullable`** — a null-year-tolerant,
non-throwing companion to the existing `monthDayCount`. Recommend adding it as
`DateTimeUtils.monthDayCountSafe({int? year, required int month})` so callers that
have a partial date (month known, year unknown) or want a no-throw contract have a
first-class option, rather than reinventing the nullable form. The other two
members need **no action** — they duplicate existing library API.

## Source (from Saropa Contacts) — verbatim general-purpose members

The two duplicated members (`isLeapYear`, `isValidDateParts`) are reproduced for
reference; the net-new member is `monthDayCountNullable`.

```dart
abstract final class LocalDateTimeUtils {
  static bool isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

  /// Validates the date and time components.
  /// If any component is invalid, returns false (early exit).
  static bool isValidDateParts({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    if (year != null && (year < 0 || year > 9999)) {
      return false;
    }

    if (month != null && (month < 1 || month > 12)) {
      return false;
    }

    if (day != null) {
      // month must be known to validate day properly
      if (month == null) return false;

      // includes leap year calc
      final int maxDay = monthDayCountNullable(year: year, month: month);
      if (day < 1 || day > maxDay) {
        return false;
      }
    }

    if (hour != null && (hour < 0 || hour > 23)) {
      return false;
    }

    if (minute != null && (minute < 0 || minute > 59)) {
      return false;
    }

    if (second != null && (second < 0 || second > 59)) {
      return false;
    }

    if (millisecond != null && (millisecond < 0 || millisecond > 999)) {
      return false;
    }

    if (microsecond != null && (microsecond < 0 || microsecond > 999)) {
      return false;
    }

    // all checks pass
    return true;
  }

  // ---- NET-NEW: nullable-year, non-throwing day count ----

  /// Days in [month]. [year] may be null: when null, February returns 28
  /// because a leap year cannot be resolved without the year.
  /// Does NOT throw on an out-of-range [month] (returns 30 for any
  /// non-31-day, non-February month). Contrast DateTimeUtils.monthDayCount,
  /// which requires a non-null year and throws ArgumentError on bad month.
  static int monthDayCountNullable({required int? year, required int month}) {
    // February: leap year check (only possible when year is known)
    if (month == 2) {
      if (year != null &&
          ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))) {
        return 29;
      }

      return 28;
    }

    const List<int> thirtyOneDayMonths = <int>[1, 3, 5, 7, 8, 10, 12];

    return thirtyOneDayMonths.contains(month) ? 31 : 30;
  }
}
```

### Excluded members + why

- `DateTimeUtilsLocal.isDeviceDateMonthFirst()`
  (`date_time_utils_local.dart`) — **EXCLUDED (scope note).** Reads
  `Platform.localeName` (`dart:io`, not pure Dart) and overlaps the library's
  pure-Dart `DateTimeUtils.isDateMonthFirst({required String localeName})`. The
  library version takes a locale param instead of reading the platform, which is
  the correct, testable, portable form. The Contacts copy exists only because a
  1.1.x refactor dropped the platform-reading variant; it is an app-side shim, not
  a library candidate. No action.
- `isLeapYear`, `isValidDateParts` — **duplicates** of existing library API
  (`DateTimeUtils.isLeapYear`, `DateTimeUtils.isValidDateParts`). Listed above for
  reference only; do not re-add.

## Test cases — existing tests verbatim (from Saropa Contacts)

`test/lib/utils/primitive/date_time/date_time_primitive_test.dart`, group
`LocalDateTimeUtils`:

```dart
group('LocalDateTimeUtils', () {
  test('isLeapYear returns true for leap years', () {
    expect(LocalDateTimeUtils.isLeapYear(2024), isTrue); // Divisible by 4
    expect(LocalDateTimeUtils.isLeapYear(2000), isTrue); // Divisible by 400
  });

  test('isLeapYear returns false for non-leap years', () {
    expect(LocalDateTimeUtils.isLeapYear(2023), isFalse);
    expect(LocalDateTimeUtils.isLeapYear(1900), isFalse); // Divisible by 100 but not 400
  });

  test('isValidDateParts validates year', () {
    expect(LocalDateTimeUtils.isValidDateParts(year: 2024), isTrue);
    expect(LocalDateTimeUtils.isValidDateParts(year: -1), isFalse);
    expect(LocalDateTimeUtils.isValidDateParts(year: 10000), isFalse);
  });

  test('isValidDateParts validates month', () {
    expect(LocalDateTimeUtils.isValidDateParts(month: 1), isTrue);
    expect(LocalDateTimeUtils.isValidDateParts(month: 12), isTrue);
    expect(LocalDateTimeUtils.isValidDateParts(month: 0), isFalse);
    expect(LocalDateTimeUtils.isValidDateParts(month: 13), isFalse);
  });

  test('isValidDateParts validates day with month', () {
    expect(LocalDateTimeUtils.isValidDateParts(month: 1, day: 31), isTrue);
    expect(LocalDateTimeUtils.isValidDateParts(month: 2, day: 28), isTrue);
    expect(
      LocalDateTimeUtils.isValidDateParts(year: 2024, month: 2, day: 29),
      isTrue,
    ); // Leap year
    expect(LocalDateTimeUtils.isValidDateParts(year: 2023, month: 2, day: 29), isFalse);
    expect(LocalDateTimeUtils.isValidDateParts(day: 15), isFalse); // Day without month
  });

  test('monthDayCountNullable returns correct days', () {
    expect(LocalDateTimeUtils.monthDayCountNullable(year: 2024, month: 1), 31);
    expect(LocalDateTimeUtils.monthDayCountNullable(year: 2024, month: 2), 29); // Leap year
    expect(LocalDateTimeUtils.monthDayCountNullable(year: 2023, month: 2), 28);
    expect(LocalDateTimeUtils.monthDayCountNullable(year: 2024, month: 4), 30);
  });
});
```

> NOTE: the existing `monthDayCountNullable` tests use raw int literals as the
> matcher (`expect(..., 31)`). When porting to the library, the library style and
> `saropa_lints/avoid_misused_test_matchers` require explicit matchers — wrap with
> `equals(31)`.

## Bulletproofing gaps — concrete edge cases to add for massive coverage

Target the net-new `monthDayCountNullable` (the keeper) for full coverage; the
other two ride on the library's existing coverage.

**`monthDayCountNullable` — null-year branch (the distinctive contract):**
- `year: null, month: 2` → `28` (cannot resolve leap year). Lock this; it is the
  whole reason the nullable variant exists.
- `year: null` for every other month 1–12 → 31/30 per the standard table.

**`monthDayCountNullable` — non-throwing out-of-range month (distinct from `monthDayCount`):**
- `month: 0`, `month: 13`, `month: -1`, `month: 100`, `month: 1 << 31` → all
  currently return `30` (fall through the 31-day list, not February). Pin this as
  the documented behavior, OR decide the library variant should clamp/throw; either
  way the spec must assert what happens, because the silent-30 is a footgun.
  Contrast-test against `DateTimeUtils.monthDayCount(month: 0)` which throws.

**Leap-year boundaries (`isLeapYear` + Feb day count):**
- `year: 2000` → leap (÷400), `1900` → not (÷100, ÷̸400), `2100`/`2200`/`2300`
  → not, `2400` → leap. Feb day count must follow: `monthDayCountNullable(year: 2000, month: 2) == 29`, `(year: 1900, month: 2) == 28`.
- `year: 0` → leap (0 % 400 == 0); `monthDayCountNullable(year: 0, month: 2) == 29`.
- Negative / BCE-style years: `year: -4` → leap by formula, `year: -1` → not.
  Decide and document whether negative years are in contract.

**`isValidDateParts` boundaries:**
- Year boundaries: `0` valid, `9999` valid, `-1` invalid, `10000` invalid.
- Each unit boundary low/high and just-over: `hour` 0/23/24/-1; `minute` &
  `second` 0/59/60/-1; `millisecond` & `microsecond` 0/999/1000/-1.
- `day: 31` for 30-day month (April/June/Sept/Nov) → invalid; `day: 30` valid.
- `day: 29, month: 2` with `year: 2024` (leap) valid; with `year: 2023` invalid;
  with `year: null` → Contacts rejects (Feb max = 28 when year unknown), library
  `isValidDateParts` accepts via `defaultLeapYearCheckYear` (a leap year). **This
  divergence MUST be an explicit test** so the chosen library semantics are locked.
- `day: 0` → invalid (lower bound); `day: -5` → invalid.
- `day` set, `month` null → invalid (day un-validatable without month).
- All-null call `isValidDateParts()` → `true` (nothing to reject).

**Extremes / robustness:**
- Very large ints near `2^63 - 1` for `year`/`month`/each unit → must return
  `false` (or, for `monthDayCountNullable`, a defined value) without overflow.
- `isLeapYear` with `year: 0x7FFFFFFFFFFFFFFF` and minimum int → no crash, modulo
  math stays well-defined.

(No string / unicode / emoji / NaN / infinity inputs apply — every parameter is
`int` or `int?`; there are no floating-point or text inputs to fuzz.)
