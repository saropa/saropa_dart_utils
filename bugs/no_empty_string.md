# no_empty_string

## 78 violations | Severity: info

### Rule Description
Empty string literal `''` detected. Use a named constant for clarity. The rule suggests replacing inline empty string literals with a named constant like `kEmptyString`.

### Assessment
- **False Positive**: Yes. Empty string `''` is the standard Dart idiom for empty strings. Creating a named constant like `kEmptyString` would be less readable, not more. The Dart style guide and core libraries use `''` directly. This is overly pedantic for a utility library where empty string is a natural return value and comparison target.
- **Should Exclude**: Yes. This rule fights against standard Dart idioms and would make the code harder to read.

### Affected Files
13 lib files.

### Recommended Action
EXCLUDE -- add `no_empty_string: false` to `analysis_options_custom.yaml`. The empty string literal `''` is universally understood in Dart and replacing it with a named constant adds indirection without clarity.
