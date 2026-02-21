# avoid_nullable_interpolation

## 1 violation | Severity: warning

### Rule Description
Nullable value in string interpolation produces the literal text `'null'` instead of handling the null case gracefully.

### Assessment
- **False Positive**: No. Interpolating a nullable value (e.g., `'Value: $nullableVar'`) will produce the string `"Value: null"` when the variable is null. This is almost never the desired behavior and can leak the word "null" into user-visible output or processed strings.
- **Should Exclude**: No. This rule catches a real class of bugs that can produce confusing output.

### Affected Files
- `lib\string\string_extensions.dart`

### Locations
- `lib\string\string_extensions.dart:385`

### Recommended Action
FIX -- add a null check or use the `??` operator to provide a fallback value:

```dart
// Before (produces "null" literal)
'$nullableValue'

// After (safe)
'${nullableValue ?? ''}'
// or
'${nullableValue ?? 'default'}'
```

Investigate the specific context at line 385 to determine the appropriate fallback value.
