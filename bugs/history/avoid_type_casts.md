# avoid_type_casts — RESOLVED

## 7 violations | Severity: warning

### Resolution
Replaced all `as` casts with `is` type checks or type promotion patterns:
- `map_extensions.dart` (5): Replaced `as String?` and `as Map?` casts with
  `is` checks that return `null` for non-matching types instead of throwing.
- `json_utils.dart` (1): `json as int?` replaced with `json is int ? json : null`.
- `make_list_extensions.dart` (1): Used local variable type promotion instead
  of `this as T`.

### Files Changed
- `lib/map/map_extensions.dart`
- `lib/json/json_utils.dart`
- `lib/list/make_list_extensions.dart`
