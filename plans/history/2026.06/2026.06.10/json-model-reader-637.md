# JSON → typed model reader (roadmap #637)

Triggered by the user's request to build the top 10 "obvious" roadmap utilities, then run `/finish` after each. This is item 1 of 10: a forgiving decoded-JSON reader that maps fields into typed values while accumulating structured validation errors instead of throwing on the first bad field.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/json_model_mapper_utils.dart` (`JsonModelReader`), new test `test/parsing/json_model_mapper_utils_test.dart`, barrel export, CODE_INDEX row, CHANGELOG `[Unreleased]` entry.

**Design:** `JsonModelReader(source, {path})` wraps a decoded JSON object. A non-map source is coerced to an empty map so required reads report `missing` rather than throwing a cast error. Typed reads — `requireString/requireInt/requireBool/requireDouble/requireList<E>/optionalString/child` — return null on failure and append a `ValidationErrorUtils` to the shared `errors` collector (reusing the existing `ValidationErrors`/`ValidationErrorUtils` from `validation_error_utils.dart`, not a new error type). `requireDouble` widens `int`→`double`. `child(key)` returns a sub-reader carrying a dotted path prefix (`address.city`) so nested failures surface with full context. Errors carry `code: 'missing'` vs `code: 'type'` so a UI can treat an absent field differently from bad data.

**Tests:** 8 cases — happy path, multi-error accumulation (no throw-on-first), missing-vs-type code distinction, optional fallback (no error on absence, error on wrong type), heterogeneous-list rejection, non-map source, nested dotted-path child, non-object child. All pass. `flutter analyze` clean on both files.

**Reviewer notes:** No `.first`/`.single` unsafe accessors. No recursion (child is caller-driven). Element check in `requireList` uses `v.every((e) => e is E)` then `cast<E>()` — sound for the homogeneous-list contract.

No bug archive — task did not close a bugs/*.md file.
