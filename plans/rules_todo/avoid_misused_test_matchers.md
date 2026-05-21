# avoid_misused_test_matchers

## 373 violations | Severity: warning

### Rule Description
Raw literal used as test matcher instead of proper matcher function. Using `expect(x, true)` instead of `expect(x, isTrue)`.

### Assessment
- **False Positive**: No. These are legitimate style issues. Using raw literals like `true`, `false`, or `null` as matchers in `expect()` calls works correctly at runtime, but produces less descriptive failure messages. Proper matchers like `isTrue`, `isFalse`, and `isNull` provide clearer output when tests fail.
- **Should Exclude**: No. Better test matchers improve debugging when tests fail. However, this is low priority since the tests function correctly as-is.

### Affected Files
19 test files across all categories, including but not limited to:
- `test\bool\bool_iterable_extensions_test.dart`
- `test\bool\bool_string_extensions_test.dart`
- `test\datetime\date_constant_extensions_test.dart`
- `test\datetime\date_time_extensions_test.dart`
- `test\datetime\date_time_utils_test.dart`
- `test\double\double_iterable_extensions_test.dart`
- `test\int\int_extensions_test.dart`
- `test\list\list_extensions_test.dart`
- `test\string\string_extensions_test.dart`
- And 10 additional test files

### Locations
373 violations spread across 19 test files. Each is an `expect()` call using a raw literal matcher.

### Recommended Action
FIX incrementally -- this is a large but mechanical change that can be done file by file:
- Replace `expect(x, true)` with `expect(x, isTrue)`
- Replace `expect(x, false)` with `expect(x, isFalse)`
- Replace `expect(x, null)` with `expect(x, isNull)`
- Replace `expect(x, 0)` with `expect(x, isZero)` where applicable

Given the volume (373 occurrences), tackle this as a background improvement over multiple commits rather than a single large change.

---

## Current status (verification)

- **Status:** Not implemented. Raw literal matchers still present in tests.
- **Verified locations (sample):** `test/datetime/date_time_utils_test.dart`, `test/parsing/parsing_test.dart`, `test/num/num_utils_test.dart`, `test/datetime/date_time_clamp_list_overlap_test.dart`, `test/datetime/date_time_relative_fiscal_week_test.dart`, `test/string/string_wildcard_extensions_test.dart` (11), and others.
- **Quick fix pattern:** Run find-and-replace per file: `expect(\([^,]+),\s*true\)` → `expect($1, isTrue)`; similarly `false` → `isFalse`, `null` → `isNull`. Ensure `package:flutter_test/flutter_test.dart` is imported (provides `isTrue`, `isFalse`, `isNull`).
- **Priority:** Low — tests pass; improvement is for clearer failure messages when assertions fail.
