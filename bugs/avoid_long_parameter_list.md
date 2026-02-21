# avoid_long_parameter_list

## 1 violation | Severity: info

### Rule Description
Function has too many parameters. Long parameter lists make functions harder to call, test, and maintain. They often indicate a function is doing too much.

### Assessment
- **False Positive**: No. This exceeds the project's own hard limit of 3 parameters per function.
- **Should Exclude**: No. This violates the project's stated quality standards.

### Affected Files
- `lib\datetime\date_time_utils.dart`

### Recommended Action
FIX -- refactor using one or more of these approaches: (1) use named parameters to improve call-site readability, (2) group related parameters into a parameter object/record, (3) split the function into smaller functions with fewer parameters. The project's hard limit is 3 parameters per function.
