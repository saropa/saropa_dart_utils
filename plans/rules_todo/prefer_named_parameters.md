# prefer_named_parameters

## 1 violation | Severity: info

### Rule Description
Function has too many positional parameters. Named parameters improve call-site readability and make the API more self-documenting.

### Assessment
- **False Positive**: No. Too many positional parameters make function calls hard to read at the call site, as the purpose of each argument is not clear without looking at the definition.
- **Should Exclude**: No. This aligns with the project's 3-parameter limit.

### Affected Files
- `lib\gesture\swipe_properties.dart`

### Recommended Action
FIX -- convert positional parameters to named parameters. Use `required` for mandatory parameters and provide default values where appropriate. This makes call sites self-documenting.
