# ENH-008: Tier-2 option variants on existing utilities (CSV errors, retry predicates, fuzzy score)

**Type:** Enhancement / Options on existing utilities
**Severity:** 🟢 Low
**Status:** Open

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
