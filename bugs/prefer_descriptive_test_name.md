# prefer_descriptive_test_name

## 163 violations | Severity: info

### Rule Description
Test name must be descriptive and follow conventions.

### Assessment
- **False Positive**: Partially. The existing test names are reasonably descriptive in context (within their `group()` blocks), but may not meet the specific naming convention enforced by the rule. This rule typically enforces patterns like "should..." prefixes or minimum name lengths that may not match the project's established testing style.
- **Should Exclude**: Yes, unless the team wants to adopt the specific naming convention enforced by this rule. The project already has a consistent testing style, and enforcing a different convention across 163 tests would be a large churn for marginal benefit.

### Affected Files
30 test files across all categories, including:
- `test\bool\bool_string_extensions_test.dart`
- `test\datetime\date_constants_test.dart`
- `test\datetime\date_time_extensions_test.dart`
- `test\int\int_extensions_test.dart`
- `test\list\list_extensions_test.dart`
- `test\string\string_extensions_test.dart`
- And 24 additional test files

### Locations
163 violations across 30 test files. Each is a test name that does not meet the rule's descriptiveness criteria.

### Recommended Action
EXCLUDE -- add `prefer_descriptive_test_name: false` to `analysis_options_custom.yaml`. The project has an established testing style that is already reasonably descriptive within the context of `group()` blocks. Enforcing a different naming convention across 163 existing tests would be high churn with low value.

Alternatively, if adopting stricter test naming is desired, fix incrementally by:
- Ensuring all test names start with "should" or a clear verb
- Making test names self-documenting without needing to read the group name
