# avoid_nested_conditional_expressions

## 9 violations | Severity: info

### Rule Description
Flags ternary expressions (`condition ? a : b`) that are nested inside other ternary expressions. Nested ternaries are difficult to read and understand, especially when they span multiple lines or involve complex conditions.

### Assessment
- **False Positive**: No. Nested ternary expressions are universally considered a readability anti-pattern. The project's own CLAUDE.md rules explicitly state: "Nested ternary (never use)".
- **Should Exclude**: No. This rule directly aligns with the project's coding standards.

### Affected Files
- `lib\datetime\date_time_extensions.dart`
- `lib\string\string_extensions.dart`

### Verification
No nested ternary found in current codebase grep; may be in split files or already fixed. Run linter for the 9 violations.

### Recommended Action
FIX -- Refactor nested ternary expressions into `if-else` statements or early return guards:

```dart
// Before (bad)
return condition1 ? value1 : condition2 ? value2 : value3;

// After (good)
if (condition1) {
  return value1;
}
if (condition2) {
  return value2;
}
return value3;
```

This is a non-breaking refactor that improves readability without changing behavior. Prioritize this fix since it violates the project's own coding standards.
