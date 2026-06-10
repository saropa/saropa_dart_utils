# URI pattern matcher (roadmap #630)

Item 3 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch. Adds a segment-based path-template matcher with typed params, the building block routers re-implement with ad-hoc splitting or hand-rolled regex.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/url/uri_pattern_utils.dart` (`UriPattern`), new test `test/url/uri_pattern_utils_test.dart`, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** `UriPattern(template)` compiles a template into a list of `_Segment`s — literals matched verbatim, or `{name}` / `{name:int}` captures. `match(path)` returns the captured params map, or null on segment-count mismatch, literal mismatch, or a failed `:int` constraint. Leading/trailing slashes and empty segments are stripped on both sides so `/a/b/` and `a/b` are equivalent. Captured values are raw (not percent-decoded) — documented; decode at the call site. No regex (segment-based, avoids regex edge cases).

**Tests:** 8 cases — named capture, count mismatch (too many / too few), literal mismatch, int constraint (accept/reject), slash normalization, all-literal empty-map match, root path, negative integer. All pass; `flutter analyze` clean.

**Reviewer notes:** `_Segment` uses a nullable `_paramName` (null = literal) read into a local before use to avoid a null-assertion. Three `substring` calls carry `// ignore: avoid_string_substring` with in-bounds proofs (brace strip guarded by `isParam`; colon halves guarded by `indexOf`). No `.first`/`.single` on unproven collections.

No bug archive — task did not close a bugs/*.md file.
