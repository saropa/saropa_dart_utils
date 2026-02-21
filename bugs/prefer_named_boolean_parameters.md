# prefer_named_boolean_parameters

## 5 violations | Severity: info

### Rule Description
Flags boolean parameters that are positional rather than named. At call sites, positional booleans are opaque -- `doSomething(true)` gives no indication of what `true` means, while `doSomething(inclusive: true)` is self-documenting.

### Assessment
- **False Positive**: No. Named boolean parameters are universally considered better API design. The Effective Dart guidelines recommend avoiding positional booleans.
- **Should Exclude**: No. This rule improves API usability for library consumers.

### Affected Files
- `lib\bool\bool_iterable_extensions.dart`

### Recommended Action
FIX -- Convert positional boolean parameters to named parameters. **This is an API-breaking change** that requires careful evaluation.

```dart
// Before (unclear at call site)
int countTrue(bool includeNull) { ... }
// Usage: countTrue(true) -- what does true mean?

// After (self-documenting)
int countTrue({bool includeNull = false}) { ... }
// Usage: countTrue(includeNull: true) -- clear intent
```

Migration steps:
1. Identify all 5 positional boolean parameters in `bool_iterable_extensions.dart`.
2. Convert each to a named parameter with a sensible default value.
3. Update all call sites in the library's own tests.
4. Document the breaking change in `CHANGELOG.md`.
5. Consider whether this warrants a major version bump per semver (if any downstream consumers exist).

**Impact assessment**: Since this is a published library, this change breaks the public API. Bundle with the next major version release, or deprecate the old signature first:
```dart
@Deprecated('Use named parameter instead: countTrue(includeNull: true)')
int countTrueOld(bool includeNull) => countTrue(includeNull: includeNull);
```
