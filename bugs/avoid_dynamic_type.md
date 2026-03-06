# avoid_dynamic_type

## 72 violations | Severity: info

### Rule Description
Avoid using `dynamic` type. Use explicit types or generics instead. The rule flags any use of the `dynamic` type annotation, encouraging stronger typing.

### Assessment
- **False Positive**: Mixed. JSON utilities legitimately need `dynamic` for `Map<String, dynamic>`, which is the standard Dart JSON type returned by `jsonDecode()`. Map extensions may also need `dynamic` for flexibility when wrapping JSON maps. However, some instances outside JSON handling may be avoidable with better generic typing.
- **Should Exclude**: No. The rule is generally valid, but certain files need targeted suppressions for JSON-related `dynamic` usage.

### Affected Files
- `lib\json\json_utils.dart`
- `lib\list\list_extensions.dart`
- `lib\list\list_of_list_extensions.dart`
- `lib\map\map_extensions.dart`
- `lib\map\map_nullable_extensions.dart`
- `lib\url\url_extensions.dart`

### Recommended Action
INVESTIGATE -- audit each usage of `dynamic`:
1. **JSON-related** (`Map<String, dynamic>`, `jsonDecode` results): Legitimate, suppress with `// ignore: avoid_dynamic_type` inline comments
2. **Generic methods** that could use `<T>` instead of `dynamic`: FIX by adding proper generics
3. **Map/List utilities** that operate on heterogeneous data: Evaluate case-by-case

---

## Verification

- **Status:** Not fixed. No project-level exclude; `dynamic` remains in json_utils, map_extensions, etc. for JSON and map APIs. Either add inline `// ignore: avoid_dynamic_type` at legitimate JSON/map sites or refactor to generics where possible. Run linter for current 72 locations.
