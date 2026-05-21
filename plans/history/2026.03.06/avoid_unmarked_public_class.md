# avoid_unmarked_public_class

## 18 violations | Severity: info

### Rule Description
Public class without `@sealed`, `@immutable`, or similar annotation. The rule expects public classes to declare their inheritance intent via annotations.

### Assessment
- **False Positive**: Yes, for this project. The utility classes in this library contain only static methods and serve as namespaces for grouping related functionality. They are not designed for instantiation or inheritance. Adding `@sealed` or `@immutable` annotations to static-only utility classes provides no meaningful information and adds clutter.
- **Should Exclude**: Yes. This rule is not useful for a library of static utility classes and extension methods.

### Affected Files
13 lib files (all utility classes).

### Recommended Action
EXCLUDE -- add `avoid_unmarked_public_class: false` to `analysis_options_custom.yaml`. The utility classes are static-only containers and do not benefit from inheritance annotations. Alternatively, if keeping the rule, consider using `abstract final class` for utility classes (Dart 3.0+ pattern) which prevents both instantiation and inheritance.
