# prefer_prefixed_global_constants

## 4 violations | Severity: info

### Rule Description
Global constants should have a prefix (e.g., k prefix) to distinguish them from local variables and other identifiers.

### Assessment
- **False Positive**: Yes. Dart convention is lowerCamelCase for constants, not k-prefixed. The k-prefix is a Flutter-specific convention inherited from C++/Objective-C traditions. This is a pure Dart utility library, not a Flutter app, so Flutter-specific naming conventions do not apply.
- **Should Exclude**: Yes. This rule conflicts with standard Dart naming conventions for a non-Flutter package.

### Affected Files
- `lib\datetime\date_constants.dart`

### Recommended Action
EXCLUDE -- add `prefer_prefixed_global_constants: false` to `analysis_options_custom.yaml`. The Dart style guide recommends lowerCamelCase for top-level constants, not the k-prefix convention.
