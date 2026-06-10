# Bounded work queue with backpressure (roadmap #654)

Item 3 of the second "next 10" roadmap-utilities batch. A fixed-capacity async producer/consumer channel where a full buffer throttles producers (backpressure) instead of growing memory unbounded.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/bounded_work_queue_utils.dart` (`BoundedWorkQueue<T>`), new test, barrel export, CHANGELOG entry.

**Design:** a `ListQueue<T>` buffer capped at `maxSize`. `push` first tries `tryPush` (hand directly to a waiting consumer, else buffer if room); when full it parks `(item, Completer)` on `_pushWaiters` and returns the completer's future — the backpressure signal. `pull` serves from the buffer (then `_admitWaitingProducer` moves one blocked producer's item into the freed slot, preserving FIFO) or parks a `Completer<T>` on `_pullWaiters` when empty. Direct hand-off: a pushed item goes straight to a waiting consumer without touching the buffer. `tryPush`/`tryPull` are the non-blocking variants. `close` blocks new pushes, fails blocked producers/consumers with `StateError` (carrying `StackTrace.current`), and leaves buffered items drainable (pull on empty+closed then errors).

**Correctness notes:** `maxSize >= 1` asserted (rendezvous mode excluded to avoid buffer-overflow edge cases). `pull` is implemented independently of `tryPull` so a nullable `T` with a buffered null is handled correctly (documented: `tryPull` returns null on empty, ambiguous for nullable T — use `pull`). The admit-on-pull step keeps total in-flight ≤ maxSize and arrival order intact.

**Distinction from `TaskScheduler` (#655):** the scheduler runs N tasks concurrently (fire-and-forget with priority); this is a flow-control channel between a producer and a consumer where backpressure is the whole point. No overlap.

**Tests:** 11 cases — maxSize<1 assert, buffer-to-capacity without blocking, FIFO pull order, direct hand-off to a waiting consumer (buffer untouched), backpressure (second push parks, releases on pull, admitted item pulled next), `tryPush` false-when-full, `tryPull` null-when-empty, push-after-close rejected (future + sync), drain-after-close-then-error, and blocked producer/consumer failure on close. All pass; `flutter analyze` clean.

**Reviewer notes:** the IDE flagged a stylistic `prefer_correct_handler_name` Info on `isFull` — not in the project's enabled tier (`flutter analyze` clean). Removed an unnecessary `dart:async` import from the test (flutter_test re-exports it). Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
