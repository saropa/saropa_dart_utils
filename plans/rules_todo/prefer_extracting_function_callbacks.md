# prefer_extracting_function_callbacks

## 1 remaining violation | Severity: info

`map_extensions.dart` violation resolved 2026-02-24 by extracting
`_writeFormattedValue` helper from `formatMap`.

### Rule Description
Function callbacks passed as arguments should be extracted to named functions rather than defined inline. This improves readability and allows reuse.

### Assessment
- **False Positive**: No. Extracting function callbacks to named functions improves readability, especially for complex transformations.
- **Should Exclude**: No. This is a legitimate code quality improvement.

### Affected Files
- `lib\html\html_utils.dart`
- `lib\map\map_extensions.dart`

### Recommended Action
FIX -- extract inline function callbacks to named functions. Use descriptive names that communicate the transformation or action being performed.
