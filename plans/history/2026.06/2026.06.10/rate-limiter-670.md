# Token-bucket rate limiter (roadmap #670)

Item 6 of the "next 10" roadmap-utilities batch. Smooths bursts of work to a sustainable average rate via a continuously-refilling token bucket. The non-blocking allow/deny primitive most rate-limited clients need.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/async/rate_limiter_utils.dart` (`TokenBucketRateLimiter`), new test, barrel export, CHANGELOG entry.

**Design:** tokens refill lazily (on each call, not on a timer) at `tokensPerSecond` up to `capacity`, starting full so an initial burst is allowed. `tryAcquire([tokens])` refills then deducts atomically — all-or-nothing, no partial spend. `timeUntilAvailable([tokens])` converts the token deficit to a ceil-rounded wait so the returned instant is the first moment the request can succeed. `availableTokens()` exposes the fractional count. Time comes from an injectable `DateTime Function() now` (default `DateTime.now`); tests pass a mutable virtual clock and advance it, so refill is deterministic with no `Timer` and no real waiting.

**Why non-blocking, no Timer:** a `Timer`-based `await acquire()` would tie behavior to wall-clock scheduling and make tests flaky. The deterministic `tryAcquire` + `timeUntilAvailable` pair lets the caller compose the wait (e.g. with the #655 scheduler or a `Future.delayed`) while the limiter stays pure and testable.

**Robustness:** refill caps at `capacity` (no overflow); a clock that didn't advance or stepped backward (`elapsedMicros <= 0`) accrues nothing and leaves the baseline untouched, so a later forward step still measures the full gap. Requesting `tokens` outside 1..capacity throws `ArgumentError` — a request larger than the bucket can ever hold is a bug, not a denial. Construction asserts `tokensPerSecond > 0` and `capacity >= 1`.

**Tests:** 11 cases — initial burst to capacity, rate-based refill on clock advance, overflow cap, no-partial-spend, `timeUntilAvailable` zero-when-available and deficit wait (1 token at 2/s = 500ms), reject >capacity and <1, assert on non-positive rate, and no-accrual on backward clock. All pass; `flutter analyze` clean.

**Reviewer notes:** dropped an initial `late _lastRefill` in favor of initializer-list seeding from the same clock source (clearer, removes LateInitializationError risk). The two IDE stylistic Infos (`prefer_correct_callback_field_name` on `_now`, `prefer_nullable_over_late`) are not in the project's enabled tier — `flutter analyze` is clean. Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
