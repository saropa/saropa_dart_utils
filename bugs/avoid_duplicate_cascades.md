# avoid_duplicate_cascades

## 3 violations | Severity: warning

### Rule Description
Duplicate cascade operation detected. Likely copy-paste error.

### Assessment
- **False Positive**: Needs investigation. The violations are in UUID formatting code where repeated cascade operations may be intentional (e.g., writing repeated characters to a buffer for UUID segment separators) or may genuinely be copy-paste errors. UUID formatting involves inserting hyphens at specific positions, which could appear as duplicate operations.
- **Should Exclude**: No. The rule is generally useful. Each instance should be investigated individually.

### Affected Files
- `lib\uuid\uuid_utils.dart`

### Locations
- `lib\uuid\uuid_utils.dart:130`
- `lib\uuid\uuid_utils.dart:132`
- `lib\uuid\uuid_utils.dart:134`

### Recommended Action
INVESTIGATE -- examine each cascade at the specific lines to determine:
1. If the duplicate cascades are intentional UUID segment processing (e.g., writing hyphens between UUID segments)
2. If they are genuine copy-paste errors that produce incorrect output
3. If intentional, add inline comments explaining why and suppress with `// ignore: avoid_duplicate_cascades`
4. If copy-paste errors, fix the logic to produce the correct UUID format

Test the UUID output to verify correctness regardless of the investigation outcome.
