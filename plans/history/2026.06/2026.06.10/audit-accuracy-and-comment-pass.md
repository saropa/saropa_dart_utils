# Publish-Audit Accuracy, Untested-Method Tests, and Inline-Comment Pass

The `scripts/publish.py` audit emitted ~600 findings spanning two classes: false positives from inaccurate heuristics, and genuine gaps (untested public methods, under-commented functions). Goal: fix the audit's false-positive heuristics AND remediate the genuine findings (add tests for untested methods, add WHY-comments to under-commented functions) across the whole repository.

---

## Finish Report (2026-06-10)

### 1. Critical note

### 2. Scope
- **(A)** Dart app code — `lib/` (comment additions only, no logic change) and `test/` (new tests).
- **(C)** docs/scripts — `scripts/modules/audit.py` (heuristics rebuild), `CHANGELOG.md`.
- No (B) extension code.

### 3. Deep review
- **Logic & safety:** `lib/` edits are comments only — zero behavior change (confirmed by `dart analyze lib` clean + full suite green). `audit.py` edits are heuristic/parsing logic; validated by re-running the audit and confirming finding counts dropped to the expected accurate values.
- **Architecture & adherence:** Comments follow the project rule "comment WHY, not WHAT," hoisted to block headers where possible, placed inside function bodies (the audit's density metric counts body comments, not dartdoc headers). No duplication introduced.
- **Linter-specific integrity:** SKIPPED [not the linter project].
- **Performance / UI-UX:** No runtime code changed; n/a.
- **Documentation quality:** This task *is* documentation quality work — 61 function bodies gained genuine algorithm-intent comments.
- **Refactoring:** A real bug was surfaced (see Outstanding) and deliberately NOT fixed (out of scope; flagged instead).

### 4. Testing validation
- **A. Existing-test audit:** The `lib/` changes are comment-only, so no existing assertion can break (no string/number/symbol semantics changed). The `audit.py` changes are tooling, not covered by the Dart test suite. New test files were added for the 29 untested public methods.
- **B. New tests:** 11 new test files for the previously-untested methods (`test/url/path_query_untested_test.dart`, `test/num/num_range_extensions_untested_test.dart`, `test/regex/regex_named_group_test.dart`, `test/iterable/iterable_skip_every_nth_test.dart`, `test/map/map_default_extensions_test.dart`, `test/list/unique_to_unique_test.dart`, `test/datetime/date_time_bounds_week_test.dart`, `test/datetime/date_time_fiscal_year_test.dart`, `test/json/json_type_converters_test.dart`, `test/json/json_decode_helpers_test.dart`, `test/map/map_grandchild_test.dart`).
- **Command run:** `flutter test` → **6160 passing, 2 skipped, 0 failing.** `dart analyze lib` → **No issues found.**

### 5. Localization
SKIPPED [A — pure-Dart utility library, no Flutter UI strings; this package has no ARB catalog].

### 6. Project maintenance
- CHANGELOG: updated under `[Unreleased] → ### Changed` with the audit-accuracy + tests + comment-pass entry.
- README verified — no updates needed (no public API or capability count changed).
- No dependency/version change.
- ROADMAP_TO_400.md was already archived to this history dir earlier in the session.
- No `bugs/*.md` file describes this work → **No bug archive — task did not close a bugs/*.md file.**

### 7. Persist finish report
Finish report saved: `plans/history/2026.06/2026.06.10/audit-accuracy-and-comment-pass.md` (this file, Case B).

### Diff summary (core logic — audit.py)
- Replaced regex `_DECL_RE` with a balanced-scan `_parse_decl` / `_iter_decls` (string-stripping, expression/call-position rejection) so declarations are matched accurately.
- `_is_nonpublic_decl` skips private names, private constructors, and members of private types.
- `_method_ranges` tracks paren depth so multi-line signatures and named-param braces don't prematurely close a body; nested closures are filtered out by containment.
- Recursion check removed (all 29 hits were legitimate recursion); empty-catch check kept.
- `_count_constructs_and_comments` no longer counts plain `final`/`var`; dartdoc header lines credited toward the comment budget.
- `audit_param_test_coverage` redefined to "untested public methods" using a global `_tested_identifiers(test_root)` scan; dead `_count_tests_per_member` / `_lib_to_test_path` deleted.

### Outstanding work
- **Inline-comment pass is PARTIAL: 61 of 92 done; 31 sparse-comment findings remain.** Resume by re-running `audit.audit_code_comments(...)` to list them, then continue the per-batch pattern (body comment inside the function, avoid code-like tokens that trip `prefer_no_commented_out_code`, `dart analyze` per batch, commit, recount).
- **Genuine bug found, NOT fixed (flagged, out of scope):** `pathRelative('a/b/c', 'a/b/d')` returns `'d'` instead of `'../d'` — `pathJoin`/`pathNormalize` drop a leading `..` (documented in the new comments on those functions). Needs an explicit decision before fixing, since the `..`-dropping behavior is intentional in `pathJoin`.
