# avoid_excessive_expressions

## 8 violations | Severity: info

### Rule Description
Flags functions or methods that contain too many expressions, indicating excessive complexity. Functions with many expressions are harder to understand, test, and maintain. The threshold is typically configurable but defaults to around 10-15 expressions.

### Assessment
- **False Positive**: No. The project enforces a hard limit of 20 lines per function. Functions with excessive expressions likely exceed or approach this limit and should be decomposed.
- **Should Exclude**: No. This rule directly supports the project's "functions <= 20 lines" hard limit.

### Affected Files
5 lib files (specific files to be identified by running the analyzer).

### Verification
Run the linter for current locations; refactor each flagged method into smaller helpers (≤20 lines, project limit).

### Recommended Action
FIX -- Refactor complex methods into smaller, focused helper functions:

1. Identify the logical sub-tasks within each flagged method.
2. Extract each sub-task into a private helper method with a descriptive name.
3. Ensure each resulting method has a single responsibility.
4. Verify that the refactored code passes all existing tests.

```dart
// Before
String complexMethod(String input) {
  // 15+ expressions doing multiple things
}

// After
String complexMethod(String input) {
  final normalized = _normalize(input);
  final validated = _validate(normalized);
  return _format(validated);
}
```

This refactor improves testability since individual helper methods can be unit tested independently.
