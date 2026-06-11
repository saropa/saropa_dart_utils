# Publish blocked by stray `2.9.` file — Windows trailing-dot index failure

The `scripts/publish.py` run aborted at the commit step (exit 128). `git add -A`
failed with `error: open("2.9."): No such file or directory` / `unable to index file '2.9.'`,
even though `2.9.` was present in the working tree.

## Root cause

A stray, untracked, 0-byte file literally named `2.9.` sat in the repo root (created 16:36).
The trailing dot is the trap: Windows (NTFS via the Win32 layer) silently strips trailing dots
and spaces from filenames, so when git recorded the intent-to-add name `2.9.` and then called
`open("2.9.")`, the OS resolved it to a different on-disk name and the open failed. One unindexable
path makes `git add -A` abort wholesale, which cascaded to "Git operations failed" and ended the
publish run.

It was NOT produced by the publish script: `SCRIPT_VERSION = "2.9"` in
`scripts/modules/constants.py`, and no code path in `scripts/publish.py` writes a bare `2.9.`
file. The file is a manual shell artifact — a `2.9`-prefixed name from an accidental redirect or
paste. It will not regenerate from the script, so no script change is warranted.

## Fix

Deleted the empty file using the Windows long-path (`\\?\`) syntax, which bypasses the Win32
trailing-dot normalization and lets the delete target the literal name:

```
Remove-Item -LiteralPath '\\?\D:\src\saropa_dart_utils\2.9.' -Force
```

`git add -A` then succeeded (only the expected CRLF→LF warning on `CHANGELOG.md` remained).

## Scope boundary

This change leaves zero tracked diff — removing an untracked file is invisible to git history,
and the release commit itself is owned by `publish.py` step 11 (`workflow.git_commit_and_push`,
version-aware message) gated by its step-2 working-tree check. The release tree was therefore
NOT pre-committed here; the correct continuation is to re-run `scripts/publish.py`.

## Finish Report (2026-06-10)

- Scope: (C) ops/working-tree only. No `lib/`, `test/`, or extension code changed.
- §3 Deep Review — SKIPPED [C]: no source changed.
- §4 Testing — SKIPPED [C]: no code symbol changed; nothing for a test to pin. The 36 staged
  files are a separate workstream's pending release content, untouched by this fix.
- §5 l10n — SKIPPED [C]: no Dart UI strings.
- §6 Maintenance — CHANGELOG not updated (removing an untracked junk file ships nothing
  user-visible); README verified — no updates needed; `No bug archive — task did not close a
  bugs/*.md file`.
- §7 Persistence — Case B: this file.
- Files changed: deleted untracked `2.9.` (no git diff); added this history record.
- Outstanding: none for this fix. To complete the release, re-run `scripts/publish.py`.
