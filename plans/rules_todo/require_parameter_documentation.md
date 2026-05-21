# require_parameter_documentation

## 120 violations | Severity: info

### Rule Description
Parameters of public methods should be documented in the dartdoc comment. Each parameter should have a description explaining its purpose, constraints, and default behavior.

### Assessment
- **False Positive**: No. Good documentation practice that helps consumers of the library understand the API.
- **Should Exclude**: No. This aligns with the project's documentation standards requiring comprehensive dartdoc comments.

### Affected Files
- 11 lib files (across multiple categories)

### Recommended Action
FIX incrementally -- prioritize public API methods that are most commonly used. Add `[paramName]` inline parameter descriptions in dartdoc comments. This can be done file-by-file over multiple commits. Use the Dart-preferred inline style:

```dart
/// Truncates the string to [maxLength] characters.
///
/// If [ellipsis] is provided, it is appended when truncation occurs.
String truncate(int maxLength, {String? ellipsis}) { ... }
```
