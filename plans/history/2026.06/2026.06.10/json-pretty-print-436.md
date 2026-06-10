# JSON pretty-printer (roadmap #436)

Item 10 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch (substituted for #683 normalized error model, which already exists). Adds an indenting JSON stringifier with optional key sorting, distinct from the existing `canonicalizeJson` (which sorts keys in-structure but does not stringify).

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/json_pretty_print_utils.dart` (`prettyPrintJson`), new test, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** `prettyPrintJson(value, {indent = 2, sortKeys = false})` selects `JsonEncoder.withIndent(' ' * indent)` for indented output or `const JsonEncoder()` for compact single-line when `indent <= 0`. When `sortKeys` is true it pre-processes the value through the existing `canonicalizeJson` (reuse, not a re-implementation) to recursively sort object keys; that also canonicalizes numbers, a no-op for the int/double values `jsonDecode` produces (documented).

**Tests:** 7 cases — default 2-space indent, recursive key sort, insertion-order preserved when not sorting, custom indent width, compact `indent: 0`, nested key sort, lists/scalars. All pass; `flutter analyze` clean.

**Reviewer notes:** Reuses `canonicalizeJson` and `dart:convert.JsonEncoder` rather than hand-rolling indentation or key sorting. Pure function, no unsafe accessors.

No bug archive — task did not close a bugs/*.md file.
