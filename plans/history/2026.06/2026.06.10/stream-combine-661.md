# Stream join/zip/combineLatest operators (roadmap #661)

Item 4 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch. Adds the two stream-combination operators apps most often reach for from rxdart, implemented on dart:async only (no dependency).

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/stream_combine_utils.dart` (`zipStreams`, `combineLatestStreams`, private `_Cell`), new test `test/async/stream_combine_utils_test.dart`, barrel export, CODE_INDEX rows, CHANGELOG entry.

**Design:**
- `zipStreams` uses two `StreamIterator`s and `async*`. It awaits `moveNext()` on BOTH before yielding, so a half-pair at the end is never emitted; both iterators are cancelled in a `finally`.
- `combineLatestStreams` builds a `StreamController` that subscribes to the sources lazily in `onListen` (no events buffered before a listener exists) and cancels both in `onCancel`. Latest values are held in a generic `_Cell<T>` holder so `combine` receives `A`/`B` with no `as` cast, and a null cell cleanly means "no value yet". Errors are forwarded; the result completes only after both sources complete (`openCount` reaches 0). The controller-close future is `unawaited`.

**Tests:** 6 cases — zip pairs by index, zip stops at shorter + drops tail, zip empty; combineLatest emits-latest sequence (`1a,2a,2b`) with microtask pumping, completes only after both sources close, forwards errors. All pass; `flutter analyze` clean.

**Reviewer notes:** No unsafe casts (holder-cell pattern). No unawaited futures except the documented controller close. Lazy subscription avoids eager-listen leaks.

No bug archive — task did not close a bugs/*.md file.
