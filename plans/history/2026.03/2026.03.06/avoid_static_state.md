# avoid_static_state

## 34 violations | Severity: warning

### Rule Description
Static mutable state persists across hot-reloads and tests. Replace static mutable fields with scoped state management.

### Assessment
- **False Positive**: Yes. This is a pure Dart utility library with no Flutter widgets, no UI, and no state management. The "static mutable state" flagged here consists of cached RegExp patterns and lookup tables (e.g., `static final _emailRegex = RegExp(...)`) which are intentionally static for performance. These are effectively immutable constants initialized once. The rule assumes a Flutter app context where hot-reload behavior matters, which does not apply here.
- **Should Exclude**: Yes. The rule is designed for Flutter apps with widget state. In a pure Dart utility library, static final fields for compiled RegExp patterns and constant lookup tables are the correct and idiomatic pattern. Add `avoid_static_state: false` to `analysis_options_custom.yaml`.

### Affected Files
- `lib\datetime\date_constants.dart`
- `lib\datetime\date_time_utils.dart`
- `lib\datetime\time_emoji_utils.dart`
- `lib\gesture\swipe_properties.dart`
- `lib\hex\hex_utils.dart`
- `lib\string\string_diacritics_extensions.dart`
- `lib\string\string_extensions.dart`

### Locations
34 violations spread across the 7 files listed above. Primary patterns include:
- Cached `RegExp` instances (`static final _regex = RegExp(...)`)
- Constant lookup maps and tables
- Configuration constants

### Recommended Action
EXCLUDE -- add `avoid_static_state: false` to `analysis_options_custom.yaml`. These static fields are the correct design pattern for a utility library where compiled regex patterns and lookup tables should be allocated once and shared across all callers.
