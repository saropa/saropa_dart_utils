# prefer_constrained_generics

## 1 violation | Severity: info

### Rule Description
Flags generic type parameters without an `extends` clause. Unconstrained generics accept any type including `void` and `Never`, which may lead to unexpected behavior. Adding a constraint narrows the accepted types and improves type safety.

### Assessment
- **False Positive**: Partially. The class `JsonIterablesUtils<T>` is designed to accept any JSON-encodable type (`num`, `String`, `bool`, `null`, `List`, `Map`). There is no single Dart type that constrains to "JSON-encodable" — `Object?` would be the closest, but still allows non-encodable types. However, `Object?` is better than fully unconstrained `T`.
- **Should Exclude**: No. Adding `extends Object?` makes the intent explicit.

### Affected Files

**`lib/json/json_utils.dart:20`**:
```dart
class JsonIterablesUtils<T> {
  /// The elements of the iterable (type [T]) must be
  /// directly encodable by `dart:convert.jsonEncode`
  /// (e.g., `num`, `String`, `bool`, `null`, `List`, or `Map`
  /// with encodable keys and values).
```

### Recommended Action
FIX — Add `extends Object?` to make the nullable-accepting intent explicit:

```dart
// Before
class JsonIterablesUtils<T> {

// After
class JsonIterablesUtils<T extends Object?> {
```

This is a no-op in terms of accepted types (unconstrained `T` already defaults to `Object?`), but it signals deliberate intent and satisfies the lint. If non-nullable values are always expected, use `extends Object` instead to exclude null at compile time.
