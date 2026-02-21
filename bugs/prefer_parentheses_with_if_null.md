# prefer_parentheses_with_if_null

## 4 violations | Severity: info

### Rule Description
Add parentheses around if-null (`??`) expressions for clarity, especially when combined with other operators. Parentheses make the precedence explicit and improve readability.

### Assessment
- **False Positive**: No. Parentheses improve readability of `??` in complex expressions by making operator precedence explicit.
- **Should Exclude**: No. This is a legitimate readability improvement.

### Affected Files
- `lib\string\string_between_extensions.dart`

### Recommended Action
FIX -- add parentheses around if-null expressions. This is a straightforward readability improvement that makes the code's intent clearer.
