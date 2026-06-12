# Pending: `saropa_lints` 13.12.3 → 13.12.4+ bump (needs permission)

> Split out from `OUTSTANDING_FROM_REPORTS.md` (audit 2026-06-12) when items 1–4
> of that plan were closed. This is the one remaining actionable item, held back
> because it is a gated dependency change. The completed audit plan was archived
> to `plans/history/2026.06/2026.06.12/OUTSTANDING_FROM_REPORTS.md`.

## The item

- **Source report:** `plans/history/2026.06/2026.06.11/lint-hygiene-stylistic-fp-suppressions.md` — "Optional `saropa_lints` 13.12.3 → 13.12.4+ bump (awaiting user permission) would let 5 of the suppressions be removed."
- **Where:** [pubspec.yaml](pubspec.yaml) (`saropa_lints: ^13.12.3`).
- **What it unblocks:** removing 5 lint suppressions that 13.12.4+ fixes upstream
  (raised duplicate thresholds / false-positive corrections). Known affected
  sites include the `prefer_setup_teardown` suppression in
  [test/flutter/color_light_test.dart](test/flutter/color_light_test.dart) (the
  CHANGELOG `[Unreleased]` entry already notes this is fixed in 13.12.4).
- **Why gated:** a dependency version bump is a blast-radius change — it re-runs
  every lint over the whole package and can surface new diagnostics. It requires
  explicit go-ahead before editing `pubspec.yaml`.
- **Status:** NOT done; pending permission.

## When authorized

1. Bump `saropa_lints` in `pubspec.yaml` to `^13.12.4` (or the current latest).
2. `dart pub get`.
3. `dart run custom_lint` — confirm clean, then remove the 5 now-unnecessary
   suppressions and re-run to confirm no new diagnostics appear.
4. Update `CHANGELOG.md` and run `/finish`, then archive this plan to
   `plans/history/`.

## Known-accepted (carried over; no action unless project rules change)

Flagged then deliberately left because fixing them violates a checked-in project
rule. Recorded so a future reader does not re-discover them as bugs.

- [lib/datetime/hebrew_date_converter.dart:386](lib/datetime/hebrew_date_converter.dart#L386) — `prefer_returning_conditional_expressions`; collapsing requires a nested ternary, banned by `.claude/rules/dart.md`.
- [test/flutter/color_light_test.dart:128](test/flutter/color_light_test.dart#L128) — `prefer_setup_teardown`; hoisting per-test locals to `setUp` would force unrelated tests to share state, against `testing.md` "Clarity Over DRY." (This suppression is the one the 13.12.4 bump above would let us remove.)
- Source: `plans/history/2026.06/2026.06.11/lint-diagnostics-cleanup-eight-files.md`.
