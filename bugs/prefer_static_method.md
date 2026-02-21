# prefer_static_method

## 126 violations | Severity: info

### Rule Description
Method doesn't use `this` and could be static. The linter flags methods that don't appear to reference the instance, suggesting they could be declared as `static` instead.

### Assessment
- **False Positive**: Yes. Extension methods in Dart cannot be static by definition -- they extend a type and access `this` implicitly through the extended type. The linter is likely confused by methods that access the extended value via positional access rather than explicit `this`. All 126 violations are in extension files where `static` is not a valid modifier.
- **Should Exclude**: Yes. This rule is fundamentally incompatible with extension methods, which are the core pattern of this library. All 24 affected lib files are extension files.

### Affected Files
All 24 lib extension files.

### Recommended Action
EXCLUDE -- add `prefer_static_method: false` to `analysis_options_custom.yaml`. This rule cannot apply correctly to a library built primarily on extension methods.
