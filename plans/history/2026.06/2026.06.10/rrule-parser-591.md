# RFC 5545 RRULE parser, subset (roadmap #591)

Item 2 of the "next 10" roadmap-utilities batch. Parses the calendar recurrence-rule string (iCalendar / Google Calendar exports) into an immutable `RecurrenceRule`. Forms the parse half of a calendar-recurrence pair; the expansion half is roadmap #592.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/datetime/rrule_parse_utils.dart` (`parseRrule`, `RecurrenceRule`, `RecurFrequency`, `RecurWeekday`), new test, barrel export, CHANGELOG entry.

**Design:** `parseRrule` strips an optional `RRULE:` prefix, splits on `;`, and dispatches each `NAME=VALUE` through a mutable `_RuleParts.apply` method (dispatch lives on the holder so it mutates `this`, not a parameter), then freezes the holder into an immutable `RecurrenceRule`. `FREQ` is required (its absence throws). `RecurWeekday` carries both the RRULE code (`MO`..`SU`) and the `DateTime.weekday` number (1..7) so the #592 iterator needs no second lookup table. Value equality uses `package:collection` `ListEquality` for the three `by*` lists.

**Subset boundary is explicit:** supported parts are FREQ/INTERVAL/COUNT/UNTIL/BYDAY/BYMONTHDAY/BYMONTH/WKST. Any other part throws `FormatException` — a silently-dropped constraint (e.g. BYSETPOS) would make a downstream expansion wrong without warning. Range guards: INTERVAL/COUNT ≥ 1, BYMONTH 1..12, BYMONTHDAY 1..31 or -1..-31 (0 rejected as the likely off-by-one typo), weekday codes validated.

**UNTIL parsing:** a single regex captures the y/m/d[/h/m/s] fields and the result is built with `DateTime`/`DateTime.utc` directly (trailing `Z` → UTC instant, else floating/local). This deliberately avoids `substring` slicing and `DateTime.parse`, both of which the analyzer flags as unbounded/unvalidated on dynamic input.

**Tests:** 19 cases — weekly+interval+byday+count, defaults, `RRULE:` prefix, order-independence + last-duplicate-wins, UTC date-only / date-time / floating UNTIL, negative BYMONTHDAY, BYMONTH+WKST, value equality; 10 error cases (missing FREQ, unknown FREQ, unsupported part, non-positive interval, bad weekday, BYMONTH/BYMONTHDAY range, malformed UNTIL, part without `=`). All pass; `flutter analyze` clean.

**Reviewer notes:** resolved a cascade of conflicting lints during cleanup — `avoid_parameter_mutation` (moved dispatch onto the holder), `avoid_nullable_interpolation` (`?? 'none'` in `toString`), and a substring/`DateTime.parse`/doc-comment/arrow-function tangle in `_parseUntil` (collapsed to a regex + list-comprehension with the explanatory comment above a `return`, not a declaration). Functions ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
