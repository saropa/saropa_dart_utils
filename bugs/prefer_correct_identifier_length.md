# prefer_correct_identifier_length

## 7 violations | Severity: info

### Rule Description
Flags identifiers that are too short (typically 1-2 characters) or too long (typically >30 characters). Short identifiers lack descriptive meaning, while excessively long identifiers reduce readability.

### Assessment
- **False Positive**: Mixed. Some short identifiers are widely accepted conventions:
  - `i`, `j`, `k` for loop indices
  - `e` for exceptions in catch blocks
  - `n` for count/number in mathematical contexts
  - `T`, `E`, `K`, `V` for type parameters

  However, other short names like `s` for a string parameter or `v` for a value may genuinely benefit from more descriptive names.
- **Should Exclude**: No, not globally. The rule catches real naming issues, but individual false positives for conventional short names should be suppressed.

### Affected Files
4 lib files (specific files to be identified by running the analyzer).

### Recommended Action
INVESTIGATE -- Review each of the 7 violations:

1. **Conventional short names** (`i`, `j`, `e`, `n` in standard contexts): Suppress with inline `// ignore:` comment.
2. **Non-standard short names** (e.g., `s`, `v`, `x` used as parameter or variable names): Rename to something descriptive (e.g., `s` -> `source`, `v` -> `value`).
3. **Overly long names**: Shorten while maintaining clarity.

Consider configuring the rule's minimum length threshold if too many conventional names are flagged:
```yaml
custom_lint:
  rules:
    - prefer_correct_identifier_length:
        min_identifier_length: 2
        max_identifier_length: 30
```
