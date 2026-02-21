# prefer_abstract_final_static_class

## 9 violations | Severity: info

### Rule Description
Flags classes that contain only static members and are not declared as `abstract final`. In Dart 3, `abstract final class` is the idiomatic way to create a namespace for static members -- it prevents both instantiation (`abstract`) and inheritance (`final`).

### Assessment
- **False Positive**: No. Utility classes like `DateTimeUtils`, `JsonUtils`, `HexUtils`, etc. contain only static methods and should not be instantiated or extended. Declaring them as `abstract final class` is the correct Dart 3 pattern.
- **Should Exclude**: No. This is a legitimate improvement that enforces proper usage of utility classes.

### Affected Files
7 lib files containing static-only utility classes (specific files to be identified by running the analyzer).

### Recommended Action
FIX -- Convert static-only utility classes to `abstract final class`:

```dart
// Before
class DateTimeUtils {
  static DateTime now() => DateTime.now();
  static String format(DateTime dt) => '...';
}

// After
abstract final class DateTimeUtils {
  static DateTime now() => DateTime.now();
  static String format(DateTime dt) => '...';
}
```

This overlaps with `prefer_final_class` (rule #6). When fixing both rules, use `abstract final class` for static-only classes and `final class` for classes with instance members. Coordinate both fixes in a single pass.

This is technically a breaking change if any consumer instantiates these classes (e.g., `DateTimeUtils()`), but since they only have static members, no consumer should be doing this.
