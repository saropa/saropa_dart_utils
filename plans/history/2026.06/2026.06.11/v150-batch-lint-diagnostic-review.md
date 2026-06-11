# v1.5.0 batch — IDE lint diagnostic review & false-positive triage

A set of IDE diagnostics from the unreleased v1.5.0 utility batch were reviewed,
with genuine false positives filed upstream in `saropa_lints`. The diagnostics covered the new
`LruLfuCacheUtils`, `ParetoOptions`, and the hierarchical-cluster test. This
record documents the triage, the local fixes, and the one upstream bug filed.

---

## Finish Report (2026-06-11)

### Scope

(A) Dart app/library code + tests in `saropa_dart_utils`. Also, by explicit user
request, a false-positive bug report authored in the **separate** `saropa_lints`
repo (committed there independently). No extension/TypeScript code touched.

### Diagnostics triaged (from the user's pasted IDE list)

| Diagnostic | File | Verdict | Action |
|---|---|---|---|
| `require_cache_expiration` `{v2}` | `lib/collections/lru_lfu_cache_utils.dart` | False positive — bounded cache caps memory by `capacity`+eviction; OOM premise false; TTL is the caller's concern | Switched inline `// ignore:` (not honored on the class decl) to file-level `// ignore_for_file:` with same-line rationale; filed upstream FP bug |
| `avoid_misused_test_matchers` ×4 | `test/collections/hierarchical_cluster_utils_test.dart` | Valid | `expect(x.length, N)` → `expect(x, hasLength(N))` (lines 56, 143, 166, 204) |
| `prefer_correct_callback_field_name` `{v5}` | `lib/collections/pareto_frontier_utils.dart` | False positive, **already fixed in saropa_lints source `{v6}`** (`_isEventCallbackType` no longer matches bare `Function`); installed v5 is stale | Added a parameter-level `// ignore:` mirroring the existing field ignore; redundant once v6 publishes (harmless) |
| cSpell ×11 | `CAPABILITIES.md` | Out of scope per project rules | Skipped |

### Deep review

- **Logic & safety:** No production logic changed. `lru_lfu_cache_utils.dart` and
  `pareto_frontier_utils.dart` changes are comment/ignore-directive only.
  `hierarchical_cluster_utils_test.dart` changes are matcher-style only —
  `hasLength(N)` asserts the same cardinality as `.length == N`, with strictly
  better failure output. No behavior delta.
- **Architecture/adherence:** The `ignore_for_file` rationale is on the same line
  (satisfies `document_analyzer_ignore_rationale`); the redundant inline ignore
  was removed (analyzer flagged it as already-ignored).
- **Refactoring:** None beyond the requested diagnostics. No out-of-scope smells
  pursued.

### Testing validation

- **Audit:** Changed lib files are comment-only (no symbols altered, no test can
  pin a comment). The changed test file is the test; running it is the audit.
- **Run:** `flutter test test/collections/hierarchical_cluster_utils_test.dart`
  → 26/26 pass. Full suite `flutter test` → 6681 pass (~2 skipped).
- **Analyze:** `flutter analyze` → "No issues found!" (saropa_dart_utils).

### Localization

SKIPPED [A-NOT-IN-SCOPE for l10n] — `saropa_dart_utils` is a pure Dart utility
library with no user-facing UI strings / ARB catalog.

### Project maintenance

- **CHANGELOG:** No new entry. The touched files are NEW in the unreleased
  `[1.5.0]` section (already fully described under `### Added`); the lint polish
  applies to code being authored in this same unreleased version and never
  shipped previously, so a "fixed lint in files added this version" line would be
  churn. Consumer-visible behavior is unchanged.
- **README:** verified — no updates needed.
- **pubspec:** unchanged by this task (already at `1.5.0` from the batch).
- **Roadmap:** not modified by this task.
- **Bug archival:** No bug archive — this task closed no `saropa_dart_utils/bugs/*.md`.

### Upstream bug filed (separate repo)

`D:\src\saropa_lints\bugs\require_cache_expiration_false_positive_bounded_lru_lfu_cache.md`
(Status: Open) + index pointer in `bugs/BUG_REPORT_GUIDE.md`. Attribution greps
confirm the rule lives at `lib/src/rules/resources/memory_management_rules.dart:720`,
registered in `lib/saropa_lints.dart:2485`. `flutter analyze` on `saropa_lints`:
clean. Committed in the `saropa_lints` repo separately.

### Files changed (saropa_dart_utils — this task's edits)

- `lib/collections/lru_lfu_cache_utils.dart` — file-level ignore + removed inline ignore
- `lib/collections/pareto_frontier_utils.dart` — parameter-level ignore
- `test/collections/hierarchical_cluster_utils_test.dart` — 4 matcher swaps
- `plans/history/2026.06/2026.06.11/v150-batch-lint-diagnostic-review.md` — this report

Note: the commit also carries the pre-existing untracked v1.5.0 batch (10 util
files + 10 test files) and its modified tracked siblings (`lib/saropa_dart_utils.dart`,
`pubspec.yaml`, `CHANGELOG.md`, `cspell.json`, `plans/ROADMAP_TO_700.md`), bundled
per the standing commit-the-tree rule. The batch was already analyze-clean and
test-green.
