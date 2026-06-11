# SPEC: DateTimeExtensions.toAnnualDate / toDayRange — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** `lib/datetime/date_time_bounds_extensions.dart` (extend the existing `DateTimeBoundsExtensions on DateTime`)
**Portability:** Flutter — `toDayRange` returns `DateTimeRange` from `package:flutter/material.dart` (already imported elsewhere in the library, e.g. `iso_interval_parse_utils.dart` does `import 'package:flutter/material.dart' show DateTimeRange;`). `toAnnualDate` is pure Dart (no Flutter, no external packages). No `intl` / `quiver` needed.

## Purpose — what it does + why it is general-purpose (not proprietary)

Two `DateTime` extension members harvested from Saropa Contacts:

- **`toAnnualDate`** — returns `DateTime(0, month, day)`: the same month/day pinned to the sentinel year **0**. This is the canonical "recurring annual date" representation (birthday, anniversary, holiday-without-year) — strip the year so two dates can be compared on month/day alone. It is **net-new** and, importantly, the **missing producer** for a consumer the library already ships: `DateTimeComparisonExtensions.isAnnualDateInRange` (`date_time_comparison_extensions.dart:89`) is explicitly documented to branch on `year == 0` ("When `year` is 0, this method checks if the month/day combination falls within the range for ANY year"). The library can already *test* a year-0 annual date but offers no blessed way to *build* one — callers hand-write `DateTime(0, month, day)`. `toAnnualDate` closes that gap.

- **`toDayRange()`** — returns the `DateTimeRange` spanning the full local day of the receiver: start at `00:00:00.000`, end at `23:59:59.999`. General-purpose day-bucketing for filtering/grouping by calendar day. **Overlaps the library's existing `startOfDay` / `endOfDay`** (see overlap note below).

Neither carries contact-domain logic, Saropa formats, l10n, icons, or reporting — both are plain `DateTime` arithmetic.

## Overlap with installed library (saropa_dart_utils 1.4.1)

- **`startOfDay` / `endOfDay` already exist** in `DateTimeBoundsExtensions` (`date_time_bounds_extensions.dart:9` and `:13`). `toDayRange()` is exactly `DateTimeRange(start: startOfDay, end: endOfDay)`. Recommendation: **do NOT port the contacts implementation verbatim** — add a thin `toDayRange()` that composes the existing getters, so there is one source of truth for the bounds. Note one behavioral difference to resolve deliberately: contacts' `endOfDay` stops at **millisecond** precision (`...59, 999`), the library's `endOfDay` goes to **microsecond** precision (`...999999`). Pick the library's microsecond form (it is the more correct "just before midnight") and let `toDayRange()` inherit it — do not reintroduce the millisecond truncation.
- **`toAnnualDate` has no equivalent** — no producer of a year-0 annual date exists anywhere in `lib/datetime/`. The only references to year-0 / annual dates are the *consumer* `isAnnualDateInRange` and ad-hoc `DateTime(checkYear, month, day)` reconstructions inside it.

**Verdict: partial-overlap.** `toDayRange` is a convenience composition over existing bounds; `toAnnualDate` is the net-new value.

## Source (from Saropa Contacts) — verbatim general-purpose members

Original file `lib/utils/primitive/date_time/date_time_extensions.dart`. No `debug()` / `DebugType` logging, l10n, icons, or app logic present — nothing stripped. Full extension below; both members are general-purpose and included.

```dart
import 'package:flutter/material.dart';

/// Extension on [DateTime] to provide additional functionality.
extension DateTimeExtensions on DateTime {
  DateTime get toAnnualDate => DateTime(0, month, day);

  /// Creates a [DateTimeRange] that covers the entire day of the given [DateTime].
  ///
  /// The range starts at 00:00:00.000 of the given day and ends just before
  /// midnight (23:59:59.999), effectively encapsulating the full 24-hour period.
  DateTimeRange toDayRange() {
    final DateTime startOfDay = DateTime(year, month, day);
    final DateTime endOfDay = DateTime(year, month, day, 23, 59, 59, 999);

    return DateTimeRange(start: startOfDay, end: endOfDay);
  }
}
```

### Recommended library form (compose over existing bounds)

```dart
extension DateTimeBoundsExtensions on DateTime {
  // ... existing startOfDay / endOfDay / startOfWeek / etc. ...

  /// The month/day of this date pinned to the sentinel year 0 — the canonical
  /// "recurring annual date" form (birthday, anniversary, holiday-without-year).
  ///
  /// Year 0 is the agreed sentinel for "any year": pairs with
  /// [DateTimeComparisonExtensions.isAnnualDateInRange], which treats a
  /// year-0 [DateTime] as a month/day match against any year in a range.
  /// Time-of-day is dropped (year-0 midnight).
  @useResult
  DateTime get toAnnualDate => DateTime(0, month, day);

  /// The full local calendar day of this date as a [DateTimeRange]:
  /// [startOfDay] (00:00:00.000000) to [endOfDay] (23:59:59.999999).
  ///
  /// Composes the existing day-bound getters so the bounds have a single
  /// source of truth. The end is the last representable instant before the
  /// next midnight (microsecond precision), not a millisecond-truncated value.
  @useResult
  DateTimeRange toDayRange() => DateTimeRange(start: startOfDay, end: endOfDay);
}
```

## Test cases — existing tests verbatim

From `d:/src/contacts/test/lib/utils/primitive/date_time/date_time_primitive_test.dart`, group `DateTimeExtensions` (lines 44-59):

```dart
group('DateTimeExtensions', () {
  test('toAnnualDate returns date with year 0', () {
    final DateTime date = DateTime(2024, 3, 15);
    final DateTime annual = date.toAnnualDate;
    expect(annual.year, 0);
    expect(annual.month, 3);
    expect(annual.day, 15);
  });

  test('toDayRange covers full day', () {
    final DateTime date = DateTime(2024, 3, 15, 10, 30);
    final DateTimeRange<DateTime> range = date.toDayRange();
    expect(range.start, DateTime(2024, 3, 15, 0, 0, 0, 0));
    expect(range.end, DateTime(2024, 3, 15, 23, 59, 59, 999));
  });
});
```

Note: the second test asserts millisecond precision (`...59, 999`). If the library form composes `endOfDay` (microsecond, `...999999`), this assertion must be updated to `DateTime(2024, 3, 15, 23, 59, 59, 999, 999)` — see the Bulletproofing gaps section.

## Bulletproofing gaps — concrete edge cases for massive coverage

### `toAnnualDate`

- **Leap day**: `DateTime(2024, 2, 29).toAnnualDate` — year 0 is a leap year in Dart's proleptic Gregorian calendar, so Feb 29 survives as `DateTime(0, 2, 29)` (no rollover to Mar 1). Assert it does NOT roll over.
- **Year-boundary days**: Jan 1 (`month==1, day==1`) and Dec 31 (`month==12, day==31`) preserve month/day exactly.
- **Time-of-day is dropped**: `DateTime(2024, 3, 15, 23, 59, 59, 999).toAnnualDate` has hour/minute/second/ms/us all 0.
- **Idempotence**: `d.toAnnualDate.toAnnualDate == d.toAnnualDate` (already year 0).
- **Round-trip with the consumer**: a `toAnnualDate` value returns the expected result from `isAnnualDateInRange` for an in-range and an out-of-range month/day, including a **range that spans the year boundary** (e.g. Dec 20 to Jan 10) — this is the documented motivation for year-0.
- **UTC vs local**: `toAnnualDate` on a `DateTime.utc(...)` produces a **local** (non-UTC) year-0 date because `DateTime(...)` is local. Decide and assert intended behavior; document if a `.utc` overload is wanted.
- **Equality of two different originals**: `DateTime(2024, 3, 15).toAnnualDate == DateTime(1999, 3, 15).toAnnualDate` (the whole point — month/day equality regardless of year).

### `toDayRange`

- **Precision decision (must resolve)**: lock whether the end is millisecond (`...999`) or microsecond (`...999999`). Add a test asserting `range.end.microsecond` explicitly so the contract is pinned and a future bounds refactor can't silently change it.
- **Start/end same calendar day**: `range.start.day == range.end.day` and `range.start` is `00:00:00.000000`.
- **Non-empty / ordered**: `range.start.isBefore(range.end)` and `range.duration` is one tick short of 24h (`23:59:59.999999`). Assert the exact `Duration`.
- **DST spring-forward day** (e.g. a US/EU day where a clock hour is skipped): `toDayRange()` builds via wall-clock `DateTime(year, month, day, ...)`, so `range.duration` is NOT a clean 23h59m... on the DST-transition day. Add a documented DST test (or assert local-wall-clock semantics) so the behavior is intentional, not accidental. Run under a fixed `TZ` in CI for determinism.
- **DST fall-back day**: same — the day has 25 hours of real time but the wall-clock range is unchanged; assert.
- **Leap-day input**: `DateTime(2024, 2, 29).toDayRange()` stays on Feb 29 for both bounds.
- **Month/year boundary inputs**: Dec 31 and Jan 1 days do not bleed into the adjacent day.
- **UTC input**: `DateTime.utc(2024, 3, 15, 10).toDayRange()` — current impl produces LOCAL bounds (loses UTC flag). Decide/assert; document whether a UTC-preserving path is needed.
- **Min/max extremes**: very large and very small years (e.g. year 1, year 9999) build valid ranges without overflow.
