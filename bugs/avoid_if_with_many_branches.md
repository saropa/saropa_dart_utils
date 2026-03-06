# avoid_if_with_many_branches

## 1 violation | Severity: info

### Rule Description
An if statement has too many branches (else-if chains), which makes the code harder to read and maintain. Consider using a switch statement or switch expression instead.

### Assessment
- **False Positive**: No. Long if-else chains are harder to read than switch statements and may miss exhaustiveness checks.
- **Should Exclude**: No. This is a legitimate code quality improvement.

### Affected Files
- `lib\gesture\swipe_properties.dart`

### Recommended Action
FIX -- convert the multi-branch if-else chain to a switch statement or switch expression. This improves readability and enables the compiler to check for exhaustiveness.

---

## Verification

- **Status:** Not fixed. `lib/gesture/swipe_properties.dart` getter `swipeMagnitude` (lines ~153–172) still uses four consecutive `if (magnitude < ...)` checks and a final return. Convert to a switch on a discretized value or keep if chain and add `// ignore: avoid_if_with_many_branches` with a short comment if intentional.
