# prefer_typedefs_for_callbacks

## 3 violations | Severity: info

### Rule Description
Flags inline function types used as parameters. The rule suggests extracting them to named `typedef` declarations for improved readability and reusability.

### Assessment
- **False Positive**: No. The inline function types are correct, but named typedefs improve API documentation and IDE hover information.
- **Should Exclude**: No. These are simple improvements, though the impact is modest for single-use callbacks.

### Affected Files

**`lib/iterable/iterable_extensions.dart:95`** — Predicate callback:
```dart
int countWhere(bool Function(T) predicate) {
```

Standard predicate pattern. A typedef would align with Dart SDK conventions (`Predicate<T>` is not in the SDK, but `bool Function(T)` is very common).

**`lib/list/unique_list_extensions.dart:15`** — Key extractor callback:
```dart
List<T> toUniqueBy<E>(E Function(T) keyExtractor, {bool ignoreNullKeys = true}) {
```

**`lib/list/unique_list_extensions.dart:50`** — Same key extractor pattern:
```dart
void toUniqueByInPlace<E>(E Function(T) keyExtractor, {bool ignoreNullKeys = true}) {
```

These two share the exact same function signature, making a typedef especially valuable to keep them in sync.

### Recommended Action
FIX — Extract typedefs for the shared signatures:

```dart
// In iterable_extensions.dart or a shared types file:
/// A function that tests an element against a condition.
typedef ElementPredicate<T> = bool Function(T element);

// In unique_list_extensions.dart or a shared types file:
/// A function that extracts a key from an element for uniqueness comparison.
typedef KeyExtractor<T, E> = E Function(T element);
```

Then update the method signatures:
```dart
// iterable_extensions.dart
int countWhere(ElementPredicate<T> predicate) { ... }

// unique_list_extensions.dart
List<T> toUniqueBy<E>(KeyExtractor<T, E> keyExtractor, {bool ignoreNullKeys = true}) { ... }
void toUniqueByInPlace<E>(KeyExtractor<T, E> keyExtractor, {bool ignoreNullKeys = true}) { ... }
```

Note: Since `bool Function(T)` is an extremely common Dart pattern, suppressing this rule for simple single-parameter predicates is also reasonable.
