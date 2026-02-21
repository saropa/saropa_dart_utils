# prefer_match_file_name

## 13 violations | Severity: info

### Rule Description
Checks that the primary class, extension, or type declared in a file matches the file name. For example, `date_time_utils.dart` should contain a class named `DateTimeUtils`.

### Assessment
- **False Positive**: Mixed. Files like `date_time_utils.dart` contain class `DateTimeUtils` which does match when converting snake_case to PascalCase. However, extension files like `map_extensions.dart` may contain extensions on `Map` where the linter cannot determine the "correct" name, or where the extension name follows a different convention (e.g., `MapExtensions` vs `SaropaMapExtensions`).
- **Should Exclude**: No, not globally. The rule is useful for catching genuinely misnamed files. Individual false positives should be investigated and suppressed case-by-case.

### Affected Files
13 lib files (utility classes and extension files). Specific files need investigation to determine which are true mismatches vs linter limitations with extension naming conventions.

### Recommended Action
INVESTIGATE -- Run the analyzer and review each of the 13 violations individually. For files where the primary declaration genuinely matches the file name (after snake_case to PascalCase conversion), suppress with an inline comment. For actual mismatches, rename the declaration or the file to align. Extension files that follow the project convention (`{type}_extensions.dart` containing `{Type}Extensions`) may need per-file suppression if the linter does not recognize extension names.
