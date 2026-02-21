# prefer_addition_subtraction_assignments

## 1 violation | Severity: info

### Rule Description
Use compound assignment operators (`+=`, `-=`) instead of explicit `x = x + 1` or `x = x - 1`. Compound assignments are more concise and idiomatic.

### Assessment
- **False Positive**: No. Compound assignment operators are universally preferred in Dart for their conciseness.
- **Should Exclude**: No. This is a trivial fix.

### Affected Files
- `lib\datetime\date_time_utils.dart`

### Recommended Action
FIX -- use compound assignment operators. Change `x = x + value` to `x += value` and `x = x - value` to `x -= value`.
