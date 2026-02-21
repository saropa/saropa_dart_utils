# require_exception_documentation

## 2 violations | Severity: info

### Rule Description
Methods that throw exceptions should document which exceptions can be thrown and under what conditions. This helps callers handle errors appropriately.

### Assessment
- **False Positive**: No. Documenting thrown exceptions is important for consumers to write proper error handling code.
- **Should Exclude**: No. This is a legitimate documentation requirement.

### Affected Files
- `lib\datetime\date_time_utils.dart`
- `lib\enum\enum_iterable_extensions.dart`

### Recommended Action
FIX -- add `@throws` or `/// Throws [ExceptionType]` documentation to methods that throw exceptions. Document the specific exception type and the conditions under which it is thrown.
