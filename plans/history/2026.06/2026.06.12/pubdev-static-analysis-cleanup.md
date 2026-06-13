# pub.dev static-analysis point-deduction cleanup

The pub.dev "Pass static analysis" check scored the package 40/50, deducting points
for 24 reported issues led by seven "Dangling library doc comment" findings. Those
findings come from pana's `lints_core` baseline, which the package's saropa_lints
plugin configuration does not surface through the local `dart analyze` CLI — so the
deductions were invisible to the normal analyze step and only appeared on the
published score page. Several file-level documentation comments were not attached to
a `library;` directive, two precondition checks used release-stripped `assert`s, a
skip-list traversal used an unsafe `!` and constant-index reads, and a handful of
explanatory comments began with an `identifier.member` token that the
commented-out-code heuristic misread as dead code.

## Finish Report (2026-06-12)

### Scope

(A) Dart library code — `lib/` and `test/`. No extension/TypeScript or UI surface;
no localization. Sections 5 (l10n) marked SKIPPED [A-NOT-IN-SCOPE].

### Changes

Documentation-attachment fixes (resolve `dangling_library_doc_comments`):
- Added a `library;` directive after the file-level doc comment in
  `base64/gzip_codec_io.dart`, `base64/gzip_codec_stub.dart`,
  `object/pipe_compose_utils.dart`, `object/pipe_utils.dart`,
  `object/shallow_copy_utils.dart`, `testing/debug_utils.dart`, and
  `url/url_encode_utils.dart`.

Correctness improvements (also clear plugin lints):
- `stats/rolling_correlation_utils.dart`: the equal-length-series and `window >= 2`
  preconditions were enforced with `assert`, which the Dart compiler strips from
  release builds — a mismatched call would then read out of bounds in production.
  Both are now `if`-throw guards raising `ArgumentError`, so the contract holds in
  release. The mirror test pins the thrown errors.
- `collections/skip_list_utils.dart`: `add` replaced a `!` null-assertion on the
  predecessor array with an explicit invariant guard that throws `StateError`; the
  `values` iterator and `floor` switched three level-0 `[0]` reads to `firstOrNull`
  (importing `package:collection`), so neither the unsafe-collection nor the
  null-assertion lint fires while the level-0 traversal semantics are unchanged.

Lint-heuristic and style adjustments (no behavior change):
- Reworded explanatory comments in `num/num_more_extensions.dart`,
  `datetime/date_time_week_extensions.dart`, and `validation/jwt_structure_utils.dart`
  so no comment line begins with an `identifier.member` token that the
  commented-out-code lint misreads as code.
- `collections/fenwick_tree_utils.dart`: `valueAt` converted to an expression body.
- `parsing/varint_utils_test.dart`: `expect(encoded.length, 10)` became
  `expect(encoded, hasLength(10))` for a clearer matcher and failure message.

### Verification

- Targeted tests pass: `skip_list_utils_test.dart`, `fenwick_tree_utils_test.dart`,
  `rolling_correlation_utils_test.dart`, `varint_utils_test.dart`,
  `num_more_extensions_test.dart` — 77 tests, all green.
- `dart analyze` on the changed library files reports no issues.
- Reproducing pana's baseline locally — `dart analyze` with
  `package:lints/core.yaml` and again with `package:lints/recommended.yaml` over
  `lib/` — reports "No issues found" in both cases.
- `dart format` reports 0 of 476 files changed.

### Relationship to the 1.6.0 release

These fixes are not present in the published 1.6.0 tarball (commit 037c44e). The
pub.dev static-analysis score will only update once a version carrying these changes
is published. The CHANGELOG records them under `[Unreleased]`.

### Documentation / maintenance

- CHANGELOG updated with an `[Unreleased]` section enumerating each fix.
- README verified — no product facts changed.
- No `bugs/*.md` or active plan describes this work; this file is the durable record.
