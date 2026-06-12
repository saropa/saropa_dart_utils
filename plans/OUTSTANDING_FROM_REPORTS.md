# Outstanding Items Buried in Reports (audit 2026-06-12)

> Audit of `plans/history/**` for work that was flagged inside otherwise-"done"
> reports but never built. Each candidate below was cross-checked against the
> current `lib/`/`test/` on disk (package version **1.5.1**) — items already
> resolved in later passes are listed under "Verified done — dropped" so this
> page is only live work.
>
> This file does **not** duplicate `ROADMAP_TO_700.md`. That roadmap is the
> explicit 110-item feature backlog (unbuilt by design, not "buried"). The
> items here are correctness bugs, doc inconsistencies, and hygiene gaps that
> were noted in passing inside completed task reports and then lost.

---

## Live items

### 1. `pathRelative` drops the leading `..` — relative paths that climb out are wrong  (BUG)

- **Where:** [lib/url/path_join_utils.dart:42](lib/url/path_join_utils.dart#L42) (`pathRelative`), depends on `pathJoin` (line 2) and `pathNormalize` (line 22). Roadmap #163.
- **Symptom:** `pathRelative('a/b/c', 'a/b/d')` returns `'d'` instead of `'../d'`.
- **Root cause:** `pathRelative` correctly builds `['..', 'd']`, then hands it to `pathJoin`, which discards any leading `..` with nothing to pop ([path_join_utils.dart:10-14](lib/url/path_join_utils.dart#L10-L14)). `pathNormalize` drops leading `..` the same way ([line 30-35](lib/url/path_join_utils.dart#L30-L35)). So a relative path that must ascend out of `base` can never be expressed.
- **Source report:** `plans/history/2026.06/2026.06.10/audit-accuracy-and-comment-pass.md` — "Genuine bug found, NOT fixed (flagged, out of scope): `pathRelative('a/b/c', 'a/b/d')` returns `'d'` instead of `'../d'`".
- **Fix:** `pathRelative` must join the `ups`/`rest` segments without routing leading `..` through `pathJoin`'s pop logic — e.g. `[...ups, ...rest].join('/')` directly, or a `pathJoin` variant that preserves leading parent refs. Leave `pathJoin`/`pathNormalize` pop semantics intact (other callers rely on them); fix at the `pathRelative` assembly site.
- **Verify:** add failing tests first — `pathRelative('a/b/c','a/b/d') == '../d'`, `pathRelative('a/b','a/b/c/d') == 'c/d'`, `pathRelative('a/b/c/d','a/x') == '../../../x'`, identical-path and empty-base cases.
- **Status:** ✅ FIXED 2026-06-12. `pathRelative` joins clean segments directly instead of via `pathJoin`; three up-traversal tests added in `test/url/path_query_untested_test.dart`; full suite for that file passes.

### 2. `removeLastChars` doc contradicts implementation; bounds math mixes code units with grapheme clusters  (BUG / doc)

- **Where:** [lib/string/string_manipulation_extensions.dart:183](lib/string/string_manipulation_extensions.dart#L183) (`removeLastChars`).
- **Problem:** Dartdoc (lines 171-174) says it "counts UTF-16 code units like `String.length`, not grapheme clusters, so removing characters... can split that cluster." But the impl bounds-checks with code-unit `length` and then calls `substringSafe(0, length - count)`, and `substringSafe` is **grapheme-cluster** based ([string_extensions.dart:282-297](lib/string/string_extensions.dart#L282-L297) — it uses `characters.getRange`). So:
  1. The "can split a cluster" warning is false — `substringSafe` never splits a cluster.
  2. Passing a code-unit-derived end (`length - count`) into a grapheme-indexed `getRange` gives wrong results when the string holds multi-code-unit graphemes (emoji, combining marks): `length` overcounts vs. grapheme count, so the wrong number of visible characters is removed.
- **Source report:** `plans/history/2026.06/2026.06.11/TEST-COVERAGE-migrated-utils-from-contacts.md` — "Doc fix / bounds reconciliation left for maintainer decision."
- **Decision needed (pick one), then implement + test:**
  - **(a) Grapheme semantics (recommended):** count by `characters.length`, rewrite doc to promise grapheme-cluster trimming, add emoji/combining-mark tests. Matches what `substringSafe` already does and the project's Unicode-correctness bar.
  - **(b) Code-unit semantics:** replace `substringSafe` with a plain `substring(0, length - count)`, keep the doc. Faster, but reintroduces cluster-splitting the doc warns about.
- **Verify:** add tests with `'Hi👋'.removeLastChars(1)` and a combining-mark string asserting the chosen semantics.
- **Status:** ✅ FIXED 2026-06-12 with option (a) grapheme semantics. Both `removeLastChars` and the singular-sibling `removeLastChar()` were corrected (the singular shared the identical code-unit/grapheme hybrid bug — `'a😀'.removeLastChar()` had returned `'a😀'` unchanged). Doc rewritten to promise grapheme trimming; three pre-existing emoji/combining-mark tests re-pinned to coherent results, plus a new `removeLastChar` emoji case. analyze clean.

### 3. Inline-comment audit pass is incomplete — 31 of 92 sparse-comment findings remain  (doc quality)

- **Source report:** `plans/history/2026.06/2026.06.10/audit-accuracy-and-comment-pass.md` — "Inline-comment pass is PARTIAL: 61 of 92 done; 31 sparse-comment findings remain."
- **Work:** resume the per-batch comment pass over the remaining 31 findings (the report says re-run `audit.audit_code_comments(...)` to re-list them; if that harness is unavailable, the 31 are the sparsely-commented sites in the migrated utils). Apply the WHY-not-WHAT comment standard.
- **Status:** ✅ VERIFIED COMPLETE 2026-06-12 — already remediated by later work. Re-running the report's own named source of truth, `scripts/modules/audit.py:audit_code_comments(project, lib)`, over the current `lib/` (441 files, 1798 methods scanned) returns **0 findings**: "All non-trivial methods have adequate inline comments." The 31 sparse-comment sites outstanding at 2026-06-10 were closed in sessions between then and now; no remaining work. No code change required for this item.

### 4. `avoid_misused_test_matchers` residual — raw literal matchers in tests  (test hygiene)

- **Source report:** `plans/history/2026.06/2026.06.10/lint_triage_resolved/avoid_misused_test_matchers.md` — original "373 violations across 19 test files," fix incrementally.
- **Current state (2026-06-12):** down to ~27 lines matching `, (true|false|null))` across `test/` — bulk done. The residual needs filtering: not every `, true)` is an `expect(x, true)` (some are trailing bool args to non-matcher calls). Confirm which are real `expect()` matchers, then replace `true`→`isTrue`, `false`→`isFalse`, `null`→`isNull`.
- **Status:** ✅ VERIFIED COMPLETE 2026-06-12 — no genuine violations remain. `dart run custom_lint` (the plugin that owns `avoid_misused_test_matchers`) reports **zero** occurrences of the rule across `test/`. Line-by-line inspection of all ~27 raw-literal matches confirms every one is a false positive: the `true`/`false`/`null` token sits inside the value expression or a tuple/data literal (e.g. `compareAges(null, null)`, `BetweenResult('a', null)`, `<(String, bool)>[('cat', false)]`), never in the matcher position. No code change required for this item.

### 5. `saropa_lints` 13.12.3 → 13.12.4+ bump  (maintenance — NEEDS PERMISSION)

- **Source report:** `plans/history/2026.06/2026.06.11/lint-hygiene-stylistic-fp-suppressions.md` — "Optional `saropa_lints` 13.12.3 → 13.12.4+ bump (awaiting user permission) would let 5 of the suppressions be removed."
- **Where:** [pubspec.yaml:76](pubspec.yaml#L76) (`saropa_lints: ^13.12.3`).
- **Why gated:** dependency version bump is a blast-radius change (re-runs every lint over the package). Requires explicit go-ahead before changing `pubspec.yaml`.
- **Status:** not done; pending permission.

---

## Known-accepted (recorded, no action unless rules change)

These were flagged then deliberately left because fixing them violates a checked-in
project rule. Listed so a future reader does not "rediscover" them as bugs.

- [lib/datetime/hebrew_date_converter.dart:386](lib/datetime/hebrew_date_converter.dart#L386) — `prefer_returning_conditional_expressions`; collapsing requires a nested ternary, banned by `.claude/rules/dart.md`.
- [test/flutter/color_light_test.dart:128](test/flutter/color_light_test.dart#L128) — `prefer_setup_teardown`; hoisting per-test locals to `setUp` would force unrelated tests to share state, against `testing.md` "Clarity Over DRY."
- Source: `plans/history/2026.06/2026.06.11/lint-diagnostics-cleanup-eight-files.md`.

---

## Verified done — dropped from this audit

Cross-checked against `lib/` at version 1.5.1; each was reported as deferred but is
in fact already resolved.

- **v1.1.4 release ops** (publish, bump consumer constraint) — `BUG-001/002/003` ambiguous-extension-clash, 2026.05.22. Package is now **1.5.1**; the 1.1.x release concern is moot.
- **`toDateInYear` Feb-29 leap-year crash** — `BUG-003`, 2026.03.06. Now guarded: returns `null` for Feb 29 in a non-leap target year ([date_time_extensions.dart:184-190](lib/datetime/date_time_extensions.dart#L184-L190)).
- **`pluralize` single-char guard** — `BUG-028`, 2026.03.06. The `length == 1` skip is gone; guard is now `isEmpty || count == 1` ([string_text_extensions.dart:299-302](lib/string/string_text_extensions.dart#L299-L302)).
- **`unicode_class_type.dart` over 200-line limit** — `spec-batch-build`, 2026.06.11. File is now **147 lines**.

---

## Separate backlog (pointer, not duplicated here)

`plans/ROADMAP_TO_700.md` — **110 unbuilt utility features** (items 401–700),
reconciled against `lib/` on 2026-06-11. That is the explicit feature backlog;
it is intentionally unbuilt, not buried, so it is not re-listed here.

---

## Finish Report (2026-06-12) — Item 1: `pathRelative` up-traversal

`pathRelative(base, target)` could not express a relative path that ascends out
of `base`. Given `pathRelative('a/b/c', 'a/b/d')` it returned `'d'` instead of
`'../d'`. The divergence scan and climb-out segment construction were correct —
the function built `['..', 'd']` — but it handed those segments to `pathJoin`,
whose contract is to treat a leading `..` as a parent-pop and discard it when no
prior segment exists. That pop logic is correct for `pathJoin`'s own callers and
for `pathNormalize`, but wrong for assembling a relative path, where a leading
`..` is a literal climb-out that must survive.

**Change:** `pathRelative` now joins its already-clean segments with a plain
`<String>[...ups, ...rest].join('/')` instead of routing them through `pathJoin`.
The segments need no re-normalization (the target was already passed through
`pathNormalize`, the shared base prefix was consumed, and the `ups` entries are
literal `..`), so bypassing `pathJoin` loses nothing and preserves the leading
parent references. `pathJoin` and `pathNormalize` are untouched, so their other
callers keep the pop-and-discard behavior they rely on. Identical paths still
join to `''`, matching the pre-existing same-location contract and its test.

**Verification:** `flutter analyze` on the two changed files reports no issues.
`test/url/path_query_untested_test.dart` passes (15 tests), including three new
up-traversal assertions — sibling climb (`'a/b/c'`→`'a/b/d'` = `'../d'`),
multi-level climb-then-descend (`'a/b/c/d'`→`'a/x'` = `'../../../x'`), and pure
ascent (`'a/b/c'`→`'a'` = `'../..'`) — which replace the comment that previously
documented the bug as intentionally unasserted. `test/url/path_url_test.dart`
(the `pathJoin`/`pathNormalize` coverage) still passes, confirming no regression
in the shared helpers.

Files changed: `lib/url/path_join_utils.dart`, `test/url/path_query_untested_test.dart`,
`CHANGELOG.md` (new `### Fixed` entry under `[Unreleased]`), this plan file.

The parent plan stays active: items 2–4 remain open and will be closed in
subsequent passes before the plan is archived to `plans/history/`.

---

## Finish Report (2026-06-12) — Item 2: `removeLast*` grapheme counting

`String.removeLastChar()` and `String.removeLastChars(int count)` removed a
variable, hard-to-predict number of visible characters because they bounded by
UTF-16 code units but sliced by grapheme cluster. Each computed
`substringSafe(0, length - count)`, where `length` is the code-unit count and
`substringSafe` interprets its end argument as a grapheme index. Subtracting a
code-unit count from a code-unit length and then using the result as a grapheme
index is incoherent: the number of characters actually removed depended on how
many code units the trailing graphemes occupied. The observable failure was a
no-op on multi-code-unit tails — `'a😀'.removeLastChar()` returned `'a😀'`
unchanged (the emoji's two code units pushed `length - 1` past the grapheme
count, which `substringSafe` clamped back to the full string). The
`removeLastChars` dartdoc compounded the problem by claiming the opposite of the
real behavior — "counts UTF-16 code units... can split that cluster" — when the
grapheme-based slice never splits a cluster.

The fix adopts grapheme semantics: both methods compute `characters.length`
(grapheme count) and slice `substringSafe(0, graphemeCount - count)`, preserving
the zero/negative no-op and the `>=`-empties-the-string guards against the
grapheme count. The `count` argument is now defined as a count of user-perceived
characters. This matches `substringSafe`, the already-correct sibling
`removeFirstChar()` (which slices at a constant grapheme start index and was
never affected), and the package's Unicode-correctness bar. The `removeLastChars`
dartdoc was rewritten to promise grapheme trimming; the singular `removeLastChar`
carried the identical defect three lines above and was fixed alongside. A direct
`import 'package:characters/...'` was added (`characters` is a declared runtime
dependency used pervasively across `lib/string/`). Pure-ASCII inputs are
unaffected, and a `lib/` grep confirms no internal consumer depends on the old
behavior, so the change is contained to the public API and its tests.

Three pre-existing tests that pinned the hybrid behavior — and whose own comments
admitted the dartdoc was wrong — were rewritten to pin the coherent grapheme
results (`'a😀'.removeLastChars(1)` = `'a'`, `…(2)` = `''`; decomposed
`'Café'.removeLastChars(1)` = `'Caf'`, `…(2)` = `'Ca'`), plus a new
`removeLastChar` emoji case.

Files changed: `lib/string/string_manipulation_extensions.dart`,
`test/string/string_manipulation_extensions_test.dart`, `CHANGELOG.md`, this plan
file. Items 3–4 remain open; the plan stays active.

---

## Finish Report (2026-06-12) — Item 3: inline-comment audit pass (verification)

The 2026-06-10 publish-audit comment pass closed 61 of 92 sparse-inline-comment
findings and recorded 31 as outstanding, with the instruction to resume by
re-running `audit.audit_code_comments(...)` to re-list them. That audit function
(`scripts/modules/audit.py`) flags any non-trivial method whose ratio of
explanatory inline comments to comment-worthy constructs (branches, loops,
algorithm steps) falls below the configured density floor, crediting the dartdoc
header toward the budget.

Re-running that exact function against the current `lib/` tree reports zero
findings. The scan walked 441 Dart files and 1798 method bodies and returned
"All non-trivial methods have adequate inline comments." The 31 sites that were
outstanding at 2026-06-10 were therefore remediated by intervening work, so this
item requires no further code change — it is closed by verification against the
report's own named source of truth rather than by new edits.

No `lib/`, `test/`, or `CHANGELOG.md` change accompanies this item (nothing was
under-commented to fix). The audit was run via a throwaway harness under
`d:\tmp` that imported the existing module unchanged; the harness was deleted
after use. Only this plan file records the outcome.

Item 4 remains open; the plan stays active.

---

## Finish Report (2026-06-12) — Item 4: `avoid_misused_test_matchers` residual (verification)

The 2026-06-10 lint triage recorded 373 `avoid_misused_test_matchers` violations
across 19 test files — `expect()` calls passing a bare `true`/`false`/`null`
literal in the matcher position instead of `isTrue`/`isFalse`/`isNull` — to be
cleared incrementally. A raw text scan for `, (true|false|null))` across `test/`
still returns roughly 27 lines, which left open whether any genuine violation
survived.

Inspection resolves all of them as false positives of that text scan: in every
case the `true`/`false`/`null` token sits inside the value expression being
asserted or inside a tuple/data literal, not in the matcher slot — for example
`expect(compareAges(null, null), isZero)`, `expect(const BetweenResult('a', null),
const BetweenResult('a', null))`, and `<(String, bool)>[('cat', false)]`. None is
an `expect(x, true)`-shaped misuse.

The authoritative confirmation comes from the rule's own engine: `dart run
custom_lint` (saropa_lints owns `avoid_misused_test_matchers`; `flutter analyze`
does not run custom_lint plugins, so it cannot see this rule) reports zero
occurrences across the suite. The 373 original violations were fully cleared by
intervening work; the residual was entirely a grep artifact. No test change is
required.

No `lib/`, `test/`, or `CHANGELOG.md` change accompanies this item. Only this
plan file records the outcome.

---

## Plan status (2026-06-12): all live items closed

Items 1–4 are resolved: items 1 and 2 by code fixes (with tests and CHANGELOG
entries), items 3 and 4 by verification that intervening work had already closed
them. Item 5 (`saropa_lints` version bump) is the single item deliberately left
untouched — a gated dependency change awaiting explicit permission. The two
"known-accepted" lint diagnostics remain accepted by project rule.

This plan stays ACTIVE in `plans/` solely to track the still-open item 5. Once
that bump is authorized and applied (or declined), the plan moves to
`plans/history/`.
