# move_variable_closer_to_its_usage

## 6 violations | Severity: info

### Rule Description
Flags variable declarations that are far from where the variable is first used. Declaring variables close to their point of use improves readability by keeping related code together and reducing the cognitive distance between declaration and usage.

### Assessment
- **False Positive**: No. Moving variables closer to their usage is a well-established readability improvement. There are very few cases where declaring a variable far from its usage is intentional.
- **Should Exclude**: No. This rule aligns with the project's readability-first principles.

### Affected Files
5 lib files (specific files to be identified by running the analyzer).

### Recommended Action
FIX -- Move variable declarations to just before their first usage:

```dart
// Before
String process(String input) {
  final separator = '-';
  // ... 10 lines of other code ...
  return input.split(separator).join();
}

// After
String process(String input) {
  // ... 10 lines of other code ...
  final separator = '-';
  return input.split(separator).join();
}
```

This is a safe, non-breaking refactor. Ensure that moving the declaration does not change semantics (e.g., if the variable captures a value that changes later in the scope). Run tests after each change to verify.
