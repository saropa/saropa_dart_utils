# Lint hygiene: suppress IDE-only stylistic-tier false positives + file upstream bugs

A batch of IDE Problems-panel diagnostics across `lib/async`, `lib/parsing`, `lib/datetime`, `lib/collections`, and `lib/url` were reviewed and fixed under this policy: no rule disabling, but local suppressions where they absolutely make sense (e.g. `// ignore: <rule> -- explanation`), and genuine false positives filed as bug reports per `D:\src\saropa_lints\bugs\BUG_REPORT_GUIDE.md`.

---

## Finish Report (2026-06-11)

### 1. Critical Note

### 2. Scope

- **(A)** Dart library code — `lib/` (comment-only `// ignore:` suppressions + two trailing commas; no logic, API, or behavior change).
- **(C)** Docs — `CHANGELOG.md`.
- Cross-repo: two false-positive bug reports authored in the **saropa_lints** repo (separate project, with the user's explicit permission via the guide).

### 3. Deep Review

- **Logic & Safety:** No executable logic changed. Every edit is either a `// ignore:` comment or a trailing comma. The two trailing commas (`business_calendar_utils.dart`, `sla_calculator_utils.dart`) were reflowed by `dart format` into multi-line argument lists — identical runtime behavior.
- **Architecture & Adherence:** Suppressions are local and reasoned, never global rule-disabling (honoring the user's policy). Each `// ignore:` carries a `-- <reason>` naming why the flagged code is correct.
- **Key finding driving the approach:** `flutter analyze lib/` is **clean**. All flagged Dart rules are saropa_lints **stylistic-tier** (opt-in, not in the project's enforced `recommended` tier); the analysis-server/IDE surfaces the full catalog while `flutter analyze` does not. So these were never project-gate failures.
- **Suppression-form correction:** the plain `// ignore: <rule>` form is **not honored** for several saropa_lints rules (confirmed via the IDE-diagnostics hook re-firing). Switched every added suppression to the qualified `// ignore: saropa_lints/<rule> -- reason` form, which the guide documents and which the hook confirmed silences them.
- **Documentation Quality:** Each suppression reason states the failure mode (e.g. "`_and()` consumes tokens; re-invocation is required, not a redundant recompute").
- **Refactoring:** None pursued beyond scope.

### 4. Testing Validation

**A. Existing-test audit (mandatory):** The edits add only comments and trailing-comma formatting — no string literal, numeric value, severity, or symbol that a test could pin was changed. Grepped the affected areas; no assertion references comment text or constructor trailing-comma layout. Ran the affected suites:

```
flutter test test/async test/parsing test/datetime test/collections test/url
→ All tests passed (2295 +, ~2 skipped)
```

`flutter analyze lib/` → **No issues found.** `dart format` → clean (the two trailing-comma files reflowed and committed in formatted form).

**B. New behavior:** None — suppressions and formatting only; no new tests warranted.

### 5. Localization (l10n) Validation

SKIPPED [A-NOT-IN-SCOPE] — `saropa_dart_utils` is a pure Dart utility library with no Flutter UI, ARB catalogs, or user-facing strings. No l10n surface exists.

### 6. Project Maintenance & Tracking

- **CHANGELOG:** Updated under `[1.4.0] → Fixed` with a bullet describing the IDE-only stylistic-FP suppressions, the qualified-ignore-form note, the two trailing commas, and the two upstream bug reports filed. Present at HEAD.
- **README:** verified — no updates needed (no product facts changed).
- **pubspec / lock:** no dependency change. (A `saropa_lints` 13.12.3 → 13.12.4+ bump was proposed to the user as an optional follow-up — it already fixes two of these FPs upstream — and is **awaiting permission**, not applied.)
- **guides reviewed** — nothing user-facing changed.
- **Roadmap:** SKIPPED — no roadmap entry opened or closed by this task.
- **LAUNCH_TEST:** n/a — not a Flutter-app repo with that file.
- **Bug-report archival:** No bug archive — task did not close a `bugs/*.md` file in this repo. (The repo's open `bugs/BUG-001..003` concern the `gen_capabilities` tool, unrelated to this work.)

### Upstream false-positive bug reports filed (saropa_lints repo)

Two rules whose logic is still wrong in current saropa_lints source (13.12.4), filed per `BUG_REPORT_GUIDE.md` with grep attribution, minimal reproducers, AST context, and root cause:

1. `bugs/prefer_reusing_assigned_local_false_positive_side_effecting_instance_method.md` — `_InitializerPurityVisitor.visitMethodInvocation` marks only PascalCase calls impure, so a side-effecting no-arg instance method (a recursive-descent parser's `_and()`/`_equality()`/`_not()`, which advance a cursor) is treated as a reusable pure read.
2. `bugs/prefer_correct_handler_name_false_positive_boolean_state_getter.md` — the rule lacks an `if (node.isGetter) return;` guard (siblings in the same file have one), so `bool get isClosed` is flagged as an event handler because its name ends in the `Closed` suffix.

Two other flagged rules were verified **already fixed upstream** and got suppressions only (no report): `prefer_correct_callback_field_name` (now `{v6}` with `_isEventCallbackType` exempting clock sources / builders / thunks) and `avoid_string_concatenation_loop` (now `{v3}` with an accumulator guard). The local ignores cover the project's installed 13.12.3 until the plugin is upgraded.

### 7. Persist Finish Report

Finish report saved: `plans/history/2026.06/2026.06.11/lint-hygiene-stylistic-fp-suppressions.md` (this file). Task closed no `bugs/*.md` and no active plan in this repo → Section 7 case B.

### 8 / 9. Commit note

The lib edits + CHANGELOG were auto-committed by a repository hook within commit `3bb9a2e` (bundled with an unrelated workstream under that commit's message). The working tree was clean at finish time; this report file is committed as a follow-up docs commit. Where the code changes live: commit `3bb9a2e`.

### Files changed by this task

`lib/async/bounded_work_queue_utils.dart`, `lib/async/rate_limiter_utils.dart`, `lib/async/read_write_lock_utils.dart`, `lib/async/sliding_window_rate_limiter_utils.dart`, `lib/async/task_scheduler_utils.dart`, `lib/collections/multi_index_collection_utils.dart`, `lib/parsing/expression_evaluator_utils.dart`, `lib/parsing/sql_filter_utils.dart`, `lib/parsing/log_line_parser_utils.dart`, `lib/url/url_template_utils.dart`, `lib/datetime/business_calendar_utils.dart`, `lib/datetime/sla_calculator_utils.dart`, `CHANGELOG.md`, and this report.

Cross-repo (saropa_lints): two new `bugs/*.md` false-positive reports.

### Diff summary of core changes

- 14 `// ignore: saropa_lints/<rule> -- reason` suppressions across 10 lib files (4× `prefer_reusing_assigned_local`, 4× `prefer_correct_callback_field_name`, 2× `prefer_boolean_prefixes`, 2× `avoid_ignoring_return_values`, 1× `prefer_correct_handler_name`, 1× `avoid_string_concatenation_loop`, 1× `prefer_cascade_over_chained` folded into an existing combined ignore).
- 2 trailing commas (`business_calendar_utils.dart`, `sla_calculator_utils.dart`) satisfying `prefer_trailing_comma_always`, reflowed by `dart format`.
- No behavior, API, or signature change anywhere.

### Outstanding

- Optional `saropa_lints` 13.12.3 → 13.12.4+ bump (awaiting user permission) would let 5 of the suppressions be removed.
