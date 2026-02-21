# no_magic_number

## 26 violations | Severity: info

### Rule Description
Magic number literal used. Extract to named constant. The rule flags numeric literals that appear in code without being assigned to a descriptively named constant.

### Assessment
- **False Positive**: Mixed. Some magic numbers are universally understood domain constants:
  - `7` (days in a week)
  - `12` (months in a year)
  - `24` (hours in a day)
  - `60` (minutes/seconds)
  - `365` (days in a year)
  - `100` (percentage base)
  These are arguably clearer inline than as named constants. Other numbers may genuinely benefit from extraction.
- **Should Exclude**: No. The rule is generally valid, but well-known constants should be evaluated individually.

### Affected Files
- `lib\datetime\date_time_extensions.dart`
- `lib\double\double_extensions.dart`
- `lib\int\int_string_extensions.dart`
- `lib\json\json_utils.dart`
- `lib\string\string_extensions.dart`

### Recommended Action
INVESTIGATE -- evaluate each magic number:
1. **Well-known constants** (7, 12, 24, 60, 365, 100): Can stay inline or use Dart's built-in `Duration` constants where applicable. Suppress with inline `// ignore: no_magic_number` if needed.
2. **Domain-specific numbers** (buffer sizes, thresholds, limits): Extract to named constants with descriptive names.
3. **Mathematical constants**: Use `dart:math` constants where available.
