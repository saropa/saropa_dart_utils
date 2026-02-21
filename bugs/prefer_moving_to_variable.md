# prefer_moving_to_variable

## 3 violations | Severity: info

### Rule Description
An expression is used multiple times and should be stored in a local variable. Extracting repeated expressions improves readability and avoids redundant computation.

### Assessment
- **False Positive**: No. Caching repeated expressions improves both readability and performance.
- **Should Exclude**: No. This is a legitimate code quality improvement.

### Affected Files
- `lib\map\map_extensions.dart`
- `lib\uuid\uuid_utils.dart`

### Recommended Action
FIX -- extract repeated expressions to local variables. This follows the project's own Dart rules which recommend caching expensive operations (e.g., `final lowerThis = toLowerCase();`).
