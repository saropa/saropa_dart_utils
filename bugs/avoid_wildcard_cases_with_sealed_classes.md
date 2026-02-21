# avoid_wildcard_cases_with_sealed_classes

## 1 violation | Severity: warning

### Rule Description
Switch on sealed class uses `default` or wildcard (`_`) case, which suppresses exhaustiveness checking. When a new subtype is added to the sealed class, the compiler will not flag this switch as incomplete.

### Assessment
- **False Positive**: No. This is a legitimate improvement. Removing the wildcard/default case enables the Dart compiler's exhaustiveness checking, which means adding a new subtype to the sealed class will produce a compile-time error at this switch statement, forcing the developer to handle the new case explicitly.
- **Should Exclude**: No. Exhaustiveness checking is one of the primary benefits of sealed classes and should be preserved.

### Affected Files
- `lib\int\int_string_extensions.dart`

### Locations
- `lib\int\int_string_extensions.dart:50`

### Recommended Action
FIX -- replace the `default` or wildcard (`_`) case with explicit cases for each subtype of the sealed class. This ensures:
1. All current subtypes are handled explicitly
2. Future subtypes trigger a compile-time error, preventing missed cases
3. The code is self-documenting about which cases are handled

Review the sealed class hierarchy to identify all subtypes and add explicit case handlers for each.
