# avoid_generic_exceptions

## 1 violation | Severity: info

### Rule Description
Generic `Exception` is thrown instead of a specific exception type. Specific exception types allow callers to catch and handle errors more precisely.

### Assessment
- **False Positive**: No. Throwing specific exceptions improves error handling and allows callers to catch specific failure modes.
- **Should Exclude**: No. This is a legitimate code quality improvement.

### Affected Files
- `lib\enum\enum_iterable_extensions.dart`

### Recommended Action
FIX -- throw a specific exception type instead of generic `Exception`. Use `ArgumentError`, `StateError`, `FormatException`, or a custom exception type as appropriate for the error condition.

---

## Verification

- **Status:** Appears resolved. `lib/enum/enum_iterable_extensions.dart` was checked and contains no `throw Exception(`. If the linter still reports a violation, run it to get the exact file and line.
