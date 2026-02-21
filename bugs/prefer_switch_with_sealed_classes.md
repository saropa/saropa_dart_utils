# prefer_switch_with_sealed_classes

## 1 violation | Severity: info

### Rule Description
Use switch expression with sealed class pattern matching. Sealed classes with switch expressions provide exhaustiveness checking, ensuring all cases are handled at compile time.

### Assessment
- **False Positive**: Mixed. This depends on whether the type hierarchy is actually sealed or could be made sealed. If the types being switched on are not sealed classes, this rule may not be applicable.
- **Should Exclude**: No, but needs investigation.

### Affected Files
- `lib\map\map_extensions.dart`

### Recommended Action
INVESTIGATE -- determine if the type hierarchy being switched on is sealed or can be made sealed. If so, convert to a switch expression with pattern matching for compile-time exhaustiveness. If the types cannot be sealed (e.g., third-party types), this rule may not be actionable.
