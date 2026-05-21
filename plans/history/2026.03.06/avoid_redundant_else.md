# avoid_redundant_else

## 13 violations | Severity: info

### Rule Description
Flags `else` blocks that are redundant because the preceding `if` block ends with a `return`, `throw`, `break`, or `continue` statement. Since the `if` block exits early, the `else` keyword is unnecessary and the code in the `else` block can be moved to the outer scope.

### Assessment
- **False Positive**: No. If an `if` block ends with a `return` or `throw`, any subsequent `else` is genuinely redundant.
- **Should Exclude**: No. Removing redundant else blocks improves readability and aligns with the project's "straight-line code over nested conditionals" principle and the Dart rule of using early return guards.

### Affected Files
- `lib\bool\bool_string_extensions.dart`
- `lib\datetime\date_time_utils.dart`
- `lib\gesture\swipe_properties.dart`
- `lib\string\string_extensions.dart`

### Recommended Action
FIX -- Remove redundant `else` blocks after early returns/throws. This is a straightforward refactor:

```dart
// Before
if (condition) {
  return value;
} else {
  // other code
}

// After
if (condition) {
  return value;
}
// other code
```

This change is safe and non-breaking since it does not alter behavior.
