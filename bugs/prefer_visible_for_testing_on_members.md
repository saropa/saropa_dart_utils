# prefer_visible_for_testing_on_members

## 1 violation | Severity: info

### Rule Description
Internal members that are exposed only for testing purposes should be annotated with `@visibleForTesting`. This annotation documents the intent and triggers a warning if the member is used outside of test code.

### Assessment
- **False Positive**: No. The `@visibleForTesting` annotation helps document the intended API surface and prevents accidental use of testing-only members in production code.
- **Should Exclude**: No. This is a legitimate code quality improvement.

### Affected Files
- `lib\int\int_utils.dart`

### Recommended Action
FIX -- add `@visibleForTesting` annotation to members that are public only for testing purposes. Import `package:meta/meta.dart` (or `package:flutter/foundation.dart` in Flutter) to access the annotation.
