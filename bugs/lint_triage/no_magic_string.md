# no_magic_string

## 25 violations | Severity: info

### Rule Description
Magic string literal used. Extract to named constant. The rule flags string literals that appear directly in code, suggesting they be assigned to named constants for clarity and maintainability.

### Assessment
- **False Positive**: Mixed. Some strings are clearer inline than as named constants:
  - Format specifiers (e.g., `'yyyy-MM-dd'`)
  - Common delimiters (e.g., `','`, `'.'`, `' '`)
  - Protocol prefixes (e.g., `'https://'`)
  Others may benefit from extraction, especially if used in multiple places.
- **Should Exclude**: No. The rule is generally valid but should be applied with judgment.

### Affected Files
7 lib files.

### Recommended Action
INVESTIGATE -- evaluate each magic string:
1. **Format strings and delimiters**: Often clearer inline. Suppress with `// ignore: no_magic_string` if the string is self-documenting.
2. **Repeated strings**: Extract to a named constant if the same string appears in multiple locations.
3. **Domain-specific strings**: Extract to named constants with descriptive names for clarity.
