# Publish fix — untrack gitignored artifacts blocking pub.dev release

The `publish.py` STEP 14 output reported `RELEASE v1.2.0 DID NOT REACH PUB.DEV` — the git tag and GitHub release existed, but the publish workflow run `27292809630` failed and pub.dev did not serve 1.2.0.

## Finish Report (2026-06-10)

### Scope

(C) repository hygiene / config — git tracking change only. No Dart app code (`lib/`, `test/`), no extension, no public API. Two artifacts removed from git tracking + one CHANGELOG bullet + this report.

### Root cause

The publish workflow (`.github/workflows/publish.yml`) runs `dart pub publish --dry-run` and, by deliberate design (see the comment at lines 34–38), fails the workflow on any non-zero exit. The dry run exited 65 on a single validation warning:

```
* 2 checked-in files are ignored by a `.gitignore`.
  Files that are checked in while gitignored:
  .favorites.json
  coverage/lcov.info
```

Both files were tracked in git AND matched `.gitignore` rules (`.gitignore:102` `.favorites.json`, `.gitignore:99` `coverage/`). `git check-ignore` in plain mode hid this because it skips already-tracked paths; `git check-ignore --no-index` confirmed both rule matches. The `.pubignore` tarball trim added earlier in 1.2.0 does NOT clear this warning — the warning is about git tracking state, not package contents.

### Fix

`git rm --cached .favorites.json coverage/lcov.info` — untracked both (kept on disk). Committed as `ed134ec`. Because 1.2.0 never reached pub.dev, the `v1.2.0` tag was force-moved onto `ed134ec` and force-pushed (user chose "Move v1.2.0 tag" over cutting 1.2.1), re-triggering the publish workflow.

### Verification

- Re-triggered run `27293479982` — all steps green, including **Dry run** and **Publish to pub.dev**.
- `GET https://pub.dev/api/packages/saropa_dart_utils` → `latest.version = 1.2.0`. Confirmed live on pub.dev.

### Deep review notes

- No logic/race/recursion surface — change is purely the removal of two files from the git index.
- Architecture: correct mechanism. Untracking is the right fix vs. `.pubignore` (which the dry-run warning is independent of) or un-ignoring in `.gitignore` (these are genuine per-developer / generated artifacts that should never be tracked).
- The `.gitignore` rules themselves are correct and unchanged; only the erroneous tracking was removed.

### Testing

No automated tests apply — no Dart symbol, string, or value changed. Grep of `test/` for `.favorites` / `lcov` / `coverage` references: none pin these paths. Verification was the CI publish run itself (and per project memory, `dart pub publish --dry-run` cannot be run locally on this Windows box — a NUL packaging error — so CI is the authoritative packaging gate).

### Files

- `.favorites.json` — removed from git tracking (on disk retained)
- `coverage/lcov.info` — removed from git tracking (on disk retained)
- `CHANGELOG.md` — added a `### Fixed` bullet under `[1.2.0]` documenting the rejected first attempt and the untracking fix
- `plans/history/2026.06/2026.06.10/publish-untrack-gitignored-artifacts.md` — this report

### Outstanding

None. 1.2.0 is live on pub.dev. Unrelated: `scripts/modules/audit.py` carries pre-existing uncommitted edits from another workstream — not part of this task, left untouched.

`No bug archive — task did not close a bugs/*.md file.`
`Finish report saved: plans/history/2026.06/2026.06.10/publish-untrack-gitignored-artifacts.md`
