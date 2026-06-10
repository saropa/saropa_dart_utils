# Publish script: release-intro + log-link pre-check

`scripts/publish.py` was extended so that, before publishing, it
checks the CHANGELOG release section for (1) a plain-language human intro line
and (2) a `[log]` link pinned to the proposed version's tag. A missing intro
must prompt retry / ignore / abort, defaulting to retry. This enforces the
CHANGELOG maintenance-note convention ("each release opens with one casual line
and ends with `[log](.../vX.Y.Z/CHANGELOG.md)`; `[Unreleased]` uses `main`").

## Finish Report (2026-06-10)

### Scope

(C) docs/scripts only — Python release tooling (`scripts/publish.py`,
`scripts/modules/version_changelog.py`, `scripts/modules/constants.py`) plus a
`CHANGELOG.md` entry. No Dart `lib/` or `test/` code touched.

### Deep Review

- **Logic & Safety** — `_release_section_bounds` anchors the next-section
  boundary on `\n##\s` (leading newline) so a `##` appearing mid-line cannot
  false-trip the end of a section. `update_log_link` rewrites only the matched
  section's link (`count=1`, sliced body), verified to leave older dated
  sections untouched. Both helpers early-return `False` on a missing file or
  absent header rather than raising. No recursion, no shared mutable state.
- **Architecture & Adherence** — the new prompt loop `validate_release_intro_phase`
  mirrors the existing `run_audit_phase` structure (same retry/ignore/abort
  shape, same `ui.*` helpers, same `ExitCode` usage). The log-link base URL is a
  single module constant `LOG_LINK_BASE`, so the validator and the auto-fixer
  share one source of truth. Wired into the existing pre-check sequence right
  after `strip_unreleased_suffix`, where the header is already pinned to a
  concrete version.
- **Linter-Specific Integrity** — SKIPPED [C-NOT-IN-SCOPE] (not the saropa_lints
  project).
- **Performance** — two extra small regex passes over CHANGELOG.md during the
  pre-check phase; negligible.
- **Documentation Quality** — both new helpers and the new phase function carry
  verbose docstrings stating WHY (the `main`→tag rewrite, why a missing intro
  loops vs. why the link is mechanical, the section-boundary anchoring reason).
  The script top-docstring pre-checks list and `Version:` were updated to 2.8.
- **Refactoring** — none beyond scope.

### Testing Validation

**A. Existing-test audit.** Grepped the repo for tests referencing the changed
symbols (`version_changelog`, `update_log_link`, `has_release_intro`,
`publish`). There is **no Python test suite** in this repo — no `scripts/tests/`,
no `pytest`/`unittest` harness, no CI step that imports these modules. The Dart
`test/` tree does not reference the Python release tooling. Nothing to update or
break.

**B. New-behavior verification.** The helpers are pure functions. Verified by
executed smoke assertions (not reasoning) covering every branch:
- log-link rewrite `main`→`vX.Y.Z`, target section only, older sections intact;
- intro present (real CHANGELOG `[Unreleased]` and `1.1.6`) → `True`;
- intro absent (log-link + bullets only) → `False`;
- log link absent → `update_log_link` returns `False`;
- missing-version header → both helpers return `False`.
All assertions passed (`ALL ASSERTIONS PASS`). Syntax-checked both edited Python
files with `ast.parse`.

Introducing a dedicated Python test framework was judged a new-infrastructure
(blast-radius) decision, out of scope for this task; flagged here rather than
added silently.

### Localization

SKIPPED [C-NOT-IN-SCOPE] — no Flutter UI; the script's operator-facing terminal
strings are dev/CLI tooling, exempt from l10n by the standing rule.

### Project Maintenance & Tracking

- CHANGELOG.md — entry added under `[Unreleased] → ### Changed` describing the
  v2.8 pre-check and the two new helpers.
- README — verified, no updates needed (release tooling is not a documented
  product fact in README).
- No dependency/lockfile change.
- No TODO/plan closed by this task.
- guides reviewed — nothing user-facing changed.
- Roadmap — SKIPPED [C-NOT-IN-SCOPE].
- No bug archive — task did not close a `bugs/*.md` file.

### Persist Finish Report

Finish report saved: plans/history/2026.06/2026.06.10/publish-changelog-intro-log-link-check.md
(Case B — task closes no existing bug or plan file.)

### Commit note

The four task files (`scripts/publish.py`, `scripts/modules/version_changelog.py`,
`scripts/modules/constants.py`, `CHANGELOG.md`) were already committed by an
automated hook in `b404431` ("build(publish): auto-regenerate CAPABILITIES.md +
land v2.8 release-intro checks"). The two `.py` files still flagged by
`git status` are stat-dirty only — zero content diff vs HEAD. The other modified
files in the tree (`CHANGELOG_HISTORY.md`, `analysis_options.yaml`,
`plans/ROADMAP_TO_700.md`, `pubspec.yaml`) are pre-existing and unrelated to this
task; they were NOT committed here. This finish-report file is committed
separately.
