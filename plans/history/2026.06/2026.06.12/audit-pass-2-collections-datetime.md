# Audit Pass 2–3 — collections, datetime

Continuing the full-project correctness audit, the `lib/collections` (64 files)
and `lib/datetime` (57 files) categories were examined for algorithm accuracy,
crash-on-invalid-input, documentation accuracy, and DST/calendar correctness.
The pass surfaced two process-hanging unbounded loops, several DST-related
date-arithmetic defects, a clustering-quality defect, and a set of documentation
claims that contradicted the code. Every public method in both categories now
carries an audit-date stamp in its doc header.

## Finish Report (2026-06-12)

This work will be reviewed by another AI.

### Scope

(A) Dart library code (`lib/`, `test/`). No Flutter UI, no extension, no
shipped scripts. l10n sections out of scope (pure utility library, no
user-facing strings).

### Method

Each category was first swept by parallel read-only audit agents to surface
candidate defects, then every flagged item was re-verified by reading the
specific code and reconciling against the existing test suite before any edit.
Several agent-reported "bugs" were downgraded on verification: a collections
columnar-view "drops keys" report was a documented, test-pinned row-0-schema
choice (doc fixed instead); a priority-map "ignores priority" report matched the
test's explicit insertion-order intent (doc fixed, key-ordering flagged as a
separate breaking recommendation); a bloom-filter "24% mis-size" was actually
~2% (the agent used log2) but still warranted replacing the hand-rolled ln.

### Collections — core logic corrections

- **kmeans2D**: replaced all-centroids-at-`points[0]` seeding with maximin
  (greedy k-means++) spreading. Identical seeds never diverge under Lloyd's
  algorithm (ties break to the lowest index), so the old code collapsed the
  output to at most two clusters for any k. A first-k-distinct seeding was tried
  first but split tight pairs; maximin spreads seeds across the data.
- **bucketByTime / TimeSeriesBuffer**: floor the epoch-to-bucket division
  instead of truncating toward zero, so negative-epoch (pre-1970) timestamps
  bucket correctly; `bucketByTime` returns empty for a non-positive width.
- **BloomFilterUtils**: size the bit array with `dart:math.log` instead of a
  hand-rolled natural-log approximation.
- **DifferenceArrayUtils.addRange**: ignore a reversed range (`l > r`) as a
  no-op instead of silently corrupting the recovered array.
- Doc honesty: `StreamQuantileUtils` (exact O(n), not P²-fixed-memory; removed
  the dead no-op buffer sort), `PriorityMapUtils` (insertion-order draining, not
  key-ordered), `toColumnar` (first-row schema), `topKIndices` (order
  unspecified), `pivot_unpivot_utils` (no `unpivot` implemented).

### Datetime — core logic corrections

- **expandRecurrence**: bound an impossible rule (one that can never resolve a
  date) with a consecutive-empty-period cap and an anchor-past-`until` check, so
  it terminates instead of hanging — even under `.take(n)`. Valid infinite rules
  yield regularly and reset the counter, so they still iterate forever as
  documented.
- **fillMissing**: return the input sorted for a non-positive interval instead
  of looping forever (the grid step never advances) and exhausting memory.
- **DST/calendar fields**: `heatmapGrid`/`_weekStart`, `dayOfYear`/`numOfWeeks`
  (feeding `weekOfYear`/`weekNumber`), `getNthWeekdayOfMonthInYear`, and
  `splitByMonth` stepped local dates with `Duration(days:n)`, which drifts off
  midnight across a DST transition (and, via `difference().inDays`, reports one
  day low after a spring-forward). All now use calendar-field stepping or UTC
  date-only endpoints.
- **parseIsoWeekString**: validate the requested week against the year's actual
  ISO-week count via the week's Thursday-year; `2025-W53` (2025 has 52 weeks)
  now returns null instead of a date in 2026.
- **isAnnualDateInRange**: skip years where the annual date does not exist (Feb
  29 in a non-leap year, which `DateTime` rolls over to Mar 1) instead of
  matching the rolled-over date.
- Doc accuracy: `getEmojiDayOrNight` error/logging claim removed;
  `convertDaysToYearsAndMonths` examples corrected.

### Testing Validation

Existing tests for each changed file were read before editing; the behavior
changes were reconciled against them. New regression tests (10 total) pin the
corrected behaviors and would fail/ hang against the old code:

- collections: parallel-edge/self-loop floyd seeding analogue is in pass 1;
  here — kmeans k=3 separation, negative/zero-width time buckets, reversed
  difference-array range.
- datetime: zero-interval `fillMissing` (no hang), impossible-rule
  `expandRecurrence` (terminates), `2025-W53` rejected / `2026-W53` accepted,
  Feb-29 annual date excluded from a non-leap range and included in a leap one.

The DST-specific date bugs (heatmap, dayOfYear, getNthWeekday, splitByMonth)
are not given dedicated regression tests because they only manifest when the
host runs in a DST timezone at a specific transition; the fixes are
verified by inspection (calendar-field arithmetic is DST-invariant) and the
existing suite stays green.

Commands run and results:

- `dart analyze lib/collections test/collections` → No issues found.
- `dart analyze lib/datetime test/datetime` → No issues found.
- `flutter test test/collections` → 659 passed.
- `flutter test test/datetime` → 1541 passed (2 pre-existing skips).

### Project Maintenance & Tracking

- CHANGELOG updated under `[Unreleased]` (audit pass 2 collections, pass 3
  datetime).
- README verified — no updates needed (no public signature changes; corrections
  to internal behavior and doc text).
- No bug archive — task did not close a `bugs/*.md` file.

### Known follow-ups (flagged, not changed in this pass)

- `PriorityMapUtils` would honor numeric priority only with a `K extends
  Comparable` bound + `SplayTreeMap` — a breaking change, deferred.
- `quiet_hours_utils.quietUntil` returns a finite instant for an all-day-tiled
  window set rather than signaling "never ends."
- `time_rounding_utils.roundMinutes` and `date_time_intl_display_offset`
  `formatUtcOffset` behave correctly only within their intended domains
  (non-negative minute-of-day; minute-aligned offsets).
- `histogram_utils.histogramQuantile` produces degenerate bins on heavily
  duplicated data (defensible for that input; documented as a note).
