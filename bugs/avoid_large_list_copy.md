# avoid_large_list_copy

## 19 violations | Severity: info

### Rule Description
Large list copy operation detected. The rule flags operations that create full copies of lists (e.g., `List.from()`, `toList()`, spread operator on large collections), which can be expensive for large inputs.

### Assessment
- **False Positive**: No. This is a legitimate performance concern. Creating copies of potentially large lists can be expensive in memory and CPU. In a utility library, callers may pass very large collections, and unnecessary copies degrade performance.
- **Should Exclude**: No. The rule highlights real optimization opportunities.

### Affected Files
8 lib files.

### Verification
Run the linter for the 19 violations; audit each `.toList()`/`List.from()`/spread for necessity or replace with lazy Iterable.

### Recommended Action
FIX -- audit each list copy operation for necessity:
1. **Return type is `List`**: If callers expect a `List`, a copy may be necessary for safety (avoiding mutation of the original). Consider returning `Iterable` instead where possible.
2. **Intermediate copies**: If a list is copied only to iterate over it, replace with lazy `Iterable` operations (`.map()`, `.where()`, `.expand()`).
3. **Defensive copies**: If a copy is made to prevent mutation, document why. Consider using `List.unmodifiable()` instead.
4. **Sort/shuffle operations**: These require a mutable copy; ensure the copy is necessary and documented.
