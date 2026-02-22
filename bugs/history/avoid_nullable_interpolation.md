# avoid_nullable_interpolation — RESOLVED

## 1 violation | Severity: warning

### Resolution
In `string_extensions.dart` `escapeForRegex()`, replaced `m[0]` (nullable
`Match` group access) with `m.group(0) ?? ''` to avoid interpolating a
nullable value.

### Files Changed
- `lib/string/string_extensions.dart`
