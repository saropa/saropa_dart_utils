# Generic cache interface + adapters (roadmap #523)

Item 6 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch. Unifies the three existing in-memory caches under one `Cache` interface and adds a write-through async adapter, so consumers depend on the capability rather than a concrete eviction policy.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/caching/cache_interface.dart` (`Cache<K,V>`, `WriteThroughCache`); retrofitted `lru_cache.dart`, `ttl_cache.dart`, `size_limit_cache.dart` with `implements Cache<K, V>` (additive — no behavior change); new test `test/caching/cache_interface_test.dart`; barrel export; CODE_INDEX rows; CHANGELOG entry.

**Design:** `Cache<K, V>` is an `abstract interface class` with `V? get(K)`, `void set(K, V)`, `void clear()`. All three caches already matched these signatures exactly, so the retrofit is a pure `implements` addition. `WriteThroughCache<K, V extends Object>` wraps a `Cache` + an async loader: `getOrLoad` returns a hit, else dedupes concurrent misses through an `_inFlight` map (one load per key), stores on success, and clears the slot in a `finally` so a failed load is not cached and retries. Expiration is delegated to the wrapped cache (pass a `TtlCache`).

**Tests:** 9 pass — 5 new (interface conformance for all three caches, consumer-depends-on-interface, write-through load-once, concurrent-miss dedup via a Completer gate, failed-load-not-cached retry) + 4 existing `cache_test.dart` cases re-run green (retrofit did not break them). `flutter analyze lib/caching/ test/caching/` clean.

**Reviewer notes:** Retrofit is additive and audited against the existing behavior-only cache test. Three justified lint ignores in `cache_interface.dart`: `prefer_wildcard_for_unused_param` (file-level — interface params name the contract), `require_cache_expiration` (delegated to wrapped cache), `avoid_unawaited_future` (`_inFlight.remove` returns the stored future, intentionally discarded). `WriteThroughCache` constrains `V extends Object` so a null `get` unambiguously means miss.

No bug archive — task did not close a bugs/*.md file.
