# Full Codebase Review — saropa_dart_utils

Started 2026-06-13. Scope: every one of the 476 `lib/` files + 451 test files, all docs,
changelogs, plans, and historical archives. Goal: find subtle bugs, improve logic, elevate
code quality. No skipping large/similar files. Web research used to verify textbook algorithms.

## Context that shapes this review

- v1.6.0 (2026-06-12) already ran a "full-project correctness audit of all 476 files"
  (~40 algorithm/crash/concurrency fixes) and stamped every method `Audited: <date>`.
  **This review must find what that pass missed**, not repeat it. The audit stamp is a claim
  to be re-verified, not trusted.
- `dart analyze` is reported fully clean as of 1.6.1; lint is the floor, not the ceiling.
- The package targets Flutter (mobile + **web**). Web's int model (IEEE-754 doubles, 32-bit
  bitwise ops) is a first-class correctness surface, not an edge case.
- Recurring historical bug classes (from `plans/history/.../BUG-*.md`): grapheme-vs-code-unit
  vs rune, inclusive/exclusive boundaries, leap-year, modulo bias, O(n²) hot paths, null
  sentinel confusion, surrogate pairs, NaN/Infinity. These are the patterns to hunt.

## Size map (files per category)

string 78 · collections 64 · datetime 57 · parsing 37 · async 34 · stats 22 · iterable 22 ·
num 21 · graph 21 · map 17 · validation 13 · list 13 · url 11 · object 11 · niche 10 ·
caching 7 · int 5 · double 5 · json 4 · bool 3 · base64 3 · + 13 singletons. Total 476.
41 files exceed the project's 200-line "hard limit".

---

## Phase 0 — Baseline (gate everything else)

- [ ] Confirm `dart analyze` clean and full test suite green from a known commit (record counts).
      Run once as a baseline; thereafter scope analyze/test to touched files (per user rule).
- [ ] Record current pub.dev score inputs (deps freshness: jiffy Outdated, analyzer pinned 11
      vs 13 latest — verify intentional).

## Phase 1 — Cross-cutting systemic passes (highest bug yield, do FIRST)

Each is a single grep-seeded sweep across all of `lib/`. A finding here usually repeats across
many files, so catching the pattern once is worth more than a per-file read.

- [ ] **1a. Web/JS 64-bit int model.** Any code doing 64-bit hash mixing, `<< n` with n>30,
      `>>>` on values wider than 32 bits, or `* 0x<bignum>` produces wrong/garbage results under
      dart2js/dartdevc (ints are 53-bit doubles; bitwise ops truncate to 32 bits).
      Seed files: `collections/hyperloglog_utils.dart` (CONFIRMED suspect), `parsing/stable_hash_utils.dart`,
      `hex/hex_utils.dart`, `collections/rolling_hash_utils.dart`, `collections/bloom_filter_utils.dart`,
      `parsing/varint_utils.dart`, `niche/checksum_utils.dart`, `niche/hash_utils.dart`,
      Fenwick/segment trees. Decide per file: document "VM-only / not web-safe", or fix with
      `Uint32`-style masking / `BigInt`. This is the single most likely source of latent bugs.
- [ ] **1b. Release-stripped asserts.** 40 `assert()` across 22 files. For EACH: is it a
      precondition on caller-supplied input (must throw in release) or an internal invariant
      (OK as assert)? 1.6.0/1.6.1 converted only fenwick + rolling_correlation; the rest are
      unverified. Files: async/{bounded_work_queue,rate_limiter,resource_pool,sliding_window_rate_limiter,task_scheduler},
      collections/{interval_tree,bk_tree,time_decay_counter,timeseries_buffer,spatial_grid,segment_tree,multi_index_collection},
      datetime/{sla_calculator,rate_limit_schedule,quiet_hours,humanize_recurrence},
      caching/{size_limit,mru,lru}, stats/{gini,data_binning}.
- [ ] **1c. Randomness & security.** 9 files use bare `Random()`. Split into:
      (i) security-sensitive → must be `Random.secure()`: `validation/safe_temp_name_utils.dart`
      (CONFIRMED — predictable temp names + no `length<=0` guard), `niche/random_string_utils.dart`,
      `uuid/uuid_v4_utils.dart` (verify), `validation` token-ish helpers;
      (ii) statistical/reproducible → should accept an injectable seed: `sampling`, `reservoir_sampling`,
      `constrained_subset`, `seeded_shuffle`, `map_extensions` random pick. Verify each is the right kind.
- [ ] **1d. `DateTime.now()` race / testability.** 23 files. Check (i) multiple `now()` reads in
      one operation that should capture a single instant (TOCTOU/midnight-rollover races — see
      historical BUG-019), (ii) whether the file should accept the existing
      `datetime/injectable_clock_utils.dart` instead. Caching TTL files especially.
- [ ] **1e. Unicode correctness.** Every string length/slice/truncate/reverse/pad: confirm it
      uses the intended unit (grapheme cluster via `characters` vs rune vs code unit) and the
      dartdoc matches. History shows repeated regressions here (removeLastChar, truncateMiddle,
      `.last`, pluralize). Sweep all 78 `string/` files + string-ish parsing.
- [ ] **1f. Numeric edge cases.** NaN/Infinity propagation, integer division by zero, overflow
      in factorial/prime/pow, float `==` comparisons, `-0.0`, empty-input mean/variance/percentile.
      Sweep num/ (21), stats/ (22), double/ (5), int/ (5).
- [ ] **1g. Inclusive/exclusive boundaries.** Date ranges, intervals, `between`, clamp, time
      buckets, billing/fiscal/business-day edges. Historical BUG-001/005/025 all live here.
      Sweep datetime/ (57) + collections interval/scheduling files.
- [ ] **1h. Unsafe collection access.** `.first/.last/.single/[0]/[i]` where emptiness isn't
      proven inline (user's standing rule). 1.6.1 fixed skip_list only. Sweep all.

## Phase 2 — Per-category deep read (the no-skipping pass)

Read EVERY file + its mirror test. For algorithmic files, verify against an authoritative
reference via web lookup (cite it in FINDINGS). Check: correctness, doc-matches-behavior,
edge cases, complexity claims, the systemic themes from Phase 1. Order = highest risk first.

- [ ] **2.1 collections (64)** — algorithm-dense, highest bug surface. Verify each against
      canonical sources: HyperLogLog, Bloom filter, BK-tree, Fenwick/segment/interval trees,
      skip list, k-means, quickselect, reservoir sampling, stable matching (Gale-Shapley),
      knapsack, bin-packing, disjoint-set, LIS/LCS, Damerau-Levenshtein, HLL alpha constants.
- [ ] **2.2 graph (21)** — Dijkstra, A*, Floyd-Warshall, MST, topo-sort, bipartite, PageRank,
      critical path. Verify against references; check negative-weight handling, disconnected
      graphs, self-loops, cycle detection.
- [ ] **2.3 stats (22)** — correlation, regression, percentile/quantile, CUSUM, MAD outliers,
      confidence intervals, Gini. Verify formulas, empty/single-sample, n-1 vs n variance.
- [ ] **2.4 string (78)** — split across sub-batches; carries Phase-1e burden. Diff/Myers,
      soundex, levenshtein, fuzzy, ICU message, glob, html sanitizer (security!), tokenizers.
- [ ] **2.5 datetime (57)** — carries Phase-1d/1g burden. Hebrew converter, rrule, recurrence,
      fiscal/billing/business calendars, timezone, DST, leap years, intl display.
- [ ] **2.6 parsing (37)** — CSV (RFC 4180), INI, cron, semver, ISBN/Luhn checksums, JSON
      path/diff/schema, email/phone, expression evaluator (operator precedence, injection).
- [ ] **2.7 async (34)** — carries Phase-1b burden. Mutex/semaphore/rwlock fairness & permit
      races, circuit breaker, rate limiters, retry/backoff, cancellation, debounce/throttle,
      resource pool, stream operators. Concurrency correctness, leak-on-error, timer disposal.
- [ ] **2.8 num/int/double (31)** — carries Phase-1f burden.
- [ ] **2.9 iterable/list/map (52)** — null-sentinel correctness, lazy-vs-eager, mutation safety.
- [ ] **2.10 validation (13)** — password strength, JWT structure, IP/CIDR, PII detector,
      path validator (traversal!), data redaction. Security correctness.
- [ ] **2.11 url (11)** — canonicalize, build, encode, templates (RFC 3986), path join (BUG-fixed
      `pathRelative` — verify the fix and siblings).
- [ ] **2.12 remaining (object, niche, caching, base64, hex, html, json, uuid, regex, bool,
      enum, typed_data, testing, color, flutter, gesture, copy_with)** — full read each.

## Phase 3 — Docs, metadata, public API

- [ ] Barrel `saropa_dart_utils.dart` (531 lines) exports every public file; no leaks of `_`-libs.
- [ ] CAPABILITIES.md / CODE_INDEX.md / CODEBASE_INDEX.md accuracy vs actual API.
- [ ] README examples compile and are truthful; "280+" count vs reality.
- [ ] CHANGELOG accuracy (claims vs code), audit-stamp integrity (every method actually stamped?).
- [ ] example/ project builds.
- [ ] Stale/oversized artifacts in repo: `custom_lint.log` (6 MB), `nul`, `*.bak` analysis files,
      `reports/.trash` — flag for cleanup (do not delete without asking).

## Phase 4 — Test quality

- [ ] Coverage gaps: lib files without a mirror test; methods with no negative/edge case.
- [ ] Weak assertions (type-only, length-only), flaky patterns (real timers, unseeded random,
      wall-clock `now()`), over-DRY loops the testing rule forbids.
- [ ] 200-line / 20-line / 3-param "hard limits" — list violations; decide refactor vs accept.

## Phase 5 — Synthesis

- [ ] Consolidate FINDINGS into a severity-ranked bug list (crash > silent-wrong > doc > style).
- [ ] For each confirmed bug: minimal failing test + fix, signature-preserving where possible.
- [ ] Group fixes into atomic commits; update CHANGELOG per change.

## Working rules for this review

- Findings are CANDIDATES until the file is read and (for algorithms) checked against a cited
  reference. No "blocker/bug" claim without the artifact in hand.
- Record every finding in FINDINGS.md with: file:line, severity, evidence, proposed fix, status.
- Track per-category completion in PROGRESS.md.
- Fan-out is CPU-bound on this device for analyze/test — gate those once in synthesis, not per file.
