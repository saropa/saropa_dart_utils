# ENH-008: Tier-2 option variants on existing utilities (CSV errors, retry predicates, fuzzy score)

**Type:** Enhancement / Options on existing utilities
**Severity:** 🟢 Low
**Status:** Fixed

> These are not missing utilities — the base utility exists, but a consumer needs an
> option/variant it doesn't expose. Grouped here because each is a small addition to an
> existing file; split into separate `ENH-NNN` files if any is taken up individually.

---

## 1. `csv_parse_utils` — surface per-row parse errors

`parseCsv` parses, but a consumer importing user CSVs needs to **collect per-row errors**
(column-count mismatch, unterminated quote) and continue, not throw on the first bad row.
Saropa Contacts' `import/csv_parser_utils.dart` hand-rolls an error-accumulating parser
for exactly this. Suggest an opt-in result type carrying `rows` + `errors[]` (mirroring the
`ValidationErrors`-accumulating style already used by `JsonModelReader`).

```bash
grep -rnE "errors|ValidationErrors" ../saropa_dart_utils/lib/parsing/csv_parse_utils.dart   # none
```

## 2. retry helpers — per-attempt `retryIf` / `onRetry` predicates

`retryWithPolicy` / `retryWithJitter` exist (jitter is already covered — no enhancement
needed there). Missing: a `bool Function(Object error)? retryIf` (retry only on transient
errors) and a `void Function(Object error, int attempt)? onRetry` hook. Saropa Contacts'
`primitive/retry_utils.dart` `RetryOptions` carries both.

```bash
grep -rnE "retryIf|onRetry" ../saropa_dart_utils/lib/async/   # none
```

## 3. `fuzzy_search_utils` — expose a partial/token-set ratio score

`fuzzySearch` ranks matches, but a consumer doing single-best-match selection with a
threshold wants the underlying **score** (and ideally partial-ratio / token-set variants,
fuzzywuzzy-style) to set its own cutoff and pre-filter (e.g. by first letter). Saropa
Contacts' `string/string_list_fuzzy_match.dart` currently pulls the external `fuzzywuzzy`
package for this; exposing the score on `fuzzySearch` results would let it drop that dep.

---

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `import/csv_parser_utils.dart`, `primitive/retry_utils.dart`, `string/string_list_fuzzy_match.dart`

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension. All three parts of this bundled bug were taken up together.

### Part 1 — CSV per-row errors (`csv_parse_utils.dart`)
- The file had ONLY `parseCsvLine` (single line); the bug's referenced `parseCsv` did not exist. Added it as a new error-accumulating multi-row parser plus result types `CsvParseResult(rows, errors)` and `CsvRowError(lineNumber, line, message)`, mirroring the `ValidationErrors`-accumulating style the bug cited.
- Validation: unterminated quote (odd `"` count — a valid line is always even since wrapping + escaped quotes pair up) and column-count mismatch (vs `expectedColumns`, or the header row when `hasHeader`). Bad rows go to `errors` with a 1-based line number; good rows to `rows`. Blank lines skipped; trailing `\r` stripped for CRLF. Line-oriented (a quoted field spanning physical newlines is not supported — documented).

### Part 2 — retry `retryIf` (`retry_policy_utils.dart`)
- **`onRetry` already existed** on `retryWithPolicy`, contrary to the bug's "missing onRetry". Only `retryIf` was genuinely absent, so that is all that was added: a `bool Function(Object)? retryIf` that rethrows a non-retryable error immediately (before consuming attempts, the delay, or firing `onRetry`).
- **`retryWithJitter` deliberately untouched** — the bug explicitly says "jitter is already covered — no enhancement needed there."

### Part 3 — fuzzy ratio variants (`fuzzy_search_utils.dart`)
- **The per-result `score` was ALREADY public** (`FuzzySearchUtils.score`, plus the `minScore` filter), so the bug's primary "expose the score" ask was already satisfied. The genuinely missing capability was the fuzzywuzzy-style ratio *variants* the consumer needs to drop the `fuzzywuzzy` package.
- Added standalone `partialRatio` (sliding-window best substring alignment), `tokenSortRatio` (order-insensitive), and `tokenSetRatio` (shared-core vs remainder). All `[0,1]`, case-insensitive, reusing `LevenshteinUtils.ratio`.
- A `saropa_lints/avoid_unsafe_reduce` warning on the 3-element max was resolved by using `fold(0.0, ...)` instead of `reduce` (ratios are ≥ 0, so the seed is safe).

**Tests (Section 4):**
- Audit: existing `parseCsvLine` (11), `retryWithPolicy`/`retryWithJitter`, and `fuzzySearch` tests all unaffected — the additions are new symbols / new optional params. Confirmed by running the three full files.
- Added: 7 `parseCsv` cases; 3 `retryIf` cases (veto-rethrows-immediately, true-keeps-retrying, veto-skips-onRetry); 12 ratio cases across the three new functions.
- Ran `flutter test test/parsing/csv_parse_utils_test.dart test/async/retry_policy_utils_test.dart test/string/fuzzy_search_utils_test.dart` → **All 52 tests passed**.
- Ran `dart analyze` on all six changed files → **No issues found**.

**Maintenance:** CHANGELOG 1.4.1 Added section gained three entries (one per part). All three targets are existing files already listed in CODEBASE_INDEX (file-level) — no index change. README verified — no updates needed.

**Dependency note:** Same `saropa_lints ^13.12.5` situation; committed pubspec keeps `^13.12.5`, local runs use `^13.12.3`.

**Outstanding:** None. All three parts implemented, tested, analyzed clean.
