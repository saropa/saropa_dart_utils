# avoid_complex_conditions

## 1 violation | Severity: info

### Rule Description
Condition expressions that are too complex (too many logical operators, nested conditions, or combined comparisons) should be simplified by extracting parts into named boolean variables.

### Assessment
- **False Positive**: No. Complex conditions should be simplified for readability and maintainability, aligning with the project's principle of "junior-friendly clarity over cleverness."
- **Should Exclude**: No. This is a legitimate code quality concern.

### Affected Files
- `lib\html\html_utils.dart`

### Recommended Action
FIX -- break the complex condition into named boolean variables that describe what each part checks. For example: `final isValidTag = ...;` and `final hasContent = ...;` then `if (isValidTag && hasContent)`.
