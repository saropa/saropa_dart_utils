# ENH-007: static `nthWeekdayOfMonth(year, month, n, weekday)` + `lastWeekdayOfMonth(...)`

**File (target):** `lib/datetime/date_time_range_utils.dart` (static helpers, alongside the existing extension)
**Type:** Enhancement / API-shape + Missing Utility
**Severity:** 🟡 Medium
**Status:** Fixed

---

## Summary

`getNthWeekdayOfMonthInYear(n, dayOfWeek)` exists only as a **DateTime-instance
extension** — it derives year/month from `this`. Calendar-construction code (DST rules,
public-holiday tables) computes occurrences for an arbitrary `(year, month)` pair and
has no seed DateTime to hang the call on; building a throwaway `DateTime(year, month)`
just to call the extension is awkward. Two gaps:

1. A **static** `nthWeekdayOfMonth(year, month, n, weekday)` taking the year/month
   explicitly.
2. `lastWeekdayOfMonth(year, month, weekday)` — "last Sunday of October" — which has
   **no** equivalent at all (the extension only counts from the start).

---

## Absence Evidence

```bash
grep -rnE "lastWeekday|static .*nthWeekday" ../saropa_dart_utils/lib/datetime/
# 1.3.0: getNthWeekdayOfMonthInYear exists as a DateTime extension only; no last-weekday helper
```

## Use Case (consumer's local implementation)

Saropa Contacts (`lib/utils/primitive/date_time/day_in_month_calculations.dart`) builds
its entire DST / observance calendar on a static family the library can't currently back:

```dart
static DateTime? nthWeekday({required int year, required int month, required int nth, required int weekday}) { ... }
static DateTime lastWeekday({required int year, required int month, required int weekday}) {
  final DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
  final int daysToSubtract = (lastDayOfMonth.weekday - weekday + 7) % 7;
  return lastDayOfMonth.subtract(Duration(days: daysToSubtract));
}
// e.g. "last Sunday of March" (EU DST), "2nd Sunday of March" (US DST)
```

## Suggested API

```dart
abstract final class MonthWeekdayUtils {
  /// nth (1..5) [weekday] in [month]/[year]; null if it doesn't exist.
  static DateTime? nthWeekdayOfMonth(int year, int month, int n, int weekday);

  /// Last [weekday] in [month]/[year] (always exists).
  static DateTime lastWeekdayOfMonth(int year, int month, int weekday);
}
```

Keep the existing extension; these statics complement it for the no-seed case.

## Missing Tests

- 5th occurrence that doesn't exist → null; 1st/2nd/3rd; `lastWeekday` across 28/29/30/31-day
  months; leap-year February; year boundaries.

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `day_in_month_calculations.dart`

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension.

**What shipped:** New file `lib/datetime/month_weekday_utils.dart` with `abstract final class MonthWeekdayUtils` (matching the existing `MonthUtils`/`WeekdayUtils`/`SerialDateUtils` convention) exposing two statics:
- `static DateTime? nthWeekdayOfMonth(int year, int month, int n, int weekday)`
- `static DateTime lastWeekdayOfMonth(int year, int month, int weekday)`

Exported from the barrel.

**Design decisions:**
- New file rather than the bug's suggested `date_time_range_utils.dart` — that file is `DateTimeRange`-extension territory; these are general `(year, month)` calendar math with their own concern. The instance counterpart `getNthWeekdayOfMonthInYear` actually lives in `date_time_extensions.dart`, not the range file, so neither was a natural host.
- `nthWeekdayOfMonth` **reuses** the existing instance algorithm: `DateTime(year, month).getNthWeekdayOfMonthInYear(n, weekday)` — no re-derivation of the offset math.
- Added an explicit range guard on `n`/`month`/`weekday` BEFORE constructing `DateTime(year, month)`. Without it, an out-of-range month (e.g. 13) would normalize to a neighboring month and the extension's own month-mismatch check would silently return a plausible-but-wrong date. The bug supplies untrusted calendar input, so invalid args return `null`.
- `lastWeekdayOfMonth` uses the consumer's proven formula (day-0-of-next-month = last day; modulo back to the weekday), which handles 28/29/30/31-day months and the December→January rollover.

**Tests (Section 4):**
- Audit: no existing test referenced `MonthWeekdayUtils` (new symbol); the barrel change only adds an export (`dart analyze` clean on the barrel confirms no ambiguity).
- New `test/datetime/month_weekday_utils_test.dart`, 12 cases. Reference dates pre-computed with an independent probe: 2nd Sun Mar 2026 = 2026-03-08, 5th Fri Jan 2026 = 2026-01-30, 5th Fri Feb 2026 = null; last Sun Oct 2026 = 2026-10-25, last Sun Mar 2026 = 2026-03-29, last Mon Feb 2026 (28d) = 2026-02-23, last Fri Feb 2024 (leap) = 2024-02-23, last Thu Dec 2026 (rollover) = 2026-12-31; plus n<1, month 0/13, weekday 0/8 → null.
- Ran `flutter test test/datetime/month_weekday_utils_test.dart` → **All 12 tests passed**.
- Ran `dart analyze` on the file, its test, and the barrel → **No issues found**.

**Maintenance:** CHANGELOG 1.4.1 Added section updated. CODEBASE_INDEX gained a row for the new file. README verified — no updates needed.

**Dependency note:** Same `saropa_lints ^13.12.5` situation; committed pubspec keeps `^13.12.5`, local runs use `^13.12.3`.

**Outstanding:** None for ENH-007.
