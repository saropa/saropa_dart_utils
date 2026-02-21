# avoid_barrel_files

## 1 violation | Severity: info

### Rule Description
Barrel files (files that only re-export other files) are detected. The rule discourages barrel files because they can obscure dependencies, slow down tree-shaking, and make it harder to trace imports.

### Assessment
- **False Positive**: Yes. The main library file `saropa_dart_utils.dart` is the standard Dart package entry point that re-exports the public API. This is the expected and recommended Dart package structure per `dart.dev` guidelines. Every published Dart package uses this pattern.
- **Should Exclude**: Yes. The package entry point is a required barrel file by Dart convention.

### Affected Files
- `lib\saropa_dart_utils.dart`

### Recommended Action
EXCLUDE -- add `avoid_barrel_files: false` to `analysis_options_custom.yaml`. The main library entry point is a standard Dart package convention and should not be flagged.
