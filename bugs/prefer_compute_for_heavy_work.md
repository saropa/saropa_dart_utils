# prefer_compute_for_heavy_work

## 14 violations | Severity: info

### Rule Description
Heavy computation should use Flutter's `compute()` for isolate-based processing. The rule suggests offloading expensive operations to a background isolate using Flutter's `compute()` function.

### Assessment
- **False Positive**: Yes. This is a pure Dart utility library, not a Flutter app. `compute()` is a Flutter-specific API (`package:flutter/foundation.dart`) and is not available in pure Dart packages. The library provides synchronous utility functions that are designed to be called by consuming applications, which can themselves decide whether to run operations in isolates.
- **Should Exclude**: Yes. The rule is fundamentally inapplicable to a pure Dart library.

### Affected Files
- `lib\base64\base64_utils.dart`
- `lib\json\json_utils.dart`

### Recommended Action
EXCLUDE -- add `prefer_compute_for_heavy_work: false` to `analysis_options_custom.yaml`. This library is a pure Dart package and cannot depend on Flutter's `compute()`. Consumers of the library can use `Isolate.run()` (Dart 2.19+) or Flutter's `compute()` in their own code if they need to offload these operations.
