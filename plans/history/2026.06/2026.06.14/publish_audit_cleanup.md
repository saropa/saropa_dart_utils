# Publish-audit cleanup ahead of tagging 1.6.2

The pre-publish audit run by `scripts/publish.py` reported two real `dart analyze`
infos and a set of coverage/comment heuristics. One info was a `prefer_no_commented_out_code`
false hit on a prose comment that happened to contain a `name(args)` call form; the
other was `prefer_setup_teardown` on a semaphore test suite whose per-test permit
counts are the scenarios under test. The audit also flagged seven named
weekday-of-month wrappers that had no test naming them directly. The remaining audit
items were heuristic false-positives that required no code change.

## Finish Report (2026-06-14)

### Scope

(A) Dart library code and tests. No VS Code extension code, no docs/scripts behavior change.

- `lib/num/num_locale_utils.dart` — comment reword only (no logic, value, or signature change).
- `test/async/async_semaphore_utils_test.dart` — lint-suppression comment with rationale.
- `test/datetime/month_weekday_named_extensions_test.dart` — seven additive test cases.
- `CHANGELOG.md` — entries under the unreleased 1.6.2 section.

### Deep Review

- **Logic & Safety**: No executable logic changed. The `num_locale_utils.dart` edit
  rewrites three comment lines describing the existing `decimalPlaces.clamp(1, 20)`
  guard; the clamp itself is untouched. The semaphore test edit adds an `// ignore`
  directive and explanatory comment, no test body change. The weekday-wrapper tests
  are pure additions.
- **Architecture & Adherence**: The added tests follow the file's existing
  group/sample-case structure (`named ordinal-weekday wrappers — sample cases` and
  `named last-weekday wrappers — sample cases`), pinning both the resolved date and
  its `weekday` per wrapper, consistent with the surrounding cases.
- **Performance / UI-UX**: Not applicable — pure utility library, no UI.
- **Documentation Quality**: The reworded comment in `num_locale_utils.dart` keeps
  the WHY (RangeError above 20 fraction digits; parity with `formatDouble`) while
  dropping the call-syntax phrasing that read as commented-out code.
- **Refactoring**: None beyond scope.

### Audit findings — disposition

Real fixes:

1. `num_locale_utils.dart` — the `decimalPlaces`-clamp comment contained
   `formatNumberLocale(x, decimalPlaces: 25)`, a `name(args)` form that
   `prefer_no_commented_out_code` reads as disabled code. Reworded to plain prose;
   the lint clears.
2. `async_semaphore_utils_test.dart` — `prefer_setup_teardown` flagged the repeated
   `AsyncSemaphoreUtils(n)` construction. Each test's permit count IS the scenario
   under test (1 to serialize, 2 to bound concurrency), so a shared `setUp()` would
   force a single count most-but-not-all tests want and hide the parameter each case
   exercises. Suppressed with `// ignore: prefer_setup_teardown` and a rationale
   comment rather than a misleading shared fixture.
3. `month_weekday_named_extensions.dart` — `firstThursday`, `firstFriday`,
   `firstSaturday`, `secondFriday`, `secondSaturday`, `lastFriday`, `lastSaturday`
   had no test naming them directly; their contract was only covered transitively by
   the bulk non-null sweep. Added one sample-date case per wrapper pinning the
   resolved date and its `weekday`.

Heuristic false-positives left unchanged (no defect):

- `compute_stream_transformer.dart` `bind()` reported untested — exercised by every
  `.transform(ComputeStreamTransformer(...))` case; `Stream.transform` calls `bind`
  internally, so the literal method name never appears in test source.
- `isNullOrEmpty` / `isNotNullOrEmpty` reported as missing doc headers — both carry
  full multiline dartdoc; the `@Deprecated` / `@useResult` annotations sit between
  the doc block and the declaration, which the line-adjacency heuristic cannot see
  past.
- Five private graph/rate-limit helpers (`_parseRecord`, `_assemble`,
  `_neighborSets`, `_preserveCycles`, `_validatedMaxPerPeriod`) reported as
  sparse-commented — each already carries a header block comment stating intent and
  failure mode, matching the project's "comment outside the block" convention; the
  audit only counts comments inside the body.

### Testing Validation

- Existing-test audit: `formatNumberLocale` is referenced by
  `test/num/num_locale_utils_test.dart` and `test/num/num_intl_format_extensions_test.dart`.
  The `num_locale_utils.dart` change is comment-only, so no assertion could break;
  confirmed by running both files.
- Command: `flutter test test/num/num_locale_utils_test.dart test/num/num_intl_format_extensions_test.dart test/async/async_semaphore_utils_test.dart test/datetime/month_weekday_named_extensions_test.dart` → 93 passed.
- Analyzer: `dart analyze lib/num/num_locale_utils.dart test/async/async_semaphore_utils_test.dart test/datetime/month_weekday_named_extensions_test.dart` → "No issues found!" (exit 0).

### l10n Validation

SKIPPED [A-NOT-IN-SCOPE] — `saropa_dart_utils` is a pure Dart utility library with no
UI directories (`lib/components`, `lib/views`, `lib/widgets`) and no ARB files. No
user-facing strings exist.

### Project Maintenance

- CHANGELOG updated under the unreleased 1.6.2 section (new test entry plus a
  "Changed (tooling/tests)" sub-section for the two lint cleanups).
- README verified — no updates needed (no public API or product fact changed).
- No bug archive — task did not close a `bugs/*.md` file.

### Outstanding work

None. The two analyzer infos are cleared and the seven untested-wrapper flags
resolved. Remaining audit flags are heuristic limitations, not code defects.
