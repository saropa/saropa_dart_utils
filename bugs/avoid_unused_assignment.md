# avoid_unused_assignment

## 16 violations | Severity: info

### Rule Description
Variable is assigned but never read after assignment. The rule detects cases where a variable is assigned a value that is never subsequently used, indicating dead code or a logic error.

### Assessment
- **False Positive**: No. This is a legitimate bug indicator. Unused assignments suggest one of:
  1. Dead code that should be removed
  2. A logic error where the computed value was intended to be used
  3. Incomplete refactoring where the usage was removed but the assignment was not
- **Should Exclude**: No. This rule catches real bugs and dead code.

### Affected Files
- `lib\html\html_utils.dart`
- `lib\json\json_utils.dart`
- `lib\string\string_between_extensions.dart`
- `lib\string\string_extensions.dart`

### Recommended Action
FIX -- audit each unused assignment:
1. **Dead code**: Remove the assignment entirely if the value is never needed.
2. **Logic error**: If the value was meant to be used (e.g., returned or passed to another function), fix the logic.
3. **Side effects**: If the right-hand side has side effects, keep the call but discard the value with `_` (Dart 3.0+) or document the intent.
4. Priority: HIGH -- unused assignments often indicate real bugs that affect correctness.
