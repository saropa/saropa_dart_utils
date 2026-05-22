# avoid_long_length_files

## 2 violations | Severity: info | RESOLVED

### Rule Description
File exceeds the long length threshold. Very long files are hard to navigate, understand, and maintain. They often indicate that a file has too many responsibilities.

### Assessment
- **False Positive**: No. Very long files are hard to navigate and violate the project's own 200-line file limit.
- **Should Exclude**: No. This aligns with the project's hard limit of files being 200 lines or fewer.

### Affected Files
- `lib\datetime\date_time_extensions.dart`
- `lib\string\string_extensions.dart`

### Resolution (2026-02-22)
Both files split into focused sub-files with re-exports for backward compatibility:
- `date_time_extensions.dart` (818 lines) → 4 files (185, 175, 164, 174 lines)
- `string_extensions.dart` (1114 lines) → 4 files (275, 195, 286, 296 lines)
All 3022 tests pass.
