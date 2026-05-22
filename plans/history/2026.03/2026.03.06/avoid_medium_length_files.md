# avoid_medium_length_files

## 5 violations | Severity: info

### Rule Description
Flags files that exceed a medium length threshold (typically 150-200 lines). Long files are harder to navigate, understand, and maintain. The rule encourages splitting large files into smaller, focused modules.

### Assessment
- **False Positive**: No. The project enforces a hard limit of 200 lines per file. Files exceeding the medium-length threshold are approaching or have exceeded this limit and should be evaluated for splitting.
- **Should Exclude**: No. This rule directly supports the project's "files <= 200 lines" hard limit.

### Affected Files
5 lib files (specific files to be identified by running the analyzer -- likely the largest extension files such as `string_extensions.dart`, `date_time_extensions.dart`, etc.).

### Recommended Action
INVESTIGATE -- For each flagged file:

1. **Check line count**: Determine how far over the threshold each file is.
2. **Identify split points**: Look for logical groupings of methods that could be separated into their own files.
3. **Split strategically**: Create new extension files organized by functionality. For example:
   ```
   // Before: one large file
   lib/string/string_extensions.dart (250 lines)

   // After: split by concern
   lib/string/string_extensions.dart (core methods)
   lib/string/string_search_extensions.dart (search-related methods)
   lib/string/string_case_extensions.dart (case conversion methods)
   ```
4. **Update barrel exports**: Ensure the library's public API remains unchanged after splitting.
5. **Update indexes**: Update `CODEBASE_INDEX.md` and `CODE_INDEX.md` to reflect the new file structure.

Note: Some files may already be close to the limit and not worth splitting if the methods are tightly coupled.
