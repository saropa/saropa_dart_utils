# prefer_final_class

## 9 violations | Severity: info

### Rule Description
Flags classes that are not marked as `final`. In Dart 3, the `final` modifier on a class prevents it from being extended or implemented outside its library, enforcing a closed type hierarchy.

### Assessment
- **False Positive**: No. Utility classes in this library are not designed to be subclassed. Marking them as `final` communicates this intent and prevents misuse.
- **Should Exclude**: No. This is a legitimate improvement that enforces the library's design intent.

### Affected Files
7 lib files containing utility classes (specific files to be identified by running the analyzer).

### Recommended Action
FIX -- Add the `final` keyword to utility classes:

```dart
// Before
class DateTimeUtils {
  // ...
}

// After
final class DateTimeUtils {
  // ...
}
```

Note: This overlaps with `prefer_abstract_final_static_class` (rule #7). For classes that contain only static members, prefer `abstract final class` instead of just `final class`. Coordinate fixes for both rules together to avoid redundant changes.

This is a non-breaking change for downstream users since utility classes should not be extended.
