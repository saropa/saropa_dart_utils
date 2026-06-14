# R4 — Keep the dogfooding gate green

**Status: Active — ongoing maintenance.**
**Origin:** [SAROPA_SUITE_INTEGRATION.md](SAROPA_SUITE_INTEGRATION.md), requirement R4.
**Split out 2026-06-14.**

## Goal

`saropa_dart_utils` dev-depends on `saropa_lints` and runs the rules over its own
source. Keeping `dart run custom_lint` (and `dart analyze`) clean under that dependency
is what makes this package a credible reference implementation of the rules the suite
ships — the suite cannot recommend a fix the reference library itself trips over. This
is a continuous obligation, not a one-time task: every change keeps the gate green.

## Current state (2026-06-14)

- `pubspec.yaml` pins `saropa_lints` at exact `13.12.7`.
- The gate is green: analyze and custom_lint pass.
- **Seven lint suppressions are deliberately kept.** A prior plan assumed a
  `saropa_lints` bump (to `13.12.4+`) would fix two rules upstream and let the
  suppressions be removed. Tested empirically by the remove-and-observe method on
  2026-06-14: all seven re-fired, so they were restored. The bump premise was closed
  with a negative result —
  [history/2026.06/2026.06.14/saropa_lints_bump_premise_disproven.md](history/2026.06/2026.06.14/saropa_lints_bump_premise_disproven.md).

The seven kept suppressions:
- `prefer_correct_callback_field_name` (reports as `{v5}`) — 4 sites:
  `lib/async/rate_limiter_utils.dart`, `lib/async/sliding_window_rate_limiter_utils.dart`,
  `lib/async/task_scheduler_utils.dart`, `lib/collections/multi_index_collection_utils.dart`.
- `avoid_string_concatenation_loop` (reports as `{v3}`, false-positives on numeric `+`) —
  3 sites: `lib/collections/rolling_hash_utils.dart` (2×),
  `lib/parsing/expression_evaluator_utils.dart`.

## Open trigger (deferred until an upstream release)

When a future `saropa_lints` version is published, re-test whether
`prefer_correct_callback_field_name` and `avoid_string_concatenation_loop` still flag the
seven sites — by the same remove-and-observe method (remove the `// ignore:`, watch the
custom_lint diagnostic), trusting the rule-version tag in the diagnostic (`{v5}` / `{v3}`)
over any changelog claim. If a version stops flagging them, remove the matching
suppressions. Do not remove on the strength of a changelog note alone — that is exactly
the mistake the disproven bump premise made.

The `prefer_setup_teardown` suppression in `test/flutter/color_light_test.dart` is
unaffected by any version — it is a deliberate clarity-over-DRY choice and stays.

## How to verify

Scope analyze/custom_lint to the changed files (never the whole package by default):
`dart analyze <changed files>` and, when a suppression site is touched,
`dart run custom_lint` on that file. The gate is "green" when neither emits a warning or
error on the touched paths.
