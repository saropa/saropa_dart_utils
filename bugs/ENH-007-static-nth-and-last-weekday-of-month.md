# ENH-007: static `nthWeekdayOfMonth(year, month, n, weekday)` + `lastWeekdayOfMonth(...)`

**File (target):** `lib/datetime/date_time_range_utils.dart` (static helpers, alongside the existing extension)
**Type:** Enhancement / API-shape + Missing Utility
**Severity:** 🟡 Medium
**Status:** Open

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
