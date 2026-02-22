# Bug Reports Index

## 2,860 total violations across 84 unique rules

Source: `reports/20260221/20260221_162802_saropa_lints_init.log`
Linter: saropa_lints v5.0.0-beta.9 (professional tier)
Date: 2026-02-21

<!-- cspell:ignore tostring -->
---

## Rules to EXCLUDE (false positives for this project)

These rules are wrong for a pure Dart utility library and should be disabled in `analysis_options_custom.yaml`.

| Rule | Count | Severity | Reason |
|------|-------|----------|--------|
| [avoid_non_ascii_symbols](avoid_non_ascii_symbols.md) | 413 | info | Library deliberately handles Unicode, emojis, diacritics |
| [require_test_description_convention](require_test_description_convention.md) | 480 | info | Style preference; existing names are adequate |
| [prefer_descriptive_test_name](prefer_descriptive_test_name.md) | 163 | info | Existing test names are reasonably descriptive |
| [prefer_static_method](prefer_static_method.md) | 126 | info | Extension methods cannot be static by definition |
| [no_empty_string](no_empty_string.md) | 78 | info | `''` is standard Dart idiom for empty strings |
| [avoid_static_state](avoid_static_state.md) | 34 | warning | Static fields are cached RegExp/constants, not widget state |
| [avoid_unmarked_public_class](avoid_unmarked_public_class.md) | 18 | info | Static utility classes don't need annotations |
| [prefer_compute_for_heavy_work](prefer_compute_for_heavy_work.md) | 14 | info | Not a Flutter app; compute() is Flutter-specific |
| [require_https_only_test](require_https_only_test.md) | 9 | info | URL tests must test both HTTP and HTTPS |
| [prefer_prefixed_global_constants](prefer_prefixed_global_constants.md) | 4 | info | Dart convention is lowerCamelCase, not k-prefix |
| [prefer_secure_random](prefer_secure_random.md) | 3 | warning | Shuffling/randomizing, not security-sensitive |
| [avoid_barrel_files](avoid_barrel_files.md) | 1 | info | Main library entry point is required by Dart convention |
| **Total** | **1,343** | | **47% of all violations** |

e.g.

## rules are wrong for a pure Dart utility library
avoid_barrel_files: false
avoid_non_ascii_symbols: false
avoid_static_state: false
avoid_unmarked_public_class: false
no_empty_string: false
prefer_compute_for_heavy_work: false
prefer_descriptive_test_name: false
prefer_prefixed_global_constants: false
prefer_secure_random: false
prefer_static_method: false
require_https_only_test: false
require_test_description_convention: false


## Rules that are FALSE POSITIVES (suppress inline)

| Rule | Count | Severity | Reason |
|------|-------|----------|--------|
| [avoid_duplicate_number_elements](avoid_duplicate_number_elements.md) | 9 | warning | Days-in-month array has intentional duplicate values |

## Legitimate BUGS to FIX

### High Priority (warnings) — ALL RESOLVED

All 9 high-priority warning rules (59 violations) have been fixed. See `bugs/history/` for details.

### Medium Priority (info - code quality)

| Rule | Count | Severity | Impact |
|------|-------|----------|--------|
| [avoid_misused_test_matchers](avoid_misused_test_matchers.md) | 373 | warning | Better failure messages with proper matchers |
| [avoid_unnecessary_nullable_return_type](avoid_unnecessary_nullable_return_type.md) | 29 | info | Return types can be tightened |
| [avoid_unused_assignment](avoid_unused_assignment.md) | 16 | info | Dead code / logic errors |
| [avoid_redundant_else](avoid_redundant_else.md) | 13 | info | Readability improvement |
| [avoid_ignoring_return_values](avoid_ignoring_return_values.md) | 11 | info | Missed error handling |
| [avoid_nested_conditional_expressions](avoid_nested_conditional_expressions.md) | 9 | info | Nested ternaries hard to read |
| [avoid_nested_shorthands](avoid_nested_shorthands.md) | 9 | info | Nested shorthands hard to read |
| [prefer_final_class](prefer_final_class.md) | 9 | info | Utility classes shouldn't be extended |
| [prefer_abstract_final_static_class](prefer_abstract_final_static_class.md) | 9 | info | Static-only classes should be abstract final |
| [avoid_excessive_expressions](avoid_excessive_expressions.md) | 8 | info | Functions too complex |
| [missing_use_result_annotation](missing_use_result_annotation.md) | 7 | info | Add @useResult to catch ignored values |
| [move_variable_closer_to_its_usage](move_variable_closer_to_its_usage.md) | 6 | info | Readability improvement |
| [avoid_unnecessary_to_list](avoid_unnecessary_to_list.md) | 6 | info | Unnecessary list allocations |
| [avoid_variable_shadowing](avoid_variable_shadowing.md) | 5 | info | Can cause subtle bugs |
| [prefer_parentheses_with_if_null](prefer_parentheses_with_if_null.md) | 4 | info | Clarity in ?? expressions |
| [prefer_switch_expression](prefer_switch_expression.md) | 4 | info | Modernize to Dart 3 syntax |
| [prefer_set_for_lookup](prefer_set_for_lookup.md) | 3 | info | O(1) vs O(n) lookups |
| [prefer_moving_to_variable](prefer_moving_to_variable.md) | 3 | info | Cache repeated expressions |
| [avoid_string_concatenation_loop](avoid_string_concatenation_loop.md) | 2 | info | O(n^2) string building |
| [avoid_collapsible_if](avoid_collapsible_if.md) | 2 | info | Reduce nesting |
| [prefer_commenting_analyzer_ignores](prefer_commenting_analyzer_ignores.md) | 2 | info | Document why rules are suppressed |
| [prefer_addition_subtraction_assignments](prefer_addition_subtraction_assignments.md) | 1 | info | Use += / -= operators |
| [prefer_digit_separators](prefer_digit_separators.md) | 1 | info | Large number readability |
| [avoid_complex_conditions](avoid_complex_conditions.md) | 1 | info | Break complex conditions into named booleans |
| [avoid_unnecessary_if](avoid_unnecessary_if.md) | 1 | info | Simplify to direct return |
| [avoid_datetime_comparison_without_precision](avoid_datetime_comparison_without_precision.md) | 1 | info | Specify comparison precision |
| [avoid_default_tostring](avoid_default_tostring.md) | 1 | info | Add meaningful toString() |
| [prefer_simpler_boolean_expressions](prefer_simpler_boolean_expressions.md) | 1 | info | Simplify boolean logic |
| [prefer_visible_for_testing_on_members](prefer_visible_for_testing_on_members.md) | 1 | info | Document testing-only API |
| [require_list_preallocate](require_list_preallocate.md) | 3 | info | Preallocate lists before loop .add() |
| [prefer_typedefs_for_callbacks](prefer_typedefs_for_callbacks.md) | 3 | info | Extract inline function types to typedefs |
| [prefer_constrained_generics](prefer_constrained_generics.md) | 1 | info | Add `extends` clause to type parameters |

### Low Priority (documentation)

| Rule | Count | Severity | Impact |
|------|-------|----------|--------|
| [require_parameter_documentation](require_parameter_documentation.md) | 120 | info | Add parameter docs to public API |
| [require_return_documentation](require_return_documentation.md) | 99 | info | Add return docs to public API |
| [require_public_api_documentation](require_public_api_documentation.md) | 2 | info | Missing dartdoc on public API |
| [require_exception_documentation](require_exception_documentation.md) | 2 | info | Document thrown exceptions |
| [require_plural_handling](require_plural_handling.md) | 1 | info | Handle plural forms in text output |

## Rules to INVESTIGATE (case-by-case)

| Rule | Count | Severity | Notes |
|------|-------|----------|-------|
| [prefer_unique_test_names](prefer_unique_test_names.md) | 410 | info | Some are group-scoped, not true duplicates |
| [avoid_dynamic_type](avoid_dynamic_type.md) | 72 | info | JSON `dynamic` is legitimate |
| [prefer_cached_getter](prefer_cached_getter.md) | 45 | info | Extensions can't cache (false positive) |
| [no_magic_number](no_magic_number.md) | 26 | info | Well-known numbers (7, 12, 24, 60) can stay |
| [no_magic_string](no_magic_string.md) | 25 | info | Evaluate each usage |
| [avoid_large_list_copy](avoid_large_list_copy.md) | 19 | info | Audit for unnecessary copies |
| [prefer_static_class](prefer_static_class.md) | 17 | info | Consider abstract final class pattern |
| [prefer_match_file_name](prefer_match_file_name.md) | 13 | info | Check which files actually mismatch |
| [avoid_similar_names](avoid_similar_names.md) | 10 | info | Some similar names are intentional |
| [prefer_correct_identifier_length](prefer_correct_identifier_length.md) | 7 | info | Standard short names (i, j, k) are fine |
| [avoid_duplicate_string_literals_pair](avoid_duplicate_string_literals_pair.md) | 6 | info | Extract repeated strings if warranted |
| [prefer_named_boolean_parameters](prefer_named_boolean_parameters.md) | 5 | info | API-breaking change |
| [avoid_medium_length_files](avoid_medium_length_files.md) | 5 | info | Consider splitting largest files |
| [avoid_hardcoded_locale](avoid_hardcoded_locale.md) | 5 | info | May be intentional for defaults |
| [prefer_explicit_parameter_names](prefer_explicit_parameter_names.md) | 3 | info | Callback params a, b are conventional |
| [prefer_single_declaration_per_file](prefer_single_declaration_per_file.md) | 3 | info | Related classes may belong together |
| [avoid_hardcoded_duration](avoid_hardcoded_duration.md) | 4 | info | Some are self-documenting |
| [prefer_setup_teardown](prefer_setup_teardown.md) | 6 | info | Evaluate shared test setup |
| [avoid_long_length_files](avoid_long_length_files.md) | 2 | info | string_extensions.dart needs splitting |
| [avoid_very_long_length_files](avoid_very_long_length_files.md) | 1 | info | string_extensions.dart needs splitting |
| [avoid_long_parameter_list](avoid_long_parameter_list.md) | 1 | info | Exceeds 3-param project limit |
| [avoid_recursive_calls](avoid_recursive_calls.md) | 1 | info | Check if recursion is bounded |
| [avoid_generic_exceptions](avoid_generic_exceptions.md) | 1 | info | Use specific exception types |
| [avoid_if_with_many_branches](avoid_if_with_many_branches.md) | 1 | info | Convert to switch |
| [avoid_duplicate_string_literals](avoid_duplicate_string_literals.md) | 1 | info | Extract to constant |
| [prefer_extracting_callbacks](prefer_extracting_callbacks.md) | 1 | info | Extract complex callbacks |
| [prefer_extracting_function_callbacks](prefer_extracting_function_callbacks.md) | 2 | info | Extract function callbacks |
| [prefer_named_parameters](prefer_named_parameters.md) | 1 | info | Too many positional params |
| [prefer_result_pattern](prefer_result_pattern.md) | 1 | info | Evaluate Result vs throw pattern |
| [prefer_switch_with_sealed_classes](prefer_switch_with_sealed_classes.md) | 1 | info | Check if type hierarchy is sealed |

---

## Suggested `analysis_options_custom.yaml` additions

```yaml
# Rules excluded for this project (pure Dart utility library)
avoid_non_ascii_symbols: false
require_test_description_convention: false
prefer_descriptive_test_name: false
prefer_static_method: false
no_empty_string: false
avoid_static_state: false
avoid_unmarked_public_class: false
prefer_compute_for_heavy_work: false
require_https_only_test: false
prefer_prefixed_global_constants: false
prefer_secure_random: false
avoid_barrel_files: false
```
