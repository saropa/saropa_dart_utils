# avoid_long_length_files

## 2 violations | Severity: info

### Rule Description
File exceeds the long length threshold. Very long files are hard to navigate, understand, and maintain. They often indicate that a file has too many responsibilities.

### Assessment
- **False Positive**: No. Very long files are hard to navigate and violate the project's own 200-line file limit.
- **Should Exclude**: No. This aligns with the project's hard limit of files being 200 lines or fewer.

### Affected Files
- `lib\datetime\date_time_extensions.dart`
- `lib\string\string_extensions.dart`

### Recommended Action
FIX -- split into smaller, focused files. Each file should have a single responsibility and stay within the project's 200-line limit. For example, `string_extensions.dart` could be split by category (case, search, truncation, etc.).
