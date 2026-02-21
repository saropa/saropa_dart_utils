# require_https_only_test

## 9 violations | Severity: info

### Rule Description
Flags HTTP URLs (non-HTTPS) found in test files. The rule encourages using HTTPS URLs in tests to promote secure URL practices and avoid accidentally deploying insecure URLs.

### Assessment
- **False Positive**: Yes. The `url_extensions_test.dart` file deliberately tests both HTTP and HTTPS URLs to ensure the URL utility methods handle both protocols correctly. A URL utility library must validate behavior for all URL schemes, including plain HTTP. Restricting tests to HTTPS-only would leave HTTP handling untested.
- **Should Exclude**: Yes. This rule should be excluded for this project because testing HTTP URL handling is a core requirement of the URL utilities.

### Affected Files
- `test\url\url_extensions_test.dart`

### Recommended Action
EXCLUDE -- Add the following to `analysis_options_custom.yaml`:

```yaml
custom_lint:
  rules:
    - require_https_only_test: false
```

Alternatively, if the rule supports file-level exclusion, exclude only `test/url/` rather than disabling globally. The URL extension tests are specifically designed to verify behavior with HTTP URLs and this is not a security concern in a test context.
