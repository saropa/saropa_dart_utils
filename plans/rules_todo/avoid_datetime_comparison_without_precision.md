# avoid_datetime_comparison_without_precision

## 1 violation | Severity: info

### Rule Description
DateTime comparison without specifying precision can lead to unexpected results. Comparing DateTime objects at full precision (microseconds) when only day-level or minute-level precision is needed can cause logical errors.

### Assessment
- **False Positive**: No. DateTime comparisons should specify the intended precision (day, hour, minute, etc.) to avoid subtle bugs caused by microsecond differences.
- **Should Exclude**: No. This is a legitimate correctness concern.

### Affected Files
- `lib\datetime\date_constant_extensions.dart`

### Recommended Action
FIX -- add precision to DateTime comparison. Ensure comparisons use the appropriate level of precision (e.g., compare only dates if time is irrelevant, or truncate to minutes/seconds as appropriate).
