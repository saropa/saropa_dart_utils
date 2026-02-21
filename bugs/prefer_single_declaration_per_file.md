# prefer_single_declaration_per_file

## 3 violations | Severity: info

### Rule Description
Each file should contain only one public class, extension, or top-level declaration. Multiple declarations per file can make code harder to find and navigate.

### Assessment
- **False Positive**: Mixed. Related classes in the same file can be appropriate (e.g., related enums with their utility class, or a class with its closely-coupled helper). Splitting tightly coupled declarations may harm cohesion.
- **Should Exclude**: No. The rule is generally good practice but needs case-by-case evaluation.

### Affected Files
- `lib\datetime\date_constants.dart`
- `lib\gesture\swipe_properties.dart`
- `lib\json\json_utils.dart`

### Recommended Action
INVESTIGATE -- split where classes are truly independent and unrelated. Keep tightly coupled declarations together if they form a cohesive unit (e.g., an enum and its extension methods).
