# avoid_string_concatenation_loop

## 2 violations | Severity: info

### Rule Description
String concatenation in a loop creates a new String object on each iteration, resulting in O(n^2) memory allocations and copies. Use StringBuffer instead for O(n) performance.

### Assessment
- **False Positive**: No. This is a legitimate performance bug. String concatenation in loops creates quadratic allocation patterns that can cause significant performance degradation for large inputs.
- **Should Exclude**: No. This should be fixed.

### Affected Files
- `lib\json\json_utils.dart`
- `lib\string\string_extensions.dart`

### Verification
No obvious string `+=` in loop in json_utils; string_extensions is a re-export. Run linter for the 2 violations and replace with StringBuffer where applicable.

### Recommended Action
FIX -- replace string concatenation in loops with StringBuffer. Use `StringBuffer` with `.write()` / `.writeln()` and call `.toString()` at the end. This changes O(n^2) allocations to O(n).
