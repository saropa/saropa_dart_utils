# avoid_wildcard_cases_with_sealed_classes — RESOLVED

## 1 violation | Severity: warning

### Resolution
In `int_string_extensions.dart`, changed `final num onesPlace` to
`final int onesPlace`. Since `int % int` always returns `int`, the `num`
type was unnecessarily broad. `num` is sealed in Dart 3, so a wildcard
case on it defeated exhaustiveness checking.

### Files Changed
- `lib/int/int_string_extensions.dart`
