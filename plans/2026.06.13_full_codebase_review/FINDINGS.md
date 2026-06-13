# Findings — Full Codebase Review

Severity: **S1** crash/hang/data-loss · **S2** silently-wrong result · **S3** doc/contract
mismatch · **S4** quality/style/perf. Status: `candidate` → `confirmed` → `fixed`.

| # | File:line | Sev | Status | Evidence | Proposed fix |
|---|-----------|-----|--------|----------|--------------|
| 1 | validation/safe_temp_name_utils.dart:6,10 | S2 | fixed | Module-level `Random()` (non-secure, seedable) generates names doc'd "collision-resistant"/"safe"; predictable temp names enable temp-file race/guessing attacks. Also no guard for `length <= 0` (returns `''`, silently not collision-resistant). | Use `Random.secure()`; throw `ArgumentError` for `length <= 0`. |
| 2 | collections/hyperloglog_utils.dart:71,73,89,139-153 | S2 | documented (web rewrite deferred) | 64-bit hash mixing (`* 0xbf58476d1ce4e5b9`), `hash >>> (64-precision)`, and `1 << r` (r up to 61) in `cardinality()`. Per Dart's number model, on web `int` is a 53-bit double and bitwise/shift ops truncate to 32-bit unsigned → wrong register index/rank; `1 << r` for r>30 becomes garbage/`0` → `1.0/(1<<r)` can divide by zero → `Infinity`/NaN estimate. Doc hedges "approximate" but never says "VM-only". | Document VM-only, OR rework to 32-bit-safe lanes. Empirical web run is closing step. |
| 3 | parsing/stable_hash_utils.dart:88-101 | S2/S3 | documented (web rewrite deferred) | FNV-1a 64-bit: `(hash ^ unit) * _fnvPrime` relies on VM 64-bit two's-complement wrap. On web the multiply overflows 53-bit precision and `& 0xFFFFFFFF` truncates to 32 bits → a VM-computed digest will NOT equal the web-computed digest for the same data. Doc claims the hash is "stable... on any platform" and "equal inputs always yield equal hashes across runs" — false across the VM/web boundary, defeating its stated use (cross-client cache keys / change detection / dedup). | Either document VM-only explicitly, or implement a web-safe 32-bit FNV-1a (mask each step to 32 bits, like rolling_hash mods by a 30-bit prime). |
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

## Themes still to verify (Phase 1 remainder)

- **1b asserts:** 40 `assert()` across 22 files — classify precondition (→throw) vs invariant (ok).
- **1d now():** 23 files call `DateTime.now()` directly — check single-instant capture & injectable clock.
- **1e–1h:** Unicode, numeric edge cases, boundaries, unsafe collection access.

Reference: web int semantics — https://dart.dev/resources/language/number-representation ;
dart2js 32-bit bitwise truncation — https://github.com/dart-lang/sdk/issues/8298
