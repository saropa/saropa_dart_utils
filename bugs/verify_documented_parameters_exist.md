# verify_documented_parameters_exist

## 31 violations | Severity: warning

### Rule Description
Documentation references a parameter that does not exist in the signature. Remove the stale parameter reference.

### Assessment
- **False Positive**: No. These are legitimate bugs where dartdoc comments reference parameters that were renamed or removed during refactoring but the documentation was not updated to match.
- **Should Exclude**: No. This rule catches real documentation drift that misleads developers reading the API docs.

### Affected Files
- `lib\base64\base64_utils.dart`
- `lib\datetime\date_time_extensions.dart`
- `lib\datetime\date_time_range_utils.dart`
- `lib\datetime\time_emoji_utils.dart`
- `lib\hex\hex_utils.dart`
- `lib\html\html_utils.dart`
- `lib\int\int_string_extensions.dart`
- `lib\map\map_extensions.dart`
- `lib\string\string_between_extensions.dart`
- `lib\string\string_case_extensions.dart`
- `lib\string\string_character_extensions.dart`
- `lib\string\string_diacritics_extensions.dart`
- `lib\string\string_extensions.dart`
- `lib\string\string_punctuation.dart`

### Locations
31 violations across 14 files. Each violation is a `@param` or `[paramName]` reference in a dartdoc comment that does not match any parameter in the current method signature.

### Recommended Action
FIX -- audit each dartdoc comment and update parameter references to match current method signatures. For each violation:
1. Check what the parameter was renamed to
2. Update the dartdoc to use the current parameter name
3. Remove references to parameters that no longer exist
