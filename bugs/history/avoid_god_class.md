# avoid_god_class — RESOLVED

## 2 violations | Severity: warning

### Resolution

**DateConstants** (suppressed): Already suppressed with `// ignore: avoid_god_class` on `DateConstants`.
The class is a pure constants namespace, not a behavioral god class.

**JsonUtils** (split): Had 21 methods (threshold: 20). Split into two classes:
- `JsonUtils` — JSON parsing and validation (9 methods)
- `JsonTypeUtils` — JSON type conversion (12 methods)

### Files Changed
- `lib/datetime/date_constants.dart` (no change — already suppressed)
- `lib/json/json_utils.dart` (removed 12 type-conversion methods)
- `lib/json/json_type_utils.dart` (new — 12 type-conversion methods)
- `lib/saropa_dart_utils.dart` (added export)
- `test/json/json_utils_test.dart` (removed moved test groups)
- `test/json/json_type_utils_test.dart` (new — moved test groups)
