# require_public_api_documentation

## 2 violations | Severity: info

### Rule Description
Public API members (classes, methods, properties, etc.) must have dartdoc documentation. Undocumented public API makes the library harder to use.

### Assessment
- **False Positive**: No. All public API should have dartdoc comments per the project's documentation standards.
- **Should Exclude**: No. This is a fundamental documentation requirement.

### Affected Files
- `lib\int\int_nullable_extensions.dart`
- `lib\string\string_extensions.dart`

### Recommended Action
FIX -- add dartdoc comments to the undocumented public API members. Every public method needs a brief one-line summary, optional detailed explanation, and an example in the dartdoc.
