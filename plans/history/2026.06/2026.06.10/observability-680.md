# Observability helpers (roadmap #680)

Item 9 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch (substituted for #435 CSV dialect detector, which already exists). Centralizes the timing-and-logging boilerplate apps sprinkle around operations.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/observability_utils.dart` (`observeAsync`, `observeSync`), new test, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** Both wrappers start a `Stopwatch`, run the operation, and on success call `onSuccess(elapsed, result)`; on any error they call `onError(elapsed, error, stackTrace)` and **rethrow** so the wrapper is transparent and never swallows a failure. The catch is `on Object catch` (the analyzer's recommended comprehensive form) precisely because an observability wrapper must time and report every failure mode, then rethrow.

**Tests:** 5 cases — async success (result + onSuccess fires), async error (rethrows, onError fires, onSuccess does not), async without hooks; sync success, sync error. All pass; `flutter analyze` clean.

**Reviewer notes:** `on Object catch` + `rethrow` is the correct pattern here and clears `avoid_catch_all`/`prefer_on_over_catch` without an ignore. `Stopwatch` uses real wall-clock time, appropriate for measuring operation latency. Hooks are optional (`?.call`).

No bug archive — task did not close a bugs/*.md file.
