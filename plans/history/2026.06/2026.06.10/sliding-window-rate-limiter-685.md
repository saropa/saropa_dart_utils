# Sliding-window-log rate limiter (roadmap #685)

Item 4 of the second "next 10" roadmap-utilities batch. Enforces an exact "N events per trailing window" limit by tracking recent event timestamps — the precise counterpart to the token-bucket limiter (#670).

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/sliding_window_rate_limiter_utils.dart` (`SlidingWindowRateLimiter`), new test, barrel export, CHANGELOG entry.

**Design:** keeps a `ListQueue<DateTime>` of in-window event timestamps (oldest first). `tryAcquire` prunes expired events, then admits-and-logs if `count < limit` else denies. `currentCount` prunes and returns the count. `timeUntilAvailable` returns zero below the limit, else `oldest + window - now` (when the oldest ages out, freeing a slot). `_prune` drops events at or before `now - window` (exclusive lower bound: an event exactly `window` old is expired). Time comes from an injectable `now` closure (default `DateTime.now`) so tests advance a virtual clock deterministically.

**Distinction from the token bucket (#670):** the bucket smooths to an average rate, O(1) memory, allows bursts to capacity; this is an exact rolling-window count, O(limit) memory, no over-limit burst. Both are valid rate limiters with different guarantees — added alongside, documented in both headers. The roadmap title's "storage abstraction" is deliberately NOT built (in-memory only; a pluggable store would be premature abstraction for the single-process common case — noted in the header).

**Tests:** 7 cases — assert on non-positive limit/window, allow-to-limit-then-deny, slot frees once the oldest ages out, exactly-window-old treated as expired (exclusive bound), `timeUntilAvailable` zero below limit and the exact wait (7s when 3s into a 10s window at limit 1). All pass; `flutter analyze` clean.

**Reviewer notes:** `.first` access in `timeUntilAvailable` and `_prune` replaced with `firstOrNull` + explicit null handling (the `avoid_unsafe_collection_methods` Warning and the project's nullable-safe-accessor rule) — `_prune`'s loop became `while (true) { firstOrNull; if (null || ...) break; }`. The IDE's `prefer_correct_callback_field_name` Info on `_now` is not in the project tier (`flutter analyze` clean). Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
