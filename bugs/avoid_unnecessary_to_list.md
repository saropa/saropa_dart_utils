# avoid_unnecessary_to_list

## 6 violations | Severity: info

### Rule Description
Flags calls to `.toList()` where the result is used in a context that accepts an `Iterable`, making the list conversion unnecessary. Converting an `Iterable` to a `List` creates an additional allocation and copy that provides no benefit when the consumer only needs to iterate.

### Assessment
- **False Positive**: No. Unnecessary `.toList()` calls waste memory and CPU cycles. If the downstream consumer accepts `Iterable`, the conversion is pure overhead.
- **Should Exclude**: No. Removing unnecessary allocations is a legitimate performance improvement.

### Affected Files
5 lib files (specific files to be identified by running the analyzer).

### Verification
Run the linter for the 6 violations; remove `.toList()` where the consumer accepts `Iterable`.

### Recommended Action
FIX -- Remove `.toList()` where the consumer accepts `Iterable`:

```dart
// Before
Iterable<String> getNames() {
  return items.map((e) => e.name).toList();
}

// After
Iterable<String> getNames() {
  return items.map((e) => e.name);
}
```

Exceptions to keep `.toList()`:
- When the return type is explicitly `List<T>` (API contract).
- When the list will be mutated (`.add()`, `.sort()`, etc.).
- When lazy evaluation would cause issues (e.g., the source collection changes between iterations).

Audit each case carefully before removing.
