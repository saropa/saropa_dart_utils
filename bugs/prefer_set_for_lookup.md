# prefer_set_for_lookup

## 3 violations | Severity: info

### Rule Description
Use Set instead of List for `contains()` lookups. Sets provide O(1) average-case lookup time compared to O(n) for Lists, making them more efficient for membership testing.

### Assessment
- **False Positive**: No. Sets are more efficient for membership testing and this is a legitimate performance improvement.
- **Should Exclude**: No. This is a valid optimization recommendation.

### Affected Files
- `lib\map\map_extensions.dart`

### Recommended Action
FIX -- convert List to Set where the collection is used primarily for `contains()` checks. This provides both a performance improvement and better communicates the intent of the collection (unique membership testing).
