# prefer_extracting_callbacks

## 1 violation | Severity: info

### Rule Description
Complex inline callbacks should be extracted to named functions. This improves readability, testability, and reuse.

### Assessment
- **False Positive**: No. Extracting complex callbacks to named functions improves code clarity and aligns with the project's principle of "junior-friendly clarity over cleverness."
- **Should Exclude**: No. This is a legitimate code quality improvement.

### Affected Files
- `lib\html\html_utils.dart`

### Recommended Action
FIX -- extract the complex callback to a named function. Give it a descriptive name that communicates what the callback does.
