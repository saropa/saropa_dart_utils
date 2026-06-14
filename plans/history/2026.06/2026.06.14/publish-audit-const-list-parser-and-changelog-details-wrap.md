# Publish-audit const-list parser fix + changelog Maintenance wrapping

The publish audit's quality report flagged two public declarations as defects —
`crash_coverage_audit.dart:70 CrashFamilyCoverage` (missing doc header) and the
same line under sparse inline comments, plus `rule_remediation_map.dart:53
RuleRemediation`. Neither is a declaration: both are the first elements of a
`const` list literal (`<CrashFamilyCoverage>[ … ]`). The audit's declaration
parser accepted any line-leading `Name(` whose parameter list did not close on
its own line, so a multi-line constructor call used as a list element was
misread as an undocumented, under-commented method declaration. Separately, the
two changelog files carried non-user-facing entries (tooling, CI, lint, tests,
refactoring, internal docs) as visible top-level sections, inconsistent with the
file's own maintenance-note convention that such entries belong inside a
collapsed `<details><summary>Maintenance</summary>` block.

## Finish Report (2026-06-14)

### Scope

(C) docs/scripts only. The Dart library (`lib/`, `test/`) is untouched. Changes
are confined to one Python tooling module (`scripts/modules/audit.py`) and the
two changelog documents (`CHANGELOG.md`, `CHANGELOG_HISTORY.md`).

### Deep review

- **`scripts/modules/audit.py`** — added `_collection_depth_before_lines`, which
  computes, per line, the net `(` + `[` nesting opened on prior lines. `{` is
  deliberately excluded so a class or function body brace (which stays open
  across all its members) does not suppress the real members inside it; strings
  and `//` comments are stripped before counting so brackets within them do not
  skew the depth; the running depth is clamped at zero so an over-close cannot
  mask a genuinely-open literal further down. Both `_iter_decls` and
  `_method_ranges` now skip any line that begins while that depth is above zero —
  the line is a constructor call used as a collection element or argument, not a
  declaration. The two iterators were the single source feeding every audit
  check (coverage histogram, doc headers, inline comments, parameter counts,
  try/catch, duplicate-class scan), so the guard removes the false positives from
  all of them at once while only ever reducing flags, never adding.
- The fix is purely additive to the parser's reject logic; declarations that
  begin at bracket depth zero (every real top-level function, member, and
  constructor) are unaffected.

### Testing validation

- **Existing-test audit:** grepped `test/` for the changed symbols. The only
  match, `test/suite/crash_coverage_audit_test.dart`, pins the `lib/suite`
  `kCrashCoverageAudit` data table (a published-library feature) and does not
  reference the Python audit script; it is unaffected by the parser change. No
  Dart test references `audit.py` or the changelog files. The changelog edits
  touch presentation only — no symbol, value, or string that any test pins.
- **Functional verification:** the audit was run end-to-end
  (`scripts/publish.py`, audit-only mode) before and after the change. Before:
  the two findings appeared under "Missing doc headers" and "Sparse code
  comments." After: section 3 reports "All checked methods have multiline doc
  headers," section 4 reports "All non-trivial methods have adequate inline
  comments," and section 9 still lists all five genuine `>3 parameters`
  declarations (`nthWeekdayOfMonth`, `contrastRatio`, `mapRange`, `SemverUtils`,
  `RedlineEntry`), confirming real declarations are still detected.
- The repository has no Python test harness for the audit tooling; the
  end-to-end audit run is the validation path. Adding a Python test framework was
  out of scope for a parser-reject fix.

### l10n validation

SKIPPED [C-NOT-IN-SCOPE] — no Flutter UI changed. The package is a pure-Dart
utility library with no ARB catalog, `l10n.yaml`, or user-facing display
strings, so no localization surface exists.

### Project maintenance & tracking

- **CHANGELOG.md** — the const-list parser fix is recorded under `[Unreleased]`
  (inside a `<details>Maintenance` / Tooling block), correctly separated from the
  already-published `[1.6.2]` section. The maintenance-wrapping pass moved all
  non-user-facing content into `<details><summary>Maintenance</summary>` blocks
  for `[Unreleased]`, 1.6.2, 1.6.1, 1.6.0, 1.5.1, 1.4.1, 1.4.0, 1.3.0, and
  1.2.0. For 1.6.2, behavior-changing entries that had been mislabeled under a
  "Changed (docs)" heading were promoted back to a visible `### Changed` section
  so real consumer-visible fixes are not hidden; only genuine tooling, test, and
  documentation entries are collapsed.
- **CHANGELOG_HISTORY.md** — the same convention was applied to the previously
  non-compliant archived versions: 1.1.4, 0.5.7 (its `### Changed` refactor
  only), and the "minor improvements" / "maintenance release" / "refactoring"
  one-line versions (0.4.2, 0.4.1, 0.4.0, 0.3.17, 0.3.16, 0.3.15). Concrete
  public-API changes were kept visible (0.5.2 type rename, 0.2.1 List→Iterable
  migration, 0.2.0 SDK/dependency bump, 0.0.10 nullable parameter), as were all
  bug fixes and additions.
- **Tag balance verified:** `CHANGELOG_HISTORY.md` is 40 open / 40 close / 40
  summary. `CHANGELOG.md` real tags are 11 / 11 / 11 (a raw count reads 12 opens
  because the maintenance NOTE prose contains the literal word `<details>`). No
  `### Tests` or `### Tooling` heading remains outside a details block in either
  file.
- README verified — no updates needed (it documents neither the audit script
  internals nor changelog section structure).
- No `pubspec` / dependency / release change. Roadmap: SKIPPED
  [A-NOT-IN-SCOPE]. `doc/guides` reviewed — none affected.
- No bug archive — task did not close a `bugs/*.md` file.

### Files changed

- `scripts/modules/audit.py` — added `_collection_depth_before_lines`; guarded
  `_iter_decls` and `_method_ranges` against collection-literal element lines.
- `CHANGELOG.md` — Unreleased entry for the parser fix; Maintenance wrapping
  across nine versions; 1.6.2 behavior/maintenance re-separation.
- `CHANGELOG_HISTORY.md` — Maintenance wrapping across the non-compliant
  archived versions.
