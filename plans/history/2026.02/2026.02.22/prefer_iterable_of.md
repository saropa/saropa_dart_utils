# prefer_iterable_of — RESOLVED

## 5 violations | Severity: warning

### Resolution
Replaced `.from()` with compile-time type-safe alternatives:
- `json_utils.dart` (3): `List<X>.from(data)` replaced with
  `data.cast<X>().toList()` (data already validated via `.every()`).
- `list_of_list_extensions.dart` (1): `List<T>.from(innerList)` replaced
  with `List<T>.of(innerList)`.
- `unique_list_extensions.dart` (2): `LinkedHashSet<T>.from(...)` replaced
  with `LinkedHashSet<T>.of(...)`, and `List<T>.from(this)` with
  `List<T>.of(this)`.

### Files Changed
- `lib/json/json_utils.dart`
- `lib/list/list_of_list_extensions.dart`
- `lib/list/unique_list_extensions.dart`
