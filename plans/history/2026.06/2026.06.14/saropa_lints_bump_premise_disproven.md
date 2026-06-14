# Closed: `saropa_lints` bump did NOT unblock the suppression removals

> Was `plans/PENDING_saropa_lints_bump.md`. Closed 2026-06-14 with a **negative
> result**: the dependency bump it was gating on already happened, but it did NOT
> deliver the upstream rule fixes the plan assumed, so the suppressions it wanted
> to remove must stay. Archived here so no future reader re-attempts the removal.

## What the plan assumed

- Bumping `saropa_lints` from `13.12.3` to `13.12.4+` would let **5 lint
  suppressions be removed**, because `13.12.4` was reported (in
  `plans/history/2026.06/2026.06.11/lint-hygiene-stylistic-fp-suppressions.md`,
  line 60) to have fixed two rules upstream:
  - `prefer_correct_callback_field_name` — said to be "now {v6}" with an
    `_isEventCallbackType` exemption for clock sources / builders / thunks.
  - `avoid_string_concatenation_loop` — said to be "now {v3}" with an accumulator
    guard that exempts numeric addition.

## What actually shipped (verified 2026-06-14 at `saropa_lints: ^13.12.7`)

The bump already happened — [pubspec.yaml](../../../../pubspec.yaml) is at
`^13.12.7`, well past `13.12.4`. The cleanup the plan described was never done, so
the suppression-removal was tested empirically: each candidate `// ignore:` was
removed and the IDE/custom_lint diagnostic was observed.

**Every one of the 7 candidate suppressions re-fired.** The bump did not deliver
the fixes:

- `prefer_correct_callback_field_name` reports as **`{v5}`**, not the `{v6}` the
  2026-06-11 report claimed. The clock-source/thunk exemption never arrived in
  the installed line. 4 sites still flagged:
  - [lib/async/rate_limiter_utils.dart](../../../../lib/async/rate_limiter_utils.dart) (`now`)
  - [lib/async/sliding_window_rate_limiter_utils.dart](../../../../lib/async/sliding_window_rate_limiter_utils.dart) (`now`)
  - [lib/async/task_scheduler_utils.dart](../../../../lib/async/task_scheduler_utils.dart) (`start`)
  - [lib/collections/multi_index_collection_utils.dart](../../../../lib/collections/multi_index_collection_utils.dart) (`indexers`)
- `avoid_string_concatenation_loop` reports as **`{v3}`** and **still
  false-positives** on integer / numeric `+` (no string concatenation present).
  3 sites still flagged (the 2026-06-11 report under-counted this as 1):
  - [lib/collections/rolling_hash_utils.dart](../../../../lib/collections/rolling_hash_utils.dart) (2× rolling-hash arithmetic)
  - [lib/parsing/expression_evaluator_utils.dart](../../../../lib/parsing/expression_evaluator_utils.dart) (1× numeric addition)

All 7 suppressions were therefore **kept** (removed, re-fired, restored — net zero
change to library code).

## Disposition

- **Do NOT remove these 7 suppressions** until a future `saropa_lints` version is
  confirmed (by the same remove-and-observe test) to no longer flag them. Trust
  the rule-version tag in the diagnostic (`{v5}` / `{v3}`), not a changelog claim.
- The `prefer_setup_teardown` suppression in
  [test/flutter/color_light_test.dart](../../../../test/flutter/color_light_test.dart)
  is unaffected: it is a deliberate clarity-over-DRY choice that stays regardless
  of any version. Its comment was corrected on 2026-06-14 — it previously claimed
  the project "pins 13.12.3" and that 13.12.4 fixed it, both false.

## Known-accepted (carried over; no action unless project rules change)

- [lib/datetime/hebrew_date_converter.dart:386](../../../../lib/datetime/hebrew_date_converter.dart#L386) — `prefer_returning_conditional_expressions`; collapsing requires a nested ternary, banned by `.claude/rules/dart.md`.
- Source: `plans/history/2026.06/2026.06.11/lint-diagnostics-cleanup-eight-files.md`.
