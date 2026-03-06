# avoid_duplicate_string_literals

## 1 violation | Severity: info

### Rule Description
A string literal is duplicated multiple times in the same file. Duplicate string literals should be extracted to a named constant to avoid typos and make updates easier.

### Assessment
- **False Positive**: Depends on context. If the string literal is used many times, extracting to a constant is worthwhile. If it appears only twice and is a simple value, the duplication may be acceptable.
- **Should Exclude**: No, but needs investigation.

### Affected Files
- `lib\bool\bool_string_extensions.dart`

### Recommended Action
INVESTIGATE -- extract the duplicated string literal to a named constant if it is repeated more than twice or if it represents a meaningful value that could change. Minor duplications of simple strings may be acceptable.

---

## Current status (verification)

- **Status:** Not implemented.
- **File:** `lib/bool/bool_string_extensions.dart`.
- **Literals:** `'true'` and `'false'` appear multiple times (in doc comments and in code: `lower == 'true'`, `lower == 'false'`, `toLowerCase() == 'true'`, `this?.toLowerCase() == 'true'`).
- **Suggested fix:** Add private constants at top of file, e.g. `static const String _trueLiteral = 'true';` and `static const String _falseLiteral = 'false';`, then use them in comparisons. Alternatively, if the linter only flags one literal, extract that one. Re-run linter after change to confirm violation is resolved.
