# prefer_digit_separators

## 1 violation | Severity: info

### Rule Description
Large number literals should use digit separators (underscores) for readability. For example, `1000000` should be written as `1_000_000`.

### Assessment
- **False Positive**: No. Digit separators significantly improve readability of large numbers and are a Dart language feature specifically designed for this purpose.
- **Should Exclude**: No. This is a trivial fix.

### Affected Files
- `lib\string\string_extensions.dart`

### Recommended Action
FIX -- add digit separators to large number literals. Use underscores to group digits (typically by thousands for decimal numbers, or by bytes/nibbles for hex numbers).
