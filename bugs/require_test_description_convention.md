# require_test_description_convention

## 480 violations | Severity: info

### Rule Description
Test descriptions should follow a specific format such as "should [action] when [condition]". This enforces a consistent naming convention across all test files.

### Assessment
- **False Positive**: Yes, in terms of practical value. The existing test names are reasonably descriptive and follow the project's convention of using "should..." format. Enforcing a rigid "should [action] when [condition]" format across 480 tests is a massive refactor for marginal benefit. The current test names communicate intent clearly.
- **Should Exclude**: Yes. The cost of refactoring 480 tests across 23 files far outweighs the marginal readability improvement of enforcing a specific grammatical pattern.

### Affected Files
- 23 test files across the entire `test/` directory

### Recommended Action
EXCLUDE -- add `require_test_description_convention: false` to `analysis_options_custom.yaml`. The existing test names are descriptive and follow reasonable conventions. A 480-test refactor provides negligible value.
