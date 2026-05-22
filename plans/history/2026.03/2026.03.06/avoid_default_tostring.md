# avoid_default_tostring

## 1 violation | Severity: info

### Rule Description
Class uses the default `toString()` inherited from Object, which returns `Instance of 'ClassName'` -- not informative for debugging or logging. Custom `toString()` implementations should provide meaningful output.

### Assessment
- **False Positive**: No. Custom `toString()` aids debugging and logging by showing the object's meaningful state.
- **Should Exclude**: No. This is a legitimate code quality improvement.

### Affected Files
- `lib\gesture\swipe_properties.dart`

### Recommended Action
FIX -- add a meaningful `toString()` override that includes the class's key fields. For example: `@override String toString() => 'SwipeProperties(direction: $direction, velocity: $velocity)';`
