# avoid_unnecessary_nullable_return_type

## 29 violations | Severity: info

### Rule Description
Return type is nullable but the method never returns null. The linter detects methods declared with a nullable return type (e.g., `String?`) that provably always return a non-null value on all code paths.

### Assessment
- **False Positive**: No. This is a legitimate bug. If a method declares `String?` but always returns a non-null `String`, the return type should be tightened to `String`. Unnecessarily nullable return types force callers to handle null when it can never occur, adding noise and potential for bugs.
- **Should Exclude**: No. Fixing these violations improves API ergonomics and type safety.

### Affected Files
14 lib files.

### Recommended Action
FIX -- audit return types and remove unnecessary nullability where the method provably never returns null. Considerations:
1. **Public API impact**: Tightening a return type from `String?` to `String` is a non-breaking change (callers expecting nullable can still accept non-nullable).
2. **Verify thoroughly**: Ensure no code path can return null, including implicit returns.
3. **Be conservative**: If there is any doubt about future null returns, keep the nullable type.
4. **Update tests**: Tests checking for null returns on these methods should be reviewed.
