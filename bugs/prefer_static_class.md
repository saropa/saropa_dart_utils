# prefer_static_class

## 17 violations | Severity: info

### Rule Description
Class with only static members should be annotated or restructured. The rule flags classes that contain only static methods and no instance members, suggesting they may be better organized.

### Assessment
- **False Positive**: Mixed. The utility classes are correctly structured as static-only classes, which is the standard Dart pattern for namespacing related functions (e.g., `JsonUtils.parse()`, `Base64Utils.encode()`). However, since Dart 3.0, `abstract final class` is the preferred pattern for utility classes, preventing instantiation and inheritance.
- **Should Exclude**: No. The rule could drive a useful modernization to use `abstract final class`.

### Affected Files
13 lib files.

### Recommended Action
INVESTIGATE:
1. **Consider `abstract final class`**: Dart 3.0+ supports `abstract final class UtilityName { ... }` which prevents instantiation and inheritance, making the intent explicit.
2. **Private constructor alternative**: Adding `UtilityName._();` private constructor also prevents instantiation.
3. **Evaluate case-by-case**: Some classes may already have the right structure; others could benefit from modernization.
4. If the team decides the current pattern is acceptable, EXCLUDE the rule.
