# prefer_iterable_of

## 5 violations | Severity: warning

### Rule Description
Using `.from()` performs a runtime cast. Use `.of()` for compile-time type safety.

### Assessment
- **False Positive**: No. This is a legitimate improvement. `List.from()` and `Map.from()` perform runtime type casting, which can silently succeed with unexpected types and fail later. `List.of()` and `Map.of()` enforce type safety at compile time, catching type errors earlier.
- **Should Exclude**: No. This rule promotes better type safety which aligns with the project's emphasis on null-safety and correctness.

### Affected Files
- `lib\json\json_utils.dart`
- `lib\list\list_of_list_extensions.dart`
- `lib\list\unique_list_extensions.dart`

### Locations
5 violations across 3 files. Each is a call to `List.from()` or `Map.from()` that should use `.of()` instead.

### Recommended Action
FIX -- replace each occurrence:
- `List.from(iterable)` with `List.of(iterable)`
- `Map.from(map)` with `Map.of(map)`
- `Set.from(iterable)` with `Set.of(iterable)` (if applicable)

This is a small, safe, mechanical change. Verify that the source types are already correctly typed (since `.of()` will not perform implicit casting).
