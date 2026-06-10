# JSON schema validation (roadmap #636)

Item 4 of the "next 5" roadmap-utilities batch. Adds declarative one-pass validation of JSON-like maps, a companion to the field-by-field `JsonModelReader` (#637).

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/json_schema_utils.dart` (`JsonType`, `FieldSchema`, `validateJsonSchema`), new test, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** Describe an object as a `Map<String, FieldSchema>`; each `FieldSchema` carries a `JsonType`, `isRequired` (default true), and optional `allowed` enum set. `validateJsonSchema(object, schema)` walks the schema once and accumulates a `ValidationErrors` (reusing the existing error model): a required absent/null field is `missing`, a present wrong-typed value is `type`, a value outside `allowed` is `enum`. `JsonType.integer` matches `int` only; `JsonType.number` matches any `num`. A non-map input yields one object-level type error. Never throws.

**Tests:** 8 cases — conforming object, omitted optional, missing-required, wrong-type, enum violation, multi-error single pass, non-map input, and integer-vs-number distinction (double accepted by number, rejected by integer). All pass; `flutter analyze` clean.

**Reviewer notes:** Reuses `ValidationErrors`/`ValidationErrorUtils` (same error codes as `JsonModelReader`, so the two compose). `isRequired` (not `required`) avoids both the boolean-prefix lint and the contextual-keyword pitfall. `for` over `schema.entries` with `continue` keeps nesting ≤ 2 and avoids a foreach-literal.

No bug archive — task did not close a bugs/*.md file.
