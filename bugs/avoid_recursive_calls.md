# avoid_recursive_calls

## 1 violation | Severity: info

### Rule Description
Recursive function call detected. Recursion can lead to stack overflow for deeply nested inputs if not properly bounded.

### Assessment
- **False Positive**: Mixed. Recursion may be intentional (e.g., GCD calculation via Euclidean algorithm) and mathematically proven to terminate. However, it should have a depth limit or be verified to always converge.
- **Should Exclude**: No, but needs case-by-case evaluation.

### Affected Files
- `lib\int\int_utils.dart`

### Recommended Action
INVESTIGATE -- check if the recursion is bounded and proven to terminate. For mathematical algorithms (like GCD), recursion is typically safe. Consider adding a depth limit parameter for safety, or convert to an iterative approach if the recursion depth could be large.

---

## Verification

- **Status:** Recursion still present; bounded and documented. `lib/int/int_utils.dart` `findGreatestCommonDenominator` uses recursion with `depth` and `maxDepth` parameters and a comment "NOTE: RECURSION". Euclidean algorithm terminates. Either add `// ignore: avoid_recursive_calls` with a one-line rationale or leave as-is and accept the lint.
