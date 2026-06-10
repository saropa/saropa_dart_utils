# prefer_simpler_boolean_expressions

## 1 violation | Severity: info

### Rule Description
Boolean expression can be simplified. Overly complex boolean expressions (e.g., double negation, redundant comparisons) should be reduced to their simplest form.

### Assessment
- **False Positive**: No. Simpler boolean expressions are easier to read and understand.
- **Should Exclude**: No. This is a trivial fix.

### Affected Files
- `lib\html\html_utils.dart`

### Recommended Action
FIX -- simplify the boolean expression. Common simplifications include: removing double negation (`!!x` to `x`), replacing `x == true` with `x`, replacing `x == false` with `!x`, and applying De Morgan's laws to flatten nested negations.
