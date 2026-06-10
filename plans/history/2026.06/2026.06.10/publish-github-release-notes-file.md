# Publish script: GitHub release creation failed with "exit code 1"

Triggered by the operator pasting the v1.3.0 publish output, which showed the
package live on pub.dev but `[!] GitHub release was not created: GitHub release
failed (exit code 1)`, followed by a one-word request: "fix". The release had
reached pub.dev; only the GitHub release step failed, and its error was masked
behind a bare exit code.

## Finish Report (2026-06-10)

### Scope

(C) docs/scripts only. The change touches the Python publish tooling under
`scripts/` — no Dart `lib/`/`test/` code and no VS Code extension. The package
shipped to pub.dev is unaffected.

### Root cause

`scripts/modules/run.py` `run_capture` runs subprocess with `shell=True` on
Windows (required so `flutter.bat` / `gh` resolve from PATH —
`scripts/modules/platform.py` `get_shell_mode` returns `is_windows()`).
`create_github_release` passed the multi-line CHANGELOG section inline via
`--notes <release_notes>`. Under `shell=True` that value is handed to cmd.exe,
which interprets the changelog's newlines and shell metacharacters
(`&`, `|`, `(`, `)`, `<`, `>`, backticks) and corrupts the command line, so
`gh release create` returned exit 1. A one-word note (`--notes "test"`)
succeeds, which is why the failure looked intermittent and the auth-error
branch never matched.

### Changes

- `scripts/modules/workflow.py` `create_github_release`: write `release_notes`
  to a `tempfile.NamedTemporaryFile(suffix=".md")` and pass `--notes-file`
  instead of inline `--notes`, keeping the body off the command line entirely.
  The temp file is removed in a `finally` block (`Path(...).unlink(missing_ok=True)`)
  regardless of gh's outcome. Added `import tempfile`.
- Same function, failure path: when the auth heuristic does not match, the
  returned error now appends gh's actual stderr/stdout
  (`f"... (exit code {rc}): {detail}"`) so a future failure reports the real
  cause rather than a bare exit code.
- `scripts/modules/constants.py` + `scripts/publish.py` docstring: bump
  publisher `SCRIPT_VERSION` 2.8 -> 2.9.

### Deep review

- Logic & safety: temp-file lifecycle is leak-free (created before the call,
  unlinked in `finally`, `missing_ok=True` tolerates a never-created file). No
  recursion or concurrency introduced. `--notes-file` also sidesteps any
  command-line length ceiling the inline notes could hit on a large changelog.
- Architecture: reuses the existing `run_mod.run_capture` path; no new shell
  invocation style introduced. `--notes-file` is gh's documented mechanism for
  exactly this case, matching the manual-recovery command already printed in
  `publish.py` (`--notes-file CHANGELOG.md`).
- No duplication added; the error-detail concatenation reuses the
  `error_output` already assembled for the auth check.

### Testing validation

A. Existing-test audit: grep of `scripts/` and `test/` for `create_github_release`,
   `run_capture`, `--notes`, `notes-file` returned only the source files
   themselves — there are no Python tests for the publish tooling, so no existing
   assertion pinned the old `--notes` behavior. Nothing to update.
B. New tests: none added. The publish scripts have no test harness and adding one
   is out of scope for this fix. Verification was done by `python -m py_compile
   scripts/modules/workflow.py` (passed) and by live reproduction: `gh release
   create v1.3.0 --notes "test"` succeeded where the script's inline multi-line
   notes had failed, confirming the metacharacter/newline corruption hypothesis.

### Live recovery performed

The v1.3.0 GitHub release did not exist (the step left nothing behind). Created
it and set the real notes:
- `gh release create v1.3.0 --title "Release v1.3.0"` (created the missing release)
- `gh release edit v1.3.0 --notes-file <v1.3.0 CHANGELOG section>` (replaced the
  placeholder note with the real changelog body)
Release now live: https://github.com/saropa/saropa_dart_utils/releases/tag/v1.3.0

### Sections skipped

- l10n validation: SKIPPED [C-NOT-IN-SCOPE] — no Dart UI strings.
- CHANGELOG.md: not updated — `CHANGELOG.md` ships to pub.dev and documents the
  library API; a publish-tooling fix is not a package-consumer-visible change.
  The record is the `SCRIPT_VERSION` bump + commit message. README verified —
  no updates needed.
- Bug archive: No bug archive — task did not close a `bugs/*.md` file.

### Files changed

- `scripts/modules/workflow.py`
- `scripts/modules/constants.py`
- `scripts/publish.py`

Core fix committed as `130a8e7`.
