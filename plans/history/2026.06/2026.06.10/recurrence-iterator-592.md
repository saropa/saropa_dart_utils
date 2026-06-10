# Recurrence iterator (roadmap #592)

Item 3 of the "next 10" roadmap-utilities batch, and the expansion half of the calendar-recurrence pair (parse half = #591). Turns a parsed `RecurrenceRule` into the concrete `DateTime` occurrences it describes.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/datetime/recurrence_iterator_utils.dart` (`expandRecurrence`), new test, barrel export, CHANGELOG entry. Imports the #591 `RecurrenceRule` model.

**Design:** `expandRecurrence(rule, start, {limit})` is a `sync*` generator that walks one FREQ×INTERVAL period at a time. Per period it builds a sorted candidate list (`_candidatesFor` → daily/weekly/monthly/yearly helpers), skips candidates before `start` (DTSTART semantics), and returns the moment a candidate passes `until`. Because periods advance monotonically, that single forward check terminates the sequence correctly. Laziness means an unbounded rule (no count/until/limit) is safe — the caller bounds it with `.take(n)`; documented explicitly.

**BY-rule expansion:** WEEKLY positions each BYDAY relative to WKST (`_weekStartDate`); MONTHLY/YEARLY resolve BYMONTHDAY through `_resolveDay` (positive 1..lastDay, negative from month-end), dropping days that don't exist that month (day-31 in a 30-day month, Feb-29 off leap years); BYMONTH filters all frequencies. Empty BY lists fall back to the start's weekday/day/month.

**DST safety:** every date is built from calendar fields via `_dateWith` / `_addDays` (never `Duration`), carrying the start instant's time-of-day and UTC-ness, so adding days across a DST boundary doesn't shift the wall-clock time.

**Tests:** 14 cases — daily count + interval, weekly BYDAY in order, pre-start tail skip, weekly interval-2, monthly fixed day, BYMONTHDAY=31 month-skipping, negative BYMONTHDAY to month-end (incl. non-leap Feb), monthly default day, yearly BYMONTH cross-product, UNTIL-inclusive stop, `limit` cap, laziness via `take` on Feb-29 leap years (2000→2004), time-of-day + UTC preservation. All pass; `flutter analyze` clean.

**Reviewer notes:** generator is unbounded by design — the doc header and the test (`take(2)` on `FREQ=YEARLY`) both make the contract explicit. No unsafe collection accessors; `RecurWeekday.values[start.weekday - 1]` is index-safe because `DateTime.weekday` is always 1..7 and the enum is declared Monday..Sunday in order. Helpers all ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
