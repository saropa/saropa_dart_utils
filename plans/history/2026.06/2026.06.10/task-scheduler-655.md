# Priority task scheduler with concurrency limit (roadmap #655)

Item 5 of the "next 10" roadmap-utilities batch. Runs async tasks under a concurrency cap, dispatching the highest-priority waiter when a slot frees — the reordering a FIFO semaphore can't provide.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/task_scheduler_utils.dart` (`TaskScheduler`, `ScheduledTask` typedef), new test, barrel export, CHANGELOG entry.

**Design:** `schedule(task, {priority})` wraps the task in a `Completer<T>`, inserts a `_PendingTask` into a priority-ordered queue (`_insert` keeps it sorted desc-priority then asc-sequence), and calls `_pump`. `_pump` dispatches from the queue head while `running < concurrency`. `_execute` increments `running` **synchronously** before its first `await` (so `_pump`'s cap check is race-free), forwards result/error to the completer, then in `finally` decrements and re-pumps. A monotonic `_sequence` is the FIFO tie-breaker for equal priorities; since each new task has the largest sequence, equal-priority entries always insert after their predecessors.

**Distinction from `AsyncSemaphoreUtils` (#651):** the semaphore is FIFO — waiters resume in arrival order. The scheduler reorders the *waiting* backlog by priority while leaving running jobs untouched (no preemption). Added alongside; the semaphore is unchanged.

**Failure isolation:** a throwing task has its error routed to that task's future via `completeError`; the `finally` still releases the slot and pumps, so one failure can't deadlock the queue.

**Tests:** 7 cases — concurrency cap (running==2/pending==2 with 4 gated tasks), highest-priority-first dispatch (A holds slot; C5→D3→B1 order), FIFO within equal priority (X→Y→Z), result propagation, error surfaced without stalling (next task still runs, running returns to 0), and the `concurrency >= 1` assertion. All pass; `flutter analyze` clean.

**Reviewer notes:** the synchronous `running++` placement is the correctness crux and is commented as such — moving it after an `await` would let `_pump` over-dispatch. Queue insertion is O(n) (linear scan); fine for typical backlogs, noted implicitly by the head-is-next-dispatch design. The IDE flagged a stylistic `prefer_correct_callback_field_name` Info on the `start` thunk field, but it is not in the project's enabled lint tier (`flutter analyze` is clean), so no change was made. Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
