# Roadmap batch — 25 advanced utilities (2026-06-12)

The `ROADMAP_TO_700.md` backlog tracked 110 unbuilt higher-complexity utilities
spanning order-statistic data structures, graph search, time-series analytics,
calendar/billing logic, structured-data parsing, and async coordination. Twenty-five
of those items were implemented as standalone, tree-shakeable files — one feature
(or tight family) per file — each with a full, deterministic test suite, and wired
into the public barrel. The roadmap's remaining-by-section counts and per-row entries
were updated to reflect the 25 closures (110 → 85 remaining).

## Finish Report (2026-06-12)

**Scope:** (A) Dart library code — `lib/` and `test/`. No Flutter UI, no extension, no l10n catalog (this package is a pure-Dart utility library with no `lib/l10n/`).

### What shipped

25 new utility files under `lib/`, each exported from `lib/saropa_dart_utils.dart`, each with a matching `test/` suite (276 new tests total):

Collections / data structures
- `collections/fenwick_tree_utils.dart` — `FenwickTree` (Binary Indexed Tree; O(log n) point update + prefix/range sum, roadmap #483)
- `collections/min_max_heap_utils.dart` — `MinMaxHeap<T>` (double-ended priority queue / min-max heap, #499)
- `collections/skip_list_utils.dart` — `SkipList<T>` (probabilistic ordered set with floor/ceiling, #502)
- `collections/similarity_dedup_utils.dart` — `clusterBySimilarity` / `dedupBySimilarity` (single-link near-dup clustering via union-find, #461)
- `collections/constrained_subset_utils.dart` — `weightedSubset` (Efraimidis–Spirakis weighted sampling without replacement, #476)
- `collections/session_clustering_utils.dart` — `clusterIntoSessions` / `sessionsWithBounds` (gap-based sessionization, #485)
- `collections/backtracking_utils.dart` — `BacktrackingSolver<State, Choice>` (generic pruned backtracking, #486)
- `collections/lazy_combinatorics_utils.dart` — `permutations` / `combinations` / `cartesianProduct` / `powerSet` (lazy `sync*` enumerators, #488)
- `collections/item_similarity_utils.dart` — `ItemSimilarityModel<T>` (co-occurrence Jaccard recommender, #490)

Graph
- `graph/multi_source_bfs_utils.dart` — `multiSourceBfsDistances` / `multiSourceBfsNearest` (#535)
- `graph/pagerank_utils.dart` — `pageRank` (power iteration with dangling-mass redistribution, #541)
- `graph/path_enumeration_utils.dart` — `enumeratePaths` (all simple paths, optional depth cap, #543)
- `graph/reachability_utils.dart` — `reachabilitySets` / `reachabilityMatrix` / `canReach` (transitive closure, #551)

Statistics
- `stats/change_point_cusum_utils.dart` — `cusumChangePoints` (two-sided CUSUM, #568)
- `stats/gini_utils.dart` — `giniCoefficient` (#573)
- `stats/rolling_correlation_utils.dart` — `rollingCorrelation` (windowed Pearson, #577)
- `stats/data_binning_utils.dart` — `binByWidth` / `quantileBoundaries` / `binByBoundaries` / `binCounts` (#585)

Date / time
- `datetime/billing_cycle_utils.dart` — `billingDateInMonth` / `nextBillingDate` / `billingSchedule` / `currentCycle` (end-of-month anchor clamping, #609)
- `datetime/humanize_recurrence_utils.dart` — `RecurrenceSpec` + `RecurrenceFrequency` + `humanizeRecurrence` (#599)
- `datetime/calendar_heatmap_utils.dart` — `dailyCounts` / `heatmapGrid` / `heatmapStats` (#603)
- `datetime/timeseries_gap_utils.dart` — `findGaps` / `fillMissing` / `forwardFill` (#606)

Parsing / async
- `parsing/http_header_parse_utils.dart` — `parseCacheControl` / `parseMaxAge` / `parseETag` / `parseRetryAfterSeconds` (#632)
- `parsing/stable_hash_utils.dart` — `stableHash` / `canonicalString` (FNV-1a structural checksum, #649)
- `parsing/flatten_explode_utils.dart` — `flattenMap` / `explode` (#648)
- `async/cancellation_token_utils.dart` — `CancellationToken` / `CancellationException` / `runCancellable` (#674)

### Verification

- `flutter analyze` on all 25 new lib files + the barrel: **0 issues**.
- `flutter test` (full suite): **8072 passing, 2 pre-existing skips**. The 25 new test files contribute 276 deterministic tests (seeded `Random` wherever randomness is involved; brute-force oracles where an algorithm admits one).
- `dart format` applied to all new files and the barrel.

### Defects found and fixed during the gate

Three test/implementation defects surfaced when the suite was run centrally and were corrected:

1. `stable_hash_utils.dart` rendered the FNV-1a result with `int.toRadixString(16)`, which emits a leading `-` for the (common) negative signed-64-bit value, producing a 17-character string. `int.toUnsigned(64)` is a no-op on a VM 64-bit int (the `1 << 64` mask wraps to `-1`), so it did not help. The fix renders the two 32-bit halves separately (`(hash >> 32) & 0xFFFFFFFF` and `hash & 0xFFFFFFFF`), each `padLeft(8, '0')`, yielding a stable unsigned 16-character lowercase hex on every platform.
2. `multi_source_bfs_utils_test.dart` asserted `multiSourceBfsDistances(g, [1]).first == 0`, but `.first` reads node 0 (which is unreachable from source node 1 across a directed edge `0 -> 1`, hence `-1`). The assertion was corrected to index the source node `[1]`. Implementation was correct.
3. `session_clustering_utils_test.dart` mapped result `DateTime`s back via `d.minute` (minute-of-hour, wraps at 60) to compare against an elapsed-minutes oracle. The mapping was corrected to `d.difference(at(0)).inMinutes`. Implementation was correct.

### House-style notes

- Every file opens with `/// <purpose> (roadmap #NNN).` + doc lines + `library;`, uses full explicit types, single quotes, trailing commas, dartdoc on every public symbol with `Example:` blocks on primary entry points, and WHY-comments above non-trivial blocks.
- Throwing collection accessors (`.first`/`.last`/`[0]`) are avoided in favor of guards or `firstOrNull`/`lastOrNull` per `saropa_lints`; input validation uses `assert` (in classes/initializer lists) or `ArgumentError` (in top-level functions) matching the surrounding rule set.
- Graph utilities reuse the existing `Adjacency` typedef from `graph/graph_utils.dart` rather than inventing a new representation.

### Not closing any bug/plan file

No bug archive — task did not close a `bugs/*.md` file. The roadmap (`plans/ROADMAP_TO_700.md`) is an open backlog, not a `PLAN_*.md`; it was edited in place (25 rows removed, section counts updated) and remains active with 85 items.
