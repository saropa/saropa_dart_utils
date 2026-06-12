# finish-skill: persisted reports written in AI-narration voice; commit attribution leaked

**Severity:** 🟡 Medium (no library/runtime impact; process + provenance hygiene)
**Category:** Tooling / Process (not a library bug, not a lint-exclusion decision)
**Status:** Closed

<!-- Status values: Open → Investigating → Fix Ready → Closed -->

> Process/tooling note: this does not fit the library-bug (`BUG-NNN`) or lint-exclusion
> templates in `BUG_REPORT_GUIDE.md`, because the defect is in the shared
> `~/.claude/skills/finish/SKILL.md` generator, not in `lib/` and not in a
> `saropa_lints` rule. Filed here because this repo consumes `/finish` and carries
> the resulting artifacts.

---

## Summary

The `/finish` skill (global `~/.claude/skills/finish/SKILL.md`) persisted its
finish-report `.md` files in a first-person AI-session-transcript voice rather than
a durable third-person engineering record. Two distinct symptoms:

1. **Narration voice in persisted report files.** Reports open with a `Trigger`
   section that quotes the chat prompts back ("the user asked to…", "don't wait for
   any more feedback"), carry the line **"This work will be reviewed by another AI."**,
   and use session-relative deixis ("mine", "this commit", "this finish pass", "the
   explicit mandate"). A maintainer reading the file a year later has no access to
   that conversation; the file should stand on its own.

2. **AI attribution leaked into commit messages (this repo only).** Historically,
   ~22 commits carried `Co-Authored-By: Claude …` trailers and `🤖 Generated with
   [Claude Code]` lines, violating the no-AI-attribution / no-emoji git rule.

---

## Attribution Evidence

```bash
# Commit-message attribution — saropa_dart_utils, across all refs
git log --all --pretty=format:'%b' | grep -iE 'co-authored-by|generated with|🤖' | sort | uniq -c
#   2 Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
#  17 Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
#   1 Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
#   2 🤖 Generated with [Claude Code](https://claude.com/claude-code)

# Crucial: these were NOT on the published branch
git log origin/main --pretty=format:'%b' | grep -ciE 'co-authored-by|🤖'   # -> 0

# Narration voice in persisted report files.
# NOTE: the two-marker, case-sensitive grep below UNDERCOUNTS — it misses
# "Reviewed by another AI." (capital R) and deixis like "the user asked" that
# carries neither marker. The full case-insensitive deixis sweep finds 27 files.
git grep -lE 'reviewed by another AI|^\*\*Trigger' -- '*.md'   # 24 (undercount)
git grep -liE 'reviewed by another ai|^\*\*Trigger|the user (asked|wanted|said|ran|pasted)|this finish pass|this commit|honest self-assessment|when challenged|the explicit mandate' -- 'plans/*.md'   # 27 (true surface)
```

**Root cause (generator, not this repo):** `~/.claude/skills/finish/SKILL.md`
Section 1 instructed stating *"This work will be reviewed by another AI."* and
Section 7B instructed the persisted intro be *"the user's request verbatim"* — both
seed transcript voice. Nothing in Section 7 barred session-deixis or chat-quoting in
the durable file.

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | Persisted finish reports read as third-person engineering records (what changed, why, how verified), standing independent of the chat. Commit messages carry zero AI attribution. |
| **Actual** | Reports read as AI session transcripts; ~22 historical commits carried `Co-Authored-By: Claude` / `🤖 Generated with` trailers. |

---

## Fix Applied (generator)

`~/.claude/skills/finish/SKILL.md` Section 7 (both DEFAULT and LINTER variants) now
carries a **Voice** block that mandates:
- third-person record voice, the file standing on its own without the conversation;
- lead with what the artifact does, not a `Trigger`/chat recap;
- no quoting/paraphrasing chat prompts — the intro states the problem objectively
  (symptom, defect, observed behavior);
- banned session-deixis: "mine", "this commit", "this turn", "this finish pass",
  "the explicit mandate", "when challenged", "the user asked/wanted/said", "honest
  self-assessment", first-person "I"/"we"/"my";
- reference work by *what* changed, never by *who/what* produced it; the
  "reviewed by another AI" note stays a chat-time statement and never enters the file.

Section 7B's persisted-intro instruction was changed from "the user's request
verbatim" to "the problem objectively stated … NOT the chat request quoted."

This fixes all future `/finish` runs in every project that uses the shared skill.

---

## Remediation status — this repo

- **Commit attribution:** the published branch (`origin/main`) was already clean
  (0 trailers). The ~22 attributed commits survived only in a local
  `refs/backup/original-main` backup ref left by a prior history rewrite. Those
  backup refs were dropped and `git gc --prune=now` run on 2026-06-11 → **0
  attributed objects remain, 0 dangling.** No force-push or remote rewrite was
  required (the remote was never polluted).
- **Narration voice in working report files (27 `.md`):** DONE (2026-06-11). The true
  surface was 27, not the ~24 the two-marker grep reported (see Attribution Evidence).
  All "reviewed by another AI" boilerplate lines were removed, every `**Trigger:**`
  chat-recap rewritten to an objective problem statement, and inline "the user
  asked/ran/pasted" / "this commit" deixis rephrased. Files live under
  `plans/history/**` and carry no runtime behavior. Full deixis sweep now returns 0
  (the only remaining hit is this bug file, which quotes the phrase as its subject).
- **Published-history content scrub:** NOT recommended. The narration text is file
  *content* inside internal report docs, not commit attribution; scrubbing it from
  published history means rewriting `origin/main` and force-pushing (every hash
  changes, clones/PRs/CI break, release tags dangle). The cost vastly exceeds the
  value of clean snapshots of internal docs nobody reads. Fix the working files and
  commit; leave history as the immutable record.

---

## Verification

- `git log origin/main --pretty=format:'%b' | grep -ciE 'co-authored-by|🤖'` → `0`
- After backup-ref drop + gc: `git rev-list --all | … grep co-authored-by` → `0`
- Narration scrub (full deixis sweep over `plans/*.md`) → `0`; the only repo-wide
  `'reviewed by another AI'` hit is this bug file itself.
- Future runs: generator change is in `~/.claude/skills/finish/SKILL.md`.

---

## Commits

<!-- Add commit hashes as remediation lands. -->

- `c4c71e6` — Rewrite 27 persisted finish reports into third-person record voice;
  remove "reviewed by another AI" boilerplate, objectify `**Trigger:**` sections and
  inline deixis; close this bug (full deixis sweep → 0).
