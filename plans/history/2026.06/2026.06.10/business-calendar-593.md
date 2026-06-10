# Holiday-aware business calendar (roadmap #593)

Item 4 of the "next 10" roadmap-utilities batch. Extends the existing weekend-only business-day helpers with a configurable holiday set and a configurable weekend definition — what real working-day math (SLAs, scheduling, payroll) needs.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/datetime/business_calendar_utils.dart` (`BusinessCalendar`), new test, barrel export, CHANGELOG entry.

**Design:** `BusinessCalendar` is an immutable service object built from a holiday `Iterable<DateTime>` (normalized to local-midnight keys via `_dateOnly`, stored in an unmodifiable `Set`) and an optional `weekendDays` set of `DateTime.weekday` values (default Sat+Sun, also unmodifiable). Query surface: `isWeekend` / `isHoliday` / `isBusinessDay`, `nextBusinessDay` / `previousBusinessDay` (strictly forward/back), `addBusinessDays` (sign = direction, magnitude = count, `n==0` returns input with time intact), `businessDaysBetween` (count over `[start, end)`), `businessDaysIn` (the list).

**Distinction from existing free functions:** `date_time_business_days_utils.dart` (`businessDaysBetween`, `addBusinessDays`) is weekend-only with no configuration and stays unchanged. `BusinessCalendar` is the configurable, holiday-aware superset — added alongside, not replacing, per the "add, don't downsize" rule.

**Date hygiene:** all comparisons are by calendar day (`_dateOnly` strips time + zone), so a holiday supplied as UTC or local matches a query either way when the Y/M/D agree. Stepping uses calendar-field arithmetic (`_addDays`, not `Duration`) so it never drifts across a DST boundary.

**Tests:** 14 cases — weekend/holiday/workday classification, time-of-day-ignored holiday match, next/previous skipping the New-Year holidays + weekend, strictly-forward next from a business day, add forward/backward over the gap, `n==0` identity (time preserved), `businessDaysBetween` span + zero-when-end-not-after-start, `businessDaysIn` listing, and a Friday/Saturday custom weekend. All pass; `flutter analyze` clean.

**Reviewer notes:** holiday/weekend sets are `Set.unmodifiable` so a caller can't mutate the calendar post-construction. No unsafe collection accessors; loops are date-only and bounded by `isBefore(stop)`. One transient `prefer_trailing_comma_always` info resolved by `dart format`. Methods all ≤20 lines; file ~135 lines.

No bug archive — task did not close a bugs/*.md file.
