# Roadmap batch 2 — 10 advanced utilities

The `plans/ROADMAP_TO_700.md` backlog tracks higher-complexity utilities that
applications routinely reimplement badly. Ten of those items had no
implementation in `lib/`: range-query trees, approximate string search, a
spatial index, a down-sampling time-series buffer, async write-caches, an MRU
cache, graph chain-simplification, a graph text codec, calendar diffing, and a
rate-limit schedule shaper. Each was built as a standalone, tree-shakeable file
(one feature or tight family per file) with a deterministic test suite, then
exported from the package barrel.

A reconciliation finding surfaced during the work: roadmap rows #683 (normalized
error model) and #684 (error aggregation) were already implemented in
`lib/validation/validation_error_utils.dart` (`ValidationErrorUtils` +
`ValidationErrors`) but were still listed as remaining. Those two rows were
removed from the roadmap rather than rebuilt, and items #510 and #608 were built
in their place to keep the batch at ten.

## Finish Report (2026-06-12)

### Scope

(A) Dart library code — `lib/` and `test/` — plus (C) docs (`CHANGELOG.md`,
`plans/ROADMAP_TO_700.md`). No Flutter UI, no VS Code extension.

### What shipped

Ten new utility files under `lib/`, each with a matching `test/` suite (80 new
tests total), all exported from `lib/saropa_dart_utils.dart`:

| Roadmap | Symbol(s) | File |
|---------|-----------|------|
| #495 | `SegmentTree` (`.sum`/`.min`/`.max`) | `lib/collections/segment_tree_utils.dart` |
| #493 | `BkTree` | `lib/collections/bk_tree_utils.dart` |
| #506 | `SpatialGrid<T>` | `lib/collections/spatial_grid_utils.dart` |
| #510 | `TimeSeriesBuffer`, `TimeBucket`, `RawPoint` | `lib/collections/timeseries_buffer_utils.dart` |
| #508 | `WriteThroughStore<K,V>`, `WriteBackStore<K,V>`, `CacheLoader`, `CacheStorer` | `lib/caching/write_through_cache.dart` |
| #509 | `MruCache<K,V>` | `lib/caching/mru_cache.dart` |
| #545 | `simplifyDegree2Chains`, `SimplifiedGraph` | `lib/graph/graph_simplify_utils.dart` |
| #554 | `serializeAdjacency`, `parseAdjacency` | `lib/graph/graph_serialize_utils.dart` |
| #608 | `diffCalendars`, `CalendarEvent`, `CalendarChange`, `CalendarDiff` | `lib/datetime/calendar_diff_utils.dart` |
| #612 | `RateLimitSchedule` | `lib/datetime/rate_limit_schedule_utils.dart` |

### Core logic notes for review

- **SegmentTree** is an iterative (bottom-up) tree with leaves in `_tree[n..2n)`.
  The combine op (sum/min/max) must be associative and commutative because the
  range walk may merge left/right partials in either order; identities are `0`,
  `+inf`, `-inf` respectively so an empty merge never perturbs a result.
- **BkTree** prunes via the triangle inequality: for a query at distance `d`
  from a node, only children with edge label in `[d-k, d+k]` can hold a match.
  Default metric is `damerauLevenshteinDistance` (injectable). Inserts are
  set-semantic (distance-0 duplicate ignored). Search uses an explicit stack to
  avoid deep recursion.
- **SpatialGrid** buckets points by `(floor(x/cell), floor(y/cell))`. A radius
  query scans only cells overlapping the query's bounding box, then filters by
  true squared Euclidean distance, so points sharing a candidate cell but lying
  outside the circle are correctly excluded.
- **TimeSeriesBuffer** keeps the last N raw points verbatim; the oldest is
  evicted into a fixed-width bucket (`count`/`sum`/`min`/`max`/`mean`) once the
  raw window overflows. Assumes non-decreasing input timestamps (the oldest raw
  point is always the front of the list).
- **WriteThroughStore / WriteBackStore** add the WRITE direction that the
  pre-existing read-through `WriteThroughCache` (#523, `cache_interface.dart`)
  lacks — they were named `*Store` specifically to avoid the `WriteThroughCache`
  name clash. Write-through awaits `store` before updating the in-memory entry
  (a failed write leaves the cache unchanged); write-back buffers dirty keys and
  flushes them, coalescing repeated puts to one store call, snapshotting the
  dirty set so a concurrent put during the awaits is not lost.
- **MruCache** evicts the most-recently-used entry (correct for cyclic scans),
  tracked by a recency list whose tail is the eviction target; `frequencyOf`
  counts accesses while resident and resets on eviction/removal.
- **simplifyDegree2Chains** contracts maximal degree-2 chains into junction-to-
  junction edges. A `consumed` set tracks beads walked through; degree-2 nodes
  in anchorless pure cycles are never reached from a junction, so a second pass
  re-emits their original edges to avoid dropping connectivity. Self-loops and
  duplicate neighbors are normalized out via per-node neighbor sets.
- **serializeAdjacency / parseAdjacency** is a dependency-free text codec
  (`0>1,2;1;2>0`). Round-trip is loss-free because every node index appears
  explicitly (isolated trailing nodes survive) and neighbor order is preserved;
  malformed/negative integer tokens throw `FormatException`.
- **diffCalendars** pairs events by `id`; "changed" means same id but differing
  start, end, or title (`CalendarEvent.sameContentAs` excludes id from the
  content comparison). Duplicate ids within a snapshot follow map-insert (last
  wins).
- **RateLimitSchedule** shapes requested times to honor a rolling-window quota
  (max N per `period`) and a minimum `cooldown`, pushing an event forward to the
  earliest compliant instant rather than dropping it. The window-clear loop
  jumps to `oldest-in-window + period` to free a quota slot.

### Verification

- `flutter analyze` on all 10 lib files, 10 test files, and the barrel:
  **No issues found.** saropa_lints info/warning diagnostics surfaced during
  authoring were each resolved (null-assertion removal via captured locals,
  `firstWhereOrNull`, documented `ignore_for_file: require_cache_expiration` on
  the store wrappers matching the existing `lru_lfu_cache_utils` convention,
  parameter-reassignment fixes).
- New suites: **80 tests, all passing.** Each suite includes a brute-force
  oracle or property check where applicable (segment tree vs direct scan across
  updates; BK-tree vs linear scan under the same metric; spatial grid vs
  distance scan over a deterministic point cloud).
- Regression: `test/caching/cache_interface_test.dart` (the pre-existing #523
  `WriteThroughCache`) re-run after the rename and barrel change — **5 tests
  pass**, confirming no export ambiguity.

### Docs & tracking

- `CHANGELOG.md` Unreleased: overview updated (25 → 35 utilities) and a new
  "Roadmap batch 2 — 10 more advanced, tree-shakeable utilities (80 new tests)"
  block added under `### Added`.
- `plans/ROADMAP_TO_700.md` trimmed: the 10 built rows removed and the two stale
  already-built rows (#683, #684) removed. Section counts: Data Structures
  25→19, Graphs 9→7, Calendars 15→13, Validation 6→4; total remaining 85→73.
- README verified — no updates needed (no product facts changed; counts in
  README are approximate "280+" and not row-exact).
- `pubspec.yaml` unchanged — no dependency or version change
  (`package:collection`, already a dependency, is the only import added).
- No bug archive — task did not close a `bugs/*.md` file.

### Commits

- `feat(utils): add 10 advanced roadmap utilities (80 tests)` — the 10 lib + 10
  test files, barrel exports, CHANGELOG, and the 10-row roadmap trim.
- `docs(plans): drop already-built roadmap rows #683/#684 from ROADMAP_TO_700`
  — the stale-row cleanup.
- A third commit adds this finish report.
