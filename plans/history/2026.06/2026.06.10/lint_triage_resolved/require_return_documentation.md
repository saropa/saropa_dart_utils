# require_return_documentation

## 99 violations | Severity: info

### Rule Description
Public methods should document their return values in the dartdoc comment. This helps consumers understand what to expect from the method.

### Assessment
- **False Positive**: No. Documenting return values is an important part of API documentation, especially for a published utility library where callers need to understand what they get back.
- **Should Exclude**: No. This aligns with the project's documentation standards.

### Affected Files
- 17 lib files (across multiple categories)

### Recommended Action
FIX incrementally -- add return value documentation to public methods. Prioritize methods with non-obvious return values or nullable returns. Use natural language in the dartdoc summary:

```dart
/// Returns the substring between [start] and [end], or `null` if
/// the delimiters are not found.
String? between(String start, String end) { ... }
```
