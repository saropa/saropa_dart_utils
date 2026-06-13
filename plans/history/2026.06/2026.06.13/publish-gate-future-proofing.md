# Publish-gate future-proofing

Publishing v1.6.0 to pub.dev required roughly six tag → CI → fail rounds, each surfacing exactly one new WARNING-severity saropa_lints rule. The tag-triggered publish workflow runs `dart pub publish`, which invokes `dart analyze` internally and exits 65 on a single warning; nothing reproduced that check before the irreversible version tag was pushed. Because each fix needed a fresh tag to re-test, blocking warnings were discovered one at a time, at ~6 minutes per round. Two further factors compounded it: a caret dependency range let CI's fresh resolve pull a newer saropa_lints patch that promoted rules to WARNING while the older local lock showed nothing, and the local release gate treated warnings as non-blocking, so it read green while the publish failed.

## Finish Report (2026-06-13)

This work will be reviewed by another AI. (Chat-time note; not part of the durable record below.)

### Scope

(C) CI configuration and release scripts only. No Dart library code (`lib/`), no tests (`test/`), no VS Code extension. The single Dart-facing change is a dependency-constraint edit in `pubspec.yaml` (a dev_dependency version pin); no published API or runtime behavior changes.

### Deep Review

- **`.github/workflows/release_gate.yml` (new)** — runs `dart pub publish --dry-run` on every push/PR to `main`, the exact command the tag-triggered `publish.yml` enforces. Lives in its own workflow file rather than as a job in the `ci` workflow (`main.yaml`) because that workflow is `disabled_manually`; a job added there would never execute. A standalone workflow is active by default, so the gate fires regardless of the `ci` workflow's state. Confirmed live: the first push that introduced the file triggered run 27456454137, which completed `success` with the `Publish dry run` step green.
- **`scripts/modules/workflow.py` — `run_analysis`** — previously returned success on WARNING-severity findings, blocking only on errors. That diverged from the publish semantics (warnings fail the dry-run with exit 65), so the local gate read green while the tag publish failed. It now returns failure when `warning_count > 0`; INFO-severity findings remain non-blocking, matching the dry-run.
- **`scripts/publish.py`** — the comment at the `run_analysis` call site documents the warning-fatal semantics; no control-flow change beyond what `run_analysis` now returns.
- **`pubspec.yaml`** — `saropa_lints` pinned to exact `13.12.7` (was `^13.12.7`). Exact-pinning makes CI's fresh resolve and the local lock use an identical rule set, removing the version-drift path by which CI saw warnings the local environment did not. A `# ignore: prefer_caret_version_syntax` directive with an inline rationale documents the deliberate exact-pin. The pin resolves cleanly (`flutter pub get` succeeds).
- **`.github/workflows/main.yaml`** — unchanged from its prior content after an intermediate edit was reverted; the gate was extracted to the standalone file.

No logic duplication, race, or recursion risk. The two workflows share `concurrency` groups keyed on workflow + ref, so superseded runs cancel.

A course correction occurred during development and is recorded here so the reasoning survives: an initial approach used `dart run custom_lint` in both the CI job and the local gate. That command fails in this package because `custom_lint` is not a direct dependency, and the actual enforcement path is the publish dry-run's internal `dart analyze`, not a separate custom_lint runner. The approach was rebuilt against the dry-run mechanism after a verification run returned `Could not find package custom_lint`.

### Testing Validation

- **Existing-test audit** — `grep` of `test/` for `run_analysis`, `run_custom_lint`, `pre_publish_validation`, `publish.py`, and `workflow.py` returned no matches. The release scripts under `scripts/` have no unit-test suite, and no Dart test references the changed symbols. Nothing pinned the old non-blocking-warning behavior.
- **Executed verification** — the changed CI gate was exercised live: pushing the standalone workflow triggered run 27456454137, which passed (`Publish dry run` step `success`) against the current tree. Both changed Python files compile (`py_compile`, no errors). Both workflow YAML files parse (`yaml.safe_load`). The exact pin resolves (`flutter pub get`).
- **New tests** — none added; the release-tooling changes have no Dart/TS test stack in this repo, and the authoritative check is the CI dry-run itself, now wired to run pre-tag.

### Localization

SKIPPED [C-NOT-IN-SCOPE] — CI/script/config only, no user-facing strings.

### Project Maintenance

- CHANGELOG: `[Unreleased]` section added describing the three changes, scoped as release-tooling only with no published API/behavior change.
- README: verified — no updates needed (no product facts or library API changed).
- `pubspec.yaml`: the `saropa_lints` pin is the only dependency change and is the subject of the task.
- Guides: none applicable to release tooling.
- No bug archive — task did not close a `bugs/*.md` file.

### Files & Commits

- `ca2d672` — `ci(publish): gate publish dry-run pre-tag and pin saropa_lints to end publish whack-a-mole` (initial gate in `main.yaml`, `run_analysis` warning-fatal, exact pin, CHANGELOG).
- `b1e34fd` — `ci(publish): move release_gate into its own active workflow` (extracted the gate to `release_gate.yml` after finding `ci` disabled; reverted the `main.yaml` job; CHANGELOG corrected).

Both pushed to `origin/main`.

### Outstanding

None for this task. The next release should push fixes to `main` first (where `release_gate` proves the dry-run green) and only then tag, so the tag fires against an already-verified tree.
