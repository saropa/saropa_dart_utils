# Async resource pool (roadmap #666)

Item 7 of the "next 10" roadmap-utilities batch. Bounds how many expensive-to-create resources exist at once and reuses idle ones — connection/client pooling that apps otherwise hand-roll.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/resource_pool_utils.dart` (`ResourcePool<T>`, `ResourceFactory` / `ResourceDisposer` typedefs), new test, barrel export, CHANGELOG entry.

**Design:** `acquire` reuses an idle resource, else creates one if `_created < maxSize`, else parks a `Completer<T>` on a FIFO waiter queue. `release` hands the resource straight to the head waiter if any, otherwise returns it to idle. `use(action)` wraps acquire/release in a try/finally so a resource can never leak (released even when the action throws). The cap is on `_created` (idle + in use); concurrent acquires are safe because `_createTracked` increments `_created` synchronously before its `await`. A failed factory rolls back `_created` so a transient error doesn't permanently consume a slot.

**Close semantics:** `close()` disposes the idle resources it holds (awaiting each `onDispose`), fails parked borrowers with `StateError`, and blocks new acquisitions. A resource still checked out at close is NOT disposed by the pool — a late `release` just drops it from the count. This contract keeps `release` synchronous (no fire-and-forget async disposal) and is documented on both `release` and `close`; callers return resources before closing or dispose outstanding ones themselves.

**Tests:** 10 cases — lazy create + idle reuse (only one created across sequential uses), create-to-maxSize for concurrent borrowers, third borrower waits then runs after release (order asserted), release-on-throw frees the slot, create-failure count rollback, idle disposal on close, acquire-after-close rejected, waiting-borrower failure on close, maxSize<1 assertion. All pass; `flutter analyze` clean.

**Reviewer notes:** the original design disposed resources on release-after-close via fire-and-forget, which produced an unwinnable lint cascade (`avoid_unawaited_future` / `avoid_future_ignore` / `avoid_swallowing_exceptions` / `require_catch_logging`) because a sync method can't await a disposer without either leaking the future or swallowing its error. Resolved by making `close()` the single disposal authority over idle resources and giving checked-out resources to the caller — simpler and honest. `completeError` carries `StackTrace.current`; `_closed` renamed `_isClosed` for the boolean-prefix convention; returns in the async `acquire` use `await`. Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
