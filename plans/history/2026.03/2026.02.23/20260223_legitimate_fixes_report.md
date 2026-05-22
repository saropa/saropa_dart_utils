# Legitimate Lint Fixes Report

**Date:** 2026-02-23
**Source:** `reports/20260223/20260223_161525_saropa_lint_report.log`
**Total violations:** 463
**False positives filed:** 4 bug reports to `d:/src/saropa_lints/bugs/`

## Summary

Of 463 violations, the breakdown is:
- **~75 false positives** (filed as bug reports against saropa_lints)
- **~290 opinionated** (mostly `prefer_blank_line_before_return` x171 -- style preference)
- **~98 legitimate fixes** needed (listed below)

---

## HIGH Priority (7 violations -- all legitimate)

### 1. `avoid_catch_all` (2 instances)
**File:** `lib/base64/base64_utils.dart`, lines 47, 86

Bare `catch` clauses without `on` type. Should use specific exception types
(e.g., `on FormatException`) instead of catch-all.

**Fix:** Replace `catch (e)` with `on FormatException catch (e)` or other
appropriate exception types.

### 2. `prefer_result_pattern` (1 instance)
**File:** `lib/enum/enum_iterable_extensions.dart`, line 14

Throwing exceptions for recoverable errors. Consider returning a result type
instead.

**Fix:** Evaluate whether this should return `null` or a `Result` type instead
of throwing.

### 3. `avoid_generic_exceptions` (1 instance)
**File:** `lib/enum/enum_iterable_extensions.dart`, line 29

Generic `Exception` thrown instead of specific type.

**Fix:** Create or use a specific exception type (e.g., `ArgumentError`).

### 4. `avoid_string_concatenation_loop` (1 instance)
**File:** `lib/json/json_utils.dart`, line 287

String `+=` in a loop causing O(n^2) allocations.

**Fix:** Use `StringBuffer` instead of string concatenation.

### 5. `avoid_parameter_mutation` (2 instances)
**File:** `lib/map/map_extensions.dart`, lines 195, 212

These already have `// ignore` comments but the rule is still firing.
The methods (`mapAddValue`, `mapRemoveValue`) are **designed** to mutate
their map parameter -- this is their documented purpose. The existing
`// ignore:` comments may not be in the correct format.

**Fix:** Verify the `// ignore:` comment syntax is correct, or add
`// ignore_for_file:` at the top.

---

## MEDIUM Priority -- Legitimate Fixes (selected)

### `avoid_redundant_else` (8 instances)
**Files:** `date_time_utils.dart`, `swipe_properties.dart`

Else clauses after early returns. These are easy mechanical fixes.

**Fix:** Remove `else` keyword after `if` blocks that `return`.

### `avoid_collapsible_if` (2 instances)
**File:** `lib/json/json_utils.dart`, lines 74, 78

Nested `if` statements that can be merged.

**Fix:** Combine conditions with `&&`.

### `avoid_high_cyclomatic_complexity` (2 instances)
**Files:** `json_utils.dart` line 68, `date_time_utils.dart` line 342

Functions with too many branches.

**Fix:** Extract helper methods to reduce branching.

### `avoid_unnecessary_nullable_return_type` (2 instances)
**File:** `lib/list/list_of_list_extensions.dart`, lines 60, 109

Return type is `T?` but function never returns `null`.

**Fix:** Change return type to non-nullable `T` if all paths return non-null.

### `avoid_unsafe_collection_methods` (1 instance)
**File:** `lib/datetime/date_time_utils.dart`, line 244

Calling `.first` on potentially empty collection.

**Fix:** Use `.firstOrNull` or add an emptiness guard.

### `avoid_excessive_expressions` (2 instances)
**Files:** `date_time_utils.dart` line 299, `string_between_extensions.dart` line 207

Expressions with >5 operators.

**Fix:** Extract sub-expressions into named variables.

### `avoid_long_parameter_list` (1 instance)
**File:** `lib/datetime/date_time_utils.dart`, line 327

Function has too many parameters.

**Fix:** Group parameters into a configuration object or use named parameters.

### `avoid_unnecessary_if` (1 instance)
**File:** `lib/datetime/date_time_utils.dart`, line 369

If/else returning `true`/`false` -- can be replaced with the condition
directly.

**Fix:** `return condition;` instead of `if (condition) return true; else return false;`

### `avoid_unused_assignment` (2 instances)
**File:** `lib/string/string_between_extensions.dart`, lines 41, 44

Variables assigned but value never used before reassignment.

**Fix:** Remove the unused initial assignment or restructure the code.

### `avoid_recursive_calls` (1 instance)
**File:** `lib/int/int_utils.dart`, line 66

Direct recursion without guaranteed depth limit.

**Fix:** Convert to iterative approach or add depth limit.

### `prefer_single_declaration_per_file` (2 instances)
**Files:** `swipe_properties.dart` line 210, `json_utils.dart` line 34

Multiple top-level declarations in one file.

**Fix:** Split into separate files.

---

## LOW Priority -- Legitimate Fixes (selected)

### `prefer_sorted_imports` (7 instances)
Various files with unsorted imports.

**Fix:** Sort imports alphabetically. Can be auto-fixed.

### `avoid_parameter_reassignment` (10 instances)
Various files reassigning function parameters.

**Fix:** Use a local variable instead of reassigning the parameter.

### `prefer_commenting_analyzer_ignores` (2 instances)
**File:** `lib/map/map_extensions.dart`, lines 137, 244

Ignore comments without explanatory text.

**Fix:** Add explanatory comments to `// ignore:` directives.

### Actual commented-out code (2 instances)
- `lib/list/list_extensions.dart` line 221 -- commented-out `safeIndex` alias
- `lib/int/int_extensions.dart` line 36 -- commented-out alternative implementation

**Fix:** Delete the commented-out code (git preserves history).

---

## OPINIONATED (290 violations -- style preferences, not bugs)

These are stylistic and should be evaluated as a batch decision:

| Rule | Count | Recommendation |
|------|------:|----------------|
| `prefer_blank_line_before_return` | 171 | Auto-fixable, apply globally or disable |
| `prefer_boolean_prefixes_for_params` | 37 | Evaluate per-method; many are fine as-is |
| `prefer_descriptive_bool_names` | 28 | Often overlaps with above; evaluate together |
| `prefer_class_over_record_return` | 12 | Records are intentional in this codebase |
| `prefer_list_first` | 13 | Replace `[0]` with `.first` -- auto-fixable |
| `prefer_for_in` | 7 | Replace index loops with for-in -- evaluate case by case |
| `prefer_all_named_parameters` | 7 | Breaking API change; defer |
| Others | 15 | Various minor style preferences |

---

## False Positive Bug Reports Filed

| Bug Report | Rule | FP Count | Filed To |
|------------|------|----------|----------|
| `prefer_no_commented_out_code_false_positive_prose_comments.md` | `prefer_no_commented_out_code` | 11 | `d:/src/saropa_lints/bugs/` |
| `avoid_medium_length_files_false_positive_counts_dartdoc.md` | `avoid_medium_length_files` | 2-4 | `d:/src/saropa_lints/bugs/` |
| `avoid_ignoring_return_values_false_positive_map_mutation_methods.md` | `avoid_ignoring_return_values` | 11 | `d:/src/saropa_lints/bugs/` |
| `avoid_dynamic_type_false_positive_json_utilities.md` | `avoid_dynamic_type` | 43 | `d:/src/saropa_lints/bugs/` |
