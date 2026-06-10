# avoid_duplicate_string_literals_pair

## 6 violations | Severity: info

### Rule Description
Flags string literals that appear identically in multiple places within the same file or across files. Duplicated string literals are a maintenance risk -- if the value needs to change, every occurrence must be updated, and missing one introduces bugs.

### Assessment
- **False Positive**: Mixed. Some duplicated strings are legitimate:
  - Empty string `''` is intentionally repeated and should not be extracted.
  - Format patterns used in date/time formatting may be intentionally inline.
  - Error messages that happen to be similar may have different contexts.

  However, strings like format specifiers, default values, or configuration keys that appear multiple times should be extracted to constants.
- **Should Exclude**: No. The rule is useful for catching maintenance risks, but each case needs individual judgment.

### Affected Files
5 lib files (specific files to be identified by running the analyzer).

### Verification
Run the linter to get exact file:line for the 6 violations; then extract to constants or suppress per case.

### Recommended Action
INVESTIGATE -- Review each of the 6 violations:

1. **Extract to constants**: Strings that represent domain concepts, format patterns, or configuration values appearing 3+ times.
   ```dart
   // Before
   return date.format('yyyy-MM-dd');
   // ... elsewhere ...
   return other.format('yyyy-MM-dd');

   // After
   static const _isoDateFormat = 'yyyy-MM-dd';
   return date.format(_isoDateFormat);
   ```

2. **Leave inline**: Empty strings, single-character strings, or strings that are coincidentally identical but semantically different.

3. **Suppress**: Cases where extraction would reduce readability (e.g., extracting `'/'` to a constant named `_forwardSlash` adds no value).
