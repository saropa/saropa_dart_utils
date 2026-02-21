# avoid_nested_shorthands

## 9 violations | Severity: info

### Rule Description
Flags shorthand expressions (such as cascade operators `..`, null-aware operators `?.`, or spread operators `...`) that are nested inside other shorthand expressions. Deeply nested shorthand syntax sacrifices readability for brevity.

### Assessment
- **False Positive**: No. Nested shorthands reduce code clarity and align with the same readability concerns as nested ternaries. The project's principle of "junior-friendly clarity over cleverness" applies directly.
- **Should Exclude**: No. This rule supports the project's readability goals.

### Affected Files
- `lib\datetime\date_time_extensions.dart`
- `lib\string\string_extensions.dart`

### Recommended Action
FIX -- Break nested shorthand expressions into separate statements or intermediate variables:

```dart
// Before (hard to read)
return list?.map((e) => e?.trim())?.toList();

// After (clear)
final mapped = list?.map((e) => e?.trim());
return mapped?.toList();
```

This refactor should be coordinated with the `avoid_nested_conditional_expressions` fix since the same files are affected. Both changes improve readability without altering behavior.
