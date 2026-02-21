# prefer_unique_test_names

## 410 violations | Severity: info

### Rule Description
Duplicate test name found within a test file.

### Assessment
- **False Positive**: Mixed. Many of the flagged duplicates are tests with the same name inside different `group()` blocks. For example, a test named `'should return null'` might appear in both `group('methodA', ...)` and `group('methodB', ...)`, which are logically distinct contexts. Some duplicates may be genuine copy-paste errors where the same scenario is tested twice within the same group.
- **Should Exclude**: Partially. If the rule does not account for `group()` scoping, the majority of violations are false positives. If it does, the remaining violations are worth fixing.

### Affected Files
29 test files across all categories, including:
- `test\bool\bool_iterable_extensions_test.dart`
- `test\datetime\date_time_extensions_test.dart`
- `test\int\int_extensions_test.dart`
- `test\list\list_extensions_test.dart`
- `test\string\string_extensions_test.dart`
- And 24 additional test files

### Locations
410 violations across 29 test files. Most are test names that are identical across different `group()` blocks within the same file.

### Recommended Action
INVESTIGATE -- audit the test names in two passes:
1. **Same name in different groups**: These are likely false positives if the group provides sufficient context. Consider making test names more specific to include the method context, or suppress/exclude if the rule does not respect group scoping.
2. **Same name in the same group**: These are genuine duplicates that should be renamed or removed.

If the majority are group-scoped false positives, EXCLUDE by adding `prefer_unique_test_names: false` to `analysis_options_custom.yaml`. Otherwise, fix genuine duplicates incrementally.
