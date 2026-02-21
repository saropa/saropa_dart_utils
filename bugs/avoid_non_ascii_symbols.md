# avoid_non_ascii_symbols

## 413 violations | Severity: info

### Rule Description
String contains non-ASCII characters which can cause encoding issues.

### Assessment
- **False Positive**: Yes. This library deliberately handles Unicode characters, emojis, and diacritics as part of its core functionality. The flagged files contain:
  - `time_emoji_utils.dart` -- emoji clock faces (e.g., clock emojis for each hour)
  - `string_diacritics_extensions.dart` -- diacritical mark mapping tables for accent removal
  - `html_utils.dart` -- HTML entity to character mappings
  - `string_extensions.dart` -- Unicode-aware string processing
  - `double_extensions.dart` -- special numeric symbols
  These non-ASCII characters are the entire purpose of these utilities.
- **Should Exclude**: Yes. A utility library that provides Unicode, emoji, and diacritics processing must contain non-ASCII characters by definition. The rule is designed for application code where non-ASCII characters in source might indicate encoding issues. Add `avoid_non_ascii_symbols: false` to `analysis_options_custom.yaml`.

### Affected Files
- `lib\datetime\time_emoji_utils.dart`
- `lib\double\double_extensions.dart`
- `lib\html\html_utils.dart`
- `lib\string\string_diacritics_extensions.dart`
- `lib\string\string_extensions.dart`

### Locations
413 violations across 5 files. The vast majority are in `string_diacritics_extensions.dart` and `html_utils.dart` which contain large mapping tables.

### Recommended Action
EXCLUDE -- add `avoid_non_ascii_symbols: false` to `analysis_options_custom.yaml`. This library's purpose includes Unicode and emoji handling, making non-ASCII source characters a requirement, not a defect.
