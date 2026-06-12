# pub.dev static-analysis score cleanup

The pub.dev package report scored "Pass static analysis" at 40/50, deducting points for 18 analyzer findings that the local `dart analyze` CLI did not surface. pana scores the package through the analysis server, which loads the `saropa_lints` plugin and the core `dangling_library_doc_comments` lint; the plain CLI run loaded neither, so the findings were invisible during normal development and only appeared on publish. The most numerous category was seven dangling library doc comments — file-level `///` comments with no `library;` directive to attach to.

## Finish Report (2026-06-12)

### Scope

(A) Dart library and test code. No VS Code extension code (B) and no docs/scripts-only change (C) beyond the changelog and this record.

### What changed and why

**Dangling library doc comments (7 files).** Each file opened with a file-level `///` description separated by a blank line (or an `import`) from the first declaration, leaving the comment unattached. The fix adds a `library;` directive immediately after the comment, which is the resolution the analyzer itself recommends. Affected files: `lib/base64/gzip_codec_io.dart`, `lib/base64/gzip_codec_stub.dart`, `lib/object/pipe_compose_utils.dart`, `lib/object/pipe_utils.dart`, `lib/object/shallow_copy_utils.dart`, `lib/testing/debug_utils.dart`, `lib/url/url_encode_utils.dart`. These edits are documentation-only and carry no runtime behavior.

**Release-stripped validation (`lib/stats/rolling_correlation_utils.dart`).** `rollingCorrelation` enforced its equal-length and `window >= 2` preconditions with `assert`, which the Dart compiler removes from release builds — a mismatched-length call would then read out of bounds in production instead of failing fast. The two asserts became `if`-throw guards raising `ArgumentError`, so the checks run in every build mode.

**Null-assertion and constant-index reads (`lib/collections/skip_list_utils.dart`).** The `add` method used `update[i]!`, whose `!` throws an uninformative `_CastError` if the invariant ever broke. It now reads the nullable value and throws a descriptive `StateError` naming the level. Three `[0]` reads in `values` and `floor` became `firstOrNull` (requiring the `package:collection` import). `firstOrNull` was chosen over `.first` deliberately: `.first` would have replaced a stylistic info-level lint with a more severe `avoid_unsafe_collection_methods` warning, since it throws on an empty collection. The surrounding code already handles the null case, so `firstOrNull` is both correct and lint-clean.

**Expression body (`lib/collections/fenwick_tree_utils.dart`).** `valueAt`, a single-return method, was converted to an arrow body, satisfying `prefer_arrow_functions` and `prefer_returning_shorthands`. The existing `// ignore: no_equal_arguments` directive was preserved on the line above the `rangeSum(index, index)` call so the degenerate-range suppression still applies.

**Test matcher (`test/parsing/varint_utils_test.dart`).** `expect(encoded.length, 10)` became `expect(encoded, hasLength(10))` for a proper matcher and clearer failure diagnostics.

**Commented-out-code false positives (3 files).** `prefer_no_commented_out_code` flagged three explanatory prose comments in `lib/num/num_more_extensions.dart`, `lib/datetime/date_time_week_extensions.dart`, and `lib/validation/jwt_structure_utils.dart`. The heuristic misfires when a comment line *begins* with an `identifier.member` token (for example `base64Url.decode ...`, `yearVal. (...`, or a lone `result.`), which reads as a dead member-access statement. Each comment was reworded so no line starts with that pattern; the explanations are unchanged in meaning, and no code or behavior was altered.

**Lint configuration (`analysis_options.yaml`).** Enabled `dangling_library_doc_comments` in the `linter.rules` block, mirroring the existing pattern that pins `curly_braces_in_flow_control_structures` so a pana-only check is visible in the local `dart analyze` CLI and caught before publish.

### Verification

- `dart analyze` (full project): `No issues found!` — the 18 findings are resolved.
- `flutter test` on the behavior-affected mirror files (`rolling_correlation_utils_test.dart`, `skip_list_utils_test.dart`, `fenwick_tree_utils_test.dart`, `varint_utils_test.dart`): all pass. The two `rolling_correlation` tests that pinned `AssertionError` were updated to expect `ArgumentError` to match the new release-safe guards.
- `flutter test` on the documentation-only `library;` files (`base64_utils_test.dart`, `debug_utils_test.dart`, `url_extensions_test.dart`, `url_extract_utils_test.dart`, `num_extensions_test.dart`, `date_time_extensions_test.dart`): all 661 pass, confirming the directives introduced no compile or import regression.

The local analyze and test pass is a proxy for the pub.dev score; the 50/50 result confirms only when pana re-runs against the published archive, because pana loads the `saropa_lints` plugin in a way the CLI only partially reproduces.

### Files changed

- `analysis_options.yaml` — enabled `dangling_library_doc_comments`.
- `lib/base64/gzip_codec_io.dart`, `lib/base64/gzip_codec_stub.dart`, `lib/object/pipe_compose_utils.dart`, `lib/object/pipe_utils.dart`, `lib/object/shallow_copy_utils.dart`, `lib/testing/debug_utils.dart`, `lib/url/url_encode_utils.dart` — added `library;`.
- `lib/stats/rolling_correlation_utils.dart` — assert → `if`-throw guards.
- `lib/collections/skip_list_utils.dart` — null-assertion guard, `firstOrNull`, `package:collection` import.
- `lib/collections/fenwick_tree_utils.dart` — arrow body for `valueAt`.
- `lib/num/num_more_extensions.dart`, `lib/datetime/date_time_week_extensions.dart`, `lib/validation/jwt_structure_utils.dart` — comment rewording.
- `test/parsing/varint_utils_test.dart` — `hasLength` matcher.
- `test/stats/rolling_correlation_utils_test.dart` — expect `ArgumentError`.
- `CHANGELOG.md` — `[Unreleased]` entry.

### Outstanding work

None. No `bugs/*.md` file described this work, so no bug was archived.
