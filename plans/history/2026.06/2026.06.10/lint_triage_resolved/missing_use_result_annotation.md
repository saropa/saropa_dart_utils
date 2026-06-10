# missing_use_result_annotation

## 7 violations | Severity: info

### Rule Description
Flags methods that return a value but are not annotated with `@useResult`. The `@useResult` annotation (from `package:meta`) causes the analyzer to emit a warning when callers ignore the return value of the annotated method, helping catch bugs where computed results are accidentally discarded.

### Assessment
- **False Positive**: No. In a utility library, virtually all public methods are pure functions whose return values are the entire point of calling them. Adding `@useResult` protects downstream consumers from silently discarding results.
- **Should Exclude**: No. This rule improves API safety for library consumers.

### Affected Files
4 lib files (specific files to be identified by running the analyzer).

### Recommended Action
FIX -- Add `@useResult` annotation to methods whose return values should not be ignored:

```dart
import 'package:meta/meta.dart';

// Before
String truncate(int maxLength) { ... }

// After
@useResult
String truncate(int maxLength) { ... }
```

Considerations:
- Apply `@useResult` to all pure functions that compute and return a value.
- Do not apply to methods that are primarily called for side effects (rare in this library).
- The `meta` package is already a transitive dependency via Flutter/Dart SDK, so no new dependency is needed.
- This is a non-breaking change -- it only adds warnings for consumers who were already ignoring results (which is likely a bug on their end).
