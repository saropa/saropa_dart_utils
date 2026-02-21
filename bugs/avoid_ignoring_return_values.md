# avoid_ignoring_return_values

## 11 violations | Severity: info

### Rule Description
Flags method calls whose return values are ignored. Ignoring return values may indicate missed error handling, logic bugs, or unnecessary computation. If a method returns a value, the caller should typically use it.

### Assessment
- **False Positive**: Partially. Some methods are called for their side effects (e.g., `List.add()` returns void but `List.remove()` returns a bool indicating success). However, most flagged cases in a utility library are likely genuine issues where a computed result is being discarded.
- **Should Exclude**: No. The rule helps catch real bugs, especially in a utility library where methods are predominantly pure functions returning values.

### Affected Files
6 lib files (specific files to be identified by running the analyzer).

### Recommended Action
FIX -- Audit each of the 11 violations individually:

1. If the return value represents an error state or important result, capture and use it.
2. If the method is called purely for side effects and the return value is intentionally unused, assign to `_` to signal intent: `_ = someMethod();`
3. Consider adding `@useResult` annotations to the methods being called, if they are defined in this library, to prevent future occurrences.
