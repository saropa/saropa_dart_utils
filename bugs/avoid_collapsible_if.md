# avoid_collapsible_if

## 2 violations | Severity: info

### Rule Description
Nested if statements that can be collapsed into a single if with `&&` should be combined. This reduces nesting depth and improves readability.

### Assessment
- **False Positive**: No. Collapsing nested if statements reduces nesting and aligns with the project's hard limit of 2 levels of nesting.
- **Should Exclude**: No. This is a legitimate code simplification.

### Affected Files
- `lib\json\json_utils.dart`

### Recommended Action
FIX -- combine nested if conditions with `&&`. For example, change `if (a) { if (b) { ... } }` to `if (a && b) { ... }`. This reduces nesting depth and makes the combined condition explicit.
