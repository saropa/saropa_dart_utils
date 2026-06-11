# Publish-audit false positive: value-class constructor flagged "untested"

The publish audit reported `lib/parsing/csv_parse_utils.dart:6 CsvRowError() 3 params, untested (no test references it)`, raising the question of how `/finish` missed it. Investigation showed it was largely a false positive — the audit's "untested public methods" check matched the constructor's name token in `test/`, but `CsvRowError` is only ever built inside `parseCsv` and returned, so tests assert its fields off the returned instances without ever writing the type name. A genuine sub-gap existed (the `.line` field and `toString()` were never read). Both the test gap and the audit heuristic were fixed.

## Finish Report (2026-06-11)

**Scope:** (A) Dart test code + (C) Python tooling / docs. No `lib/` app code, no Flutter UI, no VS Code extension.

### Deep review

- **Logic & safety:** `_constructor_field_names` brace-matches from the class declaration to its closing brace. Guards: returns `None` when the declaration name != enclosing type (not a constructor), `set()` when the class opener can't be located. `seen_open`/`depth` correctly bound the body scan. No recursion, no unbounded loops (range over file lines).
- **Architecture & adherence:** reuses existing `_TYPE_DECL_RE` and `_enclosing_type_name`; adds one focused regex (`_FIELD_DECL_RE`) next to sibling decl regexes. The credit is applied in `audit_param_test_coverage` before the existing name-token flag, leaving the flat-token-set model (`_tested_identifiers`) intact.
- **Documentation:** both the new helper and the new regex carry WHY-comments naming the false-positive they prevent and the "all fields" conservatism choice; the call-site has a 3-line block comment.
- **Refactoring:** none beyond scope.

### Changes

1. **`test/parsing/csv_parse_utils_test.dart`** — new `CsvRowError` group: direct construction asserting all three fields (`lineNumber`, `line`, `message`), `toString()` format, and that `parseCsv` carries `.line` through verbatim. Closes the real gap (the `.line` field and `toString()` were previously unexercised). 21/21 tests pass.
2. **`scripts/modules/audit.py`** — `audit_param_test_coverage` now credits a constructor (name == enclosing type) as covered when ALL its declared public `final` instance fields are referenced anywhere in `test/`, before applying the name-token flag. Added `_FIELD_DECL_RE` and `_constructor_field_names(...)`. "All fields," not "any," so a coincidental identifier collision can't silence it; the still-flagged path and message are unchanged.
3. **`CHANGELOG.md`** — `### Tests` entry for the CsvRowError coverage and `### Tooling` entry for the audit heuristic (marked internal-only).

### Verification

- `flutter test test/parsing/csv_parse_utils_test.dart` → 21/21 pass.
- `dart analyze` on the two touched Dart files → No issues found.
- `python -m py_compile scripts/modules/audit.py` → OK.
- `_constructor_field_names` unit-probed: `CsvRowError` → `{line, lineNumber, message}`; `CsvParseResult` → `{errors, rows}`; top-level `parseCsv` → `None`. Old-test simulation (`.line` absent) → still flagged (real gap); fields-fully-covered → credited.
- Full `audit_param_test_coverage` over `lib/` → 0 untested public methods (was 1).

### Known limit

The credit is by field NAME appearing anywhere in `test/`, not attributed to the specific type — the same flat-token-set tradeoff the rest of this audit already makes (`_tested_identifiers`). A class all of whose field names coincidentally appear in unrelated tests could be credited without a dedicated test. Tightening would require real AST/type resolution — a larger change than warranted.

### Outstanding

None.
