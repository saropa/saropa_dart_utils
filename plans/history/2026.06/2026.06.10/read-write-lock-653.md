# Read/write lock abstraction (roadmap #653)

Item 5 of the second "next 10" roadmap-utilities batch. An async reader/writer lock — concurrent reads or one exclusive write — with configurable writer/reader preference.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/read_write_lock_utils.dart` (`ReadWriteLock`), new test, barrel export, CHANGELOG entry.

**Design:** `read(action)` acquires a shared lock (many concurrent), `write(action)` the exclusive lock; both release in `finally` (throw-safe). State is `_activeReaders` + `_writerActive` plus two `ListQueue<Completer>` waiter lines. `_acquireRead` proceeds immediately unless a writer holds the lock or (under writer-preference) one is queued; `_acquireWrite` proceeds only when idle (no readers, no writer). Releases call `_wakeNext`, which — only when the lock is free — hands off per policy: writer-preference grants the head writer else a full batch of readers; reader-preference drains queued readers first else a writer. `_grantAllReaders` admits the whole waiting reader batch concurrently.

**Anti-starvation:** writer-preference (default) makes a waiting writer block newly-arriving readers, so a steady read stream can't starve a write. `writerPreferred: false` flips to reader-preference (max throughput, writer-starvation risk) — documented trade-off, caller's choice.

**Distinction from `AsyncMutexUtils`:** the mutex serializes everything; this lets reads run in parallel and only excludes around writes — the read-heavy-cache primitive. Reentrancy is explicitly unsupported (documented; a write inside a read on the same lock deadlocks).

**Tests:** 7 cases — concurrent readers (`activeReaders == 2`), reader blocked while a writer holds, writes serialize (`w2` waits for `w1`), writer-preference ordering (`r1 → w → r2`, the queued writer beats the late reader), reader-preference ordering (`r1 → r2 → w`, the late reader jumps the writer), and result-return + release-on-throw. All pass; `flutter analyze` clean.

**Reviewer notes:** the IDE flagged stylistic Infos (`prefer_boolean_prefixes` on `writerPreferred`, `avoid_ignoring_return_values` on the intentional `_grantWriter()` call) — neither is in the project's enabled tier (`flutter analyze` clean), so the public API name `writerPreferred` was kept (clearer than an `is`-prefixed alternative). Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
