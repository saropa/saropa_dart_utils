# avoid_variable_shadowing

## 5 violations | Severity: info

### Rule Description
Flags variables that shadow (have the same name as) a variable from an outer scope. Shadowing can cause subtle bugs where the programmer intends to reference the outer variable but accidentally uses the inner one, or vice versa.

### Assessment
- **False Positive**: No. Variable shadowing is a legitimate source of bugs. Even when the shadowing is intentional, it creates confusion for future readers and maintainers.
- **Should Exclude**: No. This rule catches real bugs and aligns with the project's "junior-friendly clarity" principle.

### Affected Files
4 lib files (specific files to be identified by running the analyzer).

### Recommended Action
FIX -- Rename shadowed variables to eliminate ambiguity:

```dart
// Before (shadowing bug risk)
String process(String value) {
  if (condition) {
    final value = transform(input); // shadows parameter 'value'
    return value;
  }
  return value;
}

// After (clear)
String process(String value) {
  if (condition) {
    final transformedValue = transform(input);
    return transformedValue;
  }
  return value;
}
```

For each violation:
1. Identify the outer and inner variables with the same name.
2. Rename the inner variable to be more specific about what it represents.
3. Verify that all references to the renamed variable are updated.
4. Run tests to confirm no behavioral change.
