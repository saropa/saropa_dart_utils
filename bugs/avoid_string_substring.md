# avoid_string_substring

## 9 violations | Severity: warning

### Rule Description
`substring()` throws `RangeError` if indices are out of bounds. Check string length before calling.

### Assessment
- **False Positive**: Mixed. Some usages may already have proper bounds checks in place before the `substring()` call. However, the concern about potential runtime `RangeError` crashes is valid and each usage should be audited individually.
- **Should Exclude**: No. This rule catches a real class of runtime errors. Each usage should be verified to have proper bounds checking.

### Affected Files
- `lib\json\json_utils.dart`
- `lib\string\string_extensions.dart`
- `lib\url\url_extensions.dart`
- `lib\uuid\uuid_utils.dart`

### Locations
9 violations across 4 files. Each location is a call to `.substring()` that the analyzer cannot verify is bounds-safe.

### Recommended Action
FIX -- audit each `substring()` usage individually:
1. Verify that the index arguments are guaranteed to be within `[0, string.length]`
2. Where bounds checks are missing, add length validation before the `substring()` call
3. Where bounds checks already exist upstream, consider adding an inline suppression comment with an explanation
4. Consider replacing with safer alternatives where applicable (e.g., extension methods that handle bounds gracefully)
