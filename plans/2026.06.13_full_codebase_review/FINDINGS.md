# Findings — Full Codebase Review

Severity: **S1** crash/hang/data-loss · **S2** silently-wrong result · **S3** doc/contract
mismatch · **S4** quality/style/perf. Status: `candidate` → `confirmed` → `fixed`.

| # | File:line | Sev | Status | Evidence | Proposed fix |
|---|-----------|-----|--------|----------|--------------|
| 1 | validation/safe_temp_name_utils.dart:6,10 | S2 | fixed | Module-level `Random()` (non-secure, seedable) generates names doc'd "collision-resistant"/"safe"; predictable temp names enable temp-file race/guessing attacks. Also no guard for `length <= 0` (returns `''`, silently not collision-resistant). | Use `Random.secure()`; throw `ArgumentError` for `length <= 0`. |
| 2 | collections/hyperloglog_utils.dart | S2 | fixed (web-safe limbs; VM output unchanged, verified 500k) | 64-bit hash mixing (`* 0xbf58476d1ce4e5b9`), `hash >>> (64-precision)`, and `1 << r` (r up to 61) in `cardinality()`. Per Dart's number model, on web `int` is a 53-bit double and bitwise/shift ops truncate to 32-bit unsigned → wrong register index/rank; `1 << r` for r>30 becomes garbage/`0` → `1.0/(1<<r)` can divide by zero → `Infinity`/NaN estimate. Doc hedges "approximate" but never says "VM-only". | Document VM-only, OR rework to 32-bit-safe lanes. Empirical web run is closing step. |
| 3 | parsing/stable_hash_utils.dart | S2/S3 | fixed (web-safe limbs; VM output unchanged, verified 200k + pinned test) | FNV-1a 64-bit: `(hash ^ unit) * _fnvPrime` relies on VM 64-bit two's-complement wrap. On web the multiply overflows 53-bit precision and `& 0xFFFFFFFF` truncates to 32 bits → a VM-computed digest will NOT equal the web-computed digest for the same data. Doc claims the hash is "stable... on any platform" and "equal inputs always yield equal hashes across runs" — false across the VM/web boundary, defeating its stated use (cross-client cache keys / change detection / dedup). | Either document VM-only explicitly, or implement a web-safe 32-bit FNV-1a (mask each step to 32 bits, like rolling_hash mods by a 30-bit prime). |
| 4 | hex/hex_utils.dart:31 | S3 | fixed | Dartdoc states "Prints a warning to the debug console if the input is invalid or too large." The code prints nothing (returns `null`). v1.6.0 changelog claims this false "prints a warning" claim was removed, but the fix only touched the `Example` block — this prose sentence survived. | Delete the sentence. |
| 5 | map/map_extensions.dart:67 | S4 | fixed | `getRandomListExcept` calls `available.shuffle(Random())` — a fresh, non-injectable RNG. Inconsistent with the library convention (skip_list/reservoir/sampling/constrained_subset/retry_policy all take an optional `Random?`); makes the method untestable/non-reproducible. | Add optional `Random? random` param, default `Random()`. |
| 6 | parsing/varint_utils.dart:16,39 | S3 | fixed (doc caveat) | 64-bit varint round-trips use `(b & 0x7f) << shift` (shift to 63) and `v >>>= 7`. Web truncates shifts to 32 bits and >2^53 isn't representable, so values above ~2^32 don't round-trip on web. No platform caveat in the doc. | Add a "64-bit values are VM-only; web is limited to 32-bit" note, or constrain documented range. |

| 7 | 40 `assert()` across 22 files (see list) | S2 | fixed (18 files; const ctors kept by design) | The asserts are **preconditions on public-API input**, not internal invariants. Release builds strip them (`avoid_assert_in_production`), so invalid input is unchecked in production. The dangerous subset strips to a **silent NaN / wrong result / hang, not a throw**: `collections/spatial_grid_utils.dart:29` (cellSize>0 → ÷0 in cell index), `collections/time_decay_counter_utils.dart:38` (halfLifeMillis>0 → ÷0 decay), `async/rate_limiter_utils.dart:30` (tokensPerSecond>0 → ÷0), `stats/data_binning_utils.dart:23` (max>min → ÷0/negative width), `async/sliding_window_rate_limiter_utils.dart:33` & `datetime/rate_limit_schedule_utils.dart:33` (period>0), `caching/{lru,mru,size_limit}` (maxSize/capacity>0 → broken eviction), `datetime/quiet_hours_utils.dart:26` (start!=end → degenerate window), `collections/interval_tree_utils.dart` (low<=high → silently wrong query), `stats/gini_utils.dart:32` (non-negative → out-of-range result). The array-index asserts (`segment_tree`, `fenwick`) are lower risk (the indexed access throws `RangeError` in release anyway). **This conflicts with deliberate commit 037c44e** which declared these "intentional dev-time asserts" and disabled the lint — but that decision is inconsistent with the project's own v1.6.0 FenwickTree fix rationale ("assert stripped → hang/silent-wrong in production"). NEEDS USER SIGN-OFF before changing. | Convert the divide-by-zero / silent-wrong subset (~12 sites) to `if`-throw `ArgumentError`, matching the FenwickTree/rolling_correlation precedent; leave throw-anyway index asserts as-is. |

## Cleared (verified OK — no fix needed)

- **1d DateTime.now() (23 files): clean.** Every datetime predicate accepts an optional `now` and captures `DateTime.now()` once per call into a local (`now ?? DateTime.now()`); no multi-read-within-one-op race. High per-file counts are many distinct methods each capturing once. (Spot-check caching TTL during Phase 2 for the put/get pair, but no race pattern found.)

- `collections/rolling_hash_utils.dart` — mods by 30-bit prime (`1000000007`); all intermediates stay < 2^53. Web-safe; the correct pattern.
- `collections/bloom_filter_utils.dart` — `_mix` is VM/web-divergent but the filter is in-memory and `add`/`mightContain` share the same mix within a run, so membership is correct; `.abs()` after `% positive` is redundant (Dart `%` is already non-negative) — harmless S4 nit.
- `niche/checksum_utils.dart`, `niche/hash_utils.dart` — bounded/in-memory intra-run; no cross-platform contract claimed.
- `uuid/uuid_v4_utils.dart` — correctly uses `Random.secure()`.
- `niche/random_string_utils.dart` — honestly documents "not cryptographically secure" + guards `length <= 0`.
- `random/common_random.dart` — documented seedable convenience.
- reservoir / stratified / weighted-subset samplers, `skip_list`, `retry_policy` — all take injectable `Random?`.
- `collections/quickselect_utils.dart` — median-of-three Lomuto, copies input, bounds-checks `k`; correct.
- `collections/stable_matching_utils.dart` — proposer-optimal Gale-Shapley; validates unknown/duplicate refs, O(1) rank lookups, single-match invariant holds on inversion; correct.
- `collections/knapsack_utils.dart` — standard 0/1 DP table + correct backward reconstruction; correct.
- `collections/lis_utils.dart` — O(n²) DP, strict-increasing, prev-chain reconstruction terminates correctly; correct.
- `parsing/semver_utils.dart` — correct §11 precedence (pre-release < release, numeric-below-alphanumeric, longer pre-release ranks higher); lenient parse (allows leading zeros) but that's documented. Correct.

### Strategic note (Phase 2 direction)
The v1.6.0 audit handled canonical algorithms well — every textbook algorithm checked so far (quickselect, Gale-Shapley, knapsack, LIS, reservoir, ES-weighted-sampling) is correct. The surviving bugs were all CROSS-CUTTING (web-int, release-stripped asserts, RNG, doc drift), now fixed in Phase 1. Remaining bug probability concentrates in BESPOKE custom-logic files (parsers, date arithmetic, `*_more`/grab-bag utils), not the algorithm implementations. Phase 2 prioritizes those.

## Phase 2.1 collections — verified clean (exhaustive read)

disjoint_set, kmeans, min_max_heap (Atkinson trickle up/down correct), nway_merge, bin_packing,
dependency_resolver, top_k_heap, pareto_frontier, greedy_set_cover, trie, difference_array,
quickselect, stable_matching, knapsack, lis, reservoir_sampling, constrained_subset, bloom_filter,
rolling_hash, hyperloglog (now web-safe), skip_list, spatial_grid, time_decay, segment_tree,
timeseries_buffer, multi_index, interval_tree, bk_tree, fenwick.

## Minor S4 notes (style/doc — defer to a synthesis cleanup pass; not bugs)

| # | File | Note |
|---|------|------|
| 8 | collections/dependency_resolver_utils.dart:225 | `_satisfiesCaret` uses a **nested ternary**, which the project `dart.md` explicitly bans ("never use"). Analyze-clean but a style-rule violation. Rewrite as `if`/`else`. |
| 9 | collections/top_k_heap_utils.dart | Doc says "via min-heap" but it's a sorted size-k list (re-sorts on each replace, O(k log k)). Doc/impl mismatch; correct results. |
| 10 | collections/bin_packing_utils.dart | An item heavier than `capacity` silently opens its own over-capacity bin (no flag). By-design for the heuristic; could document. |
| 11 | collections/fenwick_tree_utils.dart:21 | The `FenwickTree(int size)` constructor still uses `assert(size >= 0)` (v1.6.0 converted only its methods). `size == -1` passes `List.filled(0)` and builds an unusable tree (`_size = -1`); release strips the assert. Low severity (every op then throws RangeError). Convert to the static-helper throw for consistency in the synthesis pass. |

## Phase 2 wave-1 (subagent-assisted audit of collections-rest, datetime, parsing, async, string)

### Fixed this round (verified against live code, regression tests added)
| # | File | Sev | Fix |
|---|------|-----|-----|
| 12 | string/string_analysis_extensions.dart:101 | S2 | replacement-char constant 56327 (0xDC07 surrogate) → 65533 (U+FFFD); hasInvalidUnicode/removeInvalidUnicode now work as documented |
| 13 | string/string_manipulation_extensions.dart (removeFirstLastChar, removeMatchingWrappingBrackets) | S2 | count graphemes not code units (matches removeLastChars); astral content no longer mis-sliced |
| 14 | string/string_lower_extensions.dart (removePrefix, removeSuffix) | S2 | code-unit `substring` instead of grapheme `substringSafe` (consistent with startsWith/endsWith) |
| 15 | async/async_semaphore_utils.dart:62 | S2 | release() throws StateError on over-release instead of letting `_available` exceed `permits` |
| 16 | async/timeout_policy_utils.dart | S3 | documented the null-fallback limitation |

### Candidate backlog from wave-1 (verify, then fix in a later batch)
| File | Sev | Issue |
|------|-----|-------|
| async/retry_utils.dart:28 | S3 | exponential delay shift `1 << (attempt-1)` NOT clamped (siblings retry_policy/exponential_backoff clamp to 30/31) → web 32-bit overflow / wrong delay at high attempt counts |
| async/debounce_utils.dart, throttle_utils.dart | S3 | returned closure exposes no cancel/dispose; pending Timer fires after owner disposed (use-after-dispose) + leaks. Stream variants handle it; these don't |
| async/idempotent_async_utils.dart:14 | S4 | dedup key with two different generic `T` for same key: `is Future<T>` test fails, runs a second op + evicts early. Same-key-different-type misuse, silent |
| async/async_mutex_utils.dart:27-30 | S4 | dead try/catch — waiters are never completed with an error, so the catch is unreachable |
| string/html_sanitizer_utils.dart | S2 | dartdoc claims "allowlist tags/attributes" but there is NO allowlist (strips ALL tags to text); tag regex `<[^>]+>` also mis-parses `>` inside attribute values, corrupting output. Doc fix + caveat that regex tag-stripping is not a security sanitizer |
| string/acronym_extract_utils.dart:8 | S3 | name-capture group `[A-Za-z\s]+` greedy across newlines/words → over-captures preceding text |
| string/text_fingerprint_utils.dart | S4 | doc/name say "32-bit" but value never masked to 32 bits; `fingerprintDistance` masks operands, dropping the high 32 bits |
| string/string_slug_extensions.dart:39 | S4 | dartdoc example output wrong (`'hello-worl'` vs actual `'hello'`) |
| string/item_similarity_utils.dart (in collections) | S3 | `recommend` doc promises first-seen tie order; `List.sort` is unstable so ties may reorder |
| string/window_functions_utils.dart:22 | S3 | `rank` dartdoc omits that it ranks DESCENDING (largest = rank 1) |
| string/ngram_utils.dart:23 | S4 | `wordNgrams('   ', 1)` returns `[['']]` (split of blank → `['']`, not empty) |
| datetime/month_weekday_utils.dart:65,72 | S3 | `lastWeekdayOfMonth` steps with fixed `Duration` on local DateTime → DST day shifts result (used by last-Sunday-of-Oct/Mar rules — the exact DST months). Should step by calendar fields |
| datetime/date_time_relative_predicate_predicates.dart:130 | S4 | `isOlderThanYesterday` builds the boundary instant via fixed 24h subtract → off by DST offset on 23h/25h days |
| datetime/time_rounding_utils.dart:16 | S4 | `roundMinutes` uses `~/` (truncates toward zero) → floor/ceil wrong for negative minutes; domain likely ≥0 but undocumented |
| parsing/log_line_parser_utils.dart:62 | S4 | duplicate field name → opaque RegExp FormatException instead of a clear "duplicate field" error |

### Verified clean in wave-1 (high level)
- collections rest (27 files): all algorithm recurrences correct (LCS, agglomerative Lance-Williams, union-find, interval scheduling, combinatorics, histogram half-open bins, sliding-window). Only S3/S4 doc notes (item_similarity tie-order, window_functions rank direction).
- datetime (57 files): billing/fiscal/business-day half-open ranges, leap-year, ISO-week, Hebrew converter, rrule/recurrence all verified; only the DST-stepping notes above.
- parsing (36 files): Luhn/ISBN/cron/CSV/JSON-path/expression-evaluator/sql-filter all correct; only loose-by-design IP/size parsing.
- async (34 files): mutex/rwlock/circuit-breaker/rate-limiters/streams correct; findings above are the exceptions.
- string A–M (mostly clean): Levenshtein/TF-IDF/fuzzy/glob/language-detect correct.

## Themes still to verify (Phase 1 remainder)

- **1b asserts:** 40 `assert()` across 22 files — classify precondition (→throw) vs invariant (ok).
- **1d now():** 23 files call `DateTime.now()` directly — check single-instant capture & injectable clock.
- **1e–1h:** Unicode, numeric edge cases, boundaries, unsafe collection access.

Reference: web int semantics — https://dart.dev/resources/language/number-representation ;
dart2js 32-bit bitwise truncation — https://github.com/dart-lang/sdk/issues/8298
