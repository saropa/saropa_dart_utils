# SLA / due-date calculator (roadmap #595)

Item 1 of the second "next 10" roadmap-utilities batch (user: "build the next 10"). Computes SLA deadlines and elapsed working time against a weekly business-hours schedule plus holidays — the "resolve within 8 business hours" calculation, building on the holiday-aware BusinessCalendar (#593).

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/datetime/sla_calculator_utils.dart` (`SlaCalculator`, `BusinessHours`, `OpenWindow`), new test, barrel export, CHANGELOG entry. Also folds in a one-line doc-comment cleanup to `interval_tree_utils.dart` (an awkward leftover phrase in the `IntervalEntry` dartdoc) that a linter surfaced.

**Design:** `OpenWindow(startMinute, endMinute)` is a half-open `[start, end)` minute-of-day range (asserts `0 <= start < end <= 1440`). `BusinessHours` maps `DateTime.weekday → List<OpenWindow>` (copied + sorted on construction) with a `uniform` factory defaulting to Mon–Fri. `SlaCalculator` layers a `BusinessCalendar?` for holidays. `_concreteWindows(reference)` materializes a day's windows as `(DateTime open, DateTime close)` records in the reference's own zone, returning empty on a holiday. `addWorkingTime` walks day-by-day consuming `remaining` from each window (clamping a before-open start to open, skipping windows that ended before start), bounded by `_maxScanDays = 4000` so an empty schedule throws `StateError` instead of looping. `workingTimeBetween` clips each window to `[start, end)` and sums; `isOpen` tests half-open membership.

**Reuse:** `BusinessCalendar` (#593) provides the holiday skip; the time-of-day open windows are the new layer. Date stepping uses calendar fields (local `_dateOnly`/`_addDays`), DST-safe, matching the #593/#592 convention.

**Tests:** 15 cases — `OpenWindow` inversion assert; `BusinessHours.uniform` weekday-only default; `isOpen` inside/before/at-close(exclusive)/weekend; `addWorkingTime` same-day fit, roll across close, weekend skip, before-open clamp, holiday skip, zero-amount identity, empty-schedule throw; `workingTimeBetween` cross-day, weekend-excluded, zero-when-end-before-start, and a round-trip against `addWorkingTime`. All pass; `flutter analyze` clean.

**Reviewer notes:** half-open window semantics are deliberate and tested (17:00 is closed when close=1020). `_atMinute` handles `minute==1440` via `DateTime(y,m,d,24,0)` normalization to next midnight. One transient `prefer_trailing_comma_always` info resolved by `dart format`. Functions ≤20 lines; file ~165 lines.

No bug archive — task did not close a bugs/*.md file.
