# prefer_explicit_parameter_names

## 3 violations | Severity: info

### Rule Description
Parameter names should be explicit and descriptive (not just `a`, `b`, `x`, etc.). Descriptive names improve code readability and self-documentation.

### Assessment
- **False Positive**: Mixed. Comparator callbacks often use `a`, `b` conventionally and this is widely understood in the Dart/programming community. Other parameters should be descriptive.
- **Should Exclude**: No, but conventional callback parameter names should be evaluated individually.

### Affected Files
- `lib\iterable\iterable_extensions.dart`
- `lib\list\unique_list_extensions.dart`

### Recommended Action
INVESTIGATE -- conventional callback parameters like `a`, `b` in comparator functions are fine and widely understood. Other parameters should be renamed to be more descriptive. Evaluate each case individually.
