# avoid_duplicate_number_elements

## 9 violations | Severity: warning

### Rule Description
Duplicate numeric element in collection literal typically indicates a copy-paste error.

### Assessment
- **False Positive**: Yes. The flagged code is a days-in-month array: `[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]`. Duplicate values like 31 and 30 are intentional and correct -- calendar months genuinely have repeated day counts (e.g., January, March, May, July, August, October, December all have 31 days).
- **Should Exclude**: No. The rule is generally useful for catching copy-paste errors in other contexts. Inline suppression is more appropriate than a global exclusion.

### Affected Files
- `lib\datetime\date_time_utils.dart`

### Locations
- `lib\datetime\date_time_utils.dart:293` (multiple columns flagged for the repeated 31 and 30 values)

### Recommended Action
SUPPRESS -- add `// ignore: avoid_duplicate_number_elements` inline comment above the days-in-month array. This is a well-known constant where duplicate numeric values are correct by definition. Consider also adding a comment explaining the array represents days per month (Jan-Dec) for clarity.
