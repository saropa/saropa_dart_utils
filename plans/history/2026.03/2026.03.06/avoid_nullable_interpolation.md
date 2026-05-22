# avoid_nullable_interpolation — RESOLVED

## 1 violation | Severity: warning

### Resolution
Replaced nullable `Match` group access (`m[0]`) with `m.group(0) ?? ''` in
all `escapeForRegex()` implementations so string interpolation never
produces the literal "null".

### Files Changed
- `lib/string/string_manipulation_extensions.dart` (original fix; method moved from string_extensions when split)
- `lib/string/string_regex_extensions.dart` (follow-up: same fix applied)
