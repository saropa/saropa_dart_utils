# Quiet-hours helper (roadmap #613)

Item 2 of the second "next 10" roadmap-utilities batch. Time-of-day "do not disturb" blackout windows for deferring notifications, with midnight-wrap support.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/datetime/quiet_hours_utils.dart` (`QuietHours`, `QuietWindow`), new test, barrel export, CHANGELOG entry. ALSO a correctness fix to the just-shipped `sla_calculator_utils.dart` (same UTC bug, see below) plus a new UTC test there.

**Design:** `QuietWindow(startMinute, endMinute)` is a daily minute-of-day window; when `start > end` it WRAPS past midnight (`containsMinute` returns `m >= start || m < end`), the common overnight 22:00–07:00 case. `QuietHours.isQuiet(at)` tests membership at minute resolution. `quietUntil(at)` returns the instant quiet ends (so a held notification schedules for exactly then) or null when not quiet; it chains back-to-back/overlapping windows by repeatedly jumping to the latest end covering the cursor until a gap is reached, bounded by the window count to cap a pathological all-day config. `_endInstant` resolves a wrapped window to today (morning head) vs tomorrow (evening tail).

**Distinction from `BusinessHours` (#595):** that models a per-weekday OPEN schedule for SLA math; `QuietHours` is the every-day time-of-day blackout. Different shape, no overlap.

**UTC correctness fix (carried in the same change):** the day-stepping helpers `_dateOnly`/`_addDays` in BOTH this file and `sla_calculator_utils.dart` originally always built LOCAL `DateTime`s, so a UTC input produced local-zone result instants (wrong absolute time). Fixed both to preserve `isUtc`. The SLA bug shipped one commit earlier but was never released (sits in the unreleased changelog) and its tests only exercised local times; a new `should keep UTC inputs in UTC` SLA test now locks it, and the quiet-hours UTC test caught it.

**Tests:** 11 quiet-hours cases — `QuietWindow` zero-length assert, same-day and wrapped `containsMinute`; `isQuiet` night/morning true, daytime/exact-end false; `quietUntil` null-outside, evening→next-morning, after-midnight→same-morning, adjacent-window chaining, multiple independent windows, and UTC preservation. Plus 1 new SLA UTC test (SLA file now 16 cases). All pass; `flutter analyze` clean.

**Reviewer notes:** minute-resolution membership documented (seconds dropped). The chaining loop's window-count bound prevents an infinite loop on a 24h-covering config (quietUntil is ill-defined there and returns a bounded best effort). Functions ≤20 lines.

No bug archive — task did not close a bugs/*.md file (the SLA UTC fix is to unreleased same-batch code, recorded here).
