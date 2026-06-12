# Audit Pass 1 — stats, graph, num

A full-project correctness audit of the utility library examines each category for
algorithm accuracy, edge-case handling, documentation accuracy, non-crashing
behavior on invalid input, and useful nullable returns. The first pass covered the
three highest algorithmic-risk categories that ship math: `lib/stats` (22 files),
`lib/graph` (21 files), and `lib/num` (21 files). It surfaced three genuine graph
algorithm defects, one 64-bit integer defect, and several documentation claims that
contradicted the code. Every public method in these three categories now carries an
audit-date stamp in its doc header recording the review.

## Finish Report (2026-06-12)

This work will be reviewed by another AI.

### Scope

(A) Dart library code (`lib/`, `test/`). No Flutter UI, no extension, no scripts
shipped. l10n sections are out of scope: the package renders no user-facing strings
(it is a pure utility library).

### Deep Review

Files changed are limited to the three audited categories plus their tests and the
changelog. Logic was verified by reading each algorithm against its mathematical
definition and reconciling every behavior change with the existing test suite before
editing.

Core logic corrections:

- **`floydWarshall` multigraph seeding** — the initial distance matrix took the
  last edge weight for a given `(i, j)` (`dist[i][j] = w`). A multigraph with two
  edges between the same pair, or a positive self-loop, could overwrite a shorter
  distance or raise the diagonal above `0`. Now takes the minimum
  (`if (w < dist[i][j]) dist[i][j] = w`).
- **`dagSchedule` topology violation** — the previous form produced a full
  topological order and then sorted it by `priority`, which can move a dependency
  after its dependent and break the topology the doc promises. Rewritten as a
  priority-aware Kahn's algorithm: priority decides order only among nodes whose
  dependencies are all already emitted. Ties break on node index (Dart's
  `List.sort` is not stable), keeping the existing equal-priority test deterministic.
- **`douglasPeuckerIndices` perpendicular distance** — `_perpendicularDistance`
  divided the cross product by `n` (the squared chord length) instead of `sqrt(n)`
  (the length), returning distance/length rather than a distance, so `epsilon` was
  not a real tolerance. Now divides by `sqrt(n)`; the degenerate zero-length chord
  returns Euclidean `sqrt(px²+py²)` instead of Manhattan.
- **Graph crash-guards** — `dijkstraDistances`, `dijkstraWithParents`, `astar`,
  `bfs`, `dfs`, and `criticalPathDistances` indexed `[start]`/`[source]` before any
  bounds check, throwing `RangeError` on an empty graph or out-of-range node. Each
  now guards first and returns a sane empty/unreachable result; `astar` returns
  `null`, matching its existing no-path contract. This matches the guard pattern the
  newer graph files (`reachability_utils`, `multi_source_bfs_utils`,
  `path_enumeration_utils`) already use.
- **`nextPowerOfTwo` 64-bit** — the bit-smear stopped at `>> 16` (the 32-bit
  recipe), leaving inputs above 2³² with an unfilled high half and a wrong result.
  Added `v |= v >> 32`.
- **`lcm` overflow** — computed `a.abs() * b.abs()` before dividing by the GCD,
  which can overflow 64-bit. Reordered to `(a.abs() ~/ gcd) * b.abs()` for the same
  result with a smaller intermediate.

Documentation corrections (behavior unchanged):

- `outlierIndicesByMAD` claimed the "conventional modified z-score cutoff" but omits
  the 0.6745 Iglewicz-Hoaglin consistency constant. The doc now states it compares
  raw MAD-unit distance and gives the conversion (`3.5 / 0.6745 ≈ 5.19`) for callers
  who want the textbook modified-z behavior.
- `divideSafe` doc claimed it returns the default when the divisor is "0 or null";
  the divisor is a non-nullable `num`, so "or null" was impossible — removed.
- `NumUtils.generateIntList` doc claimed it "prints a warning debug message" on an
  invalid range; the code only returns `null` — claim removed.

### Testing Validation

Existing tests audited by reading each changed file's matching test before editing.
The three behavior-changing graph fixes were traced through every existing assertion:
the Douglas-Peucker suite uses extreme epsilons that pass under both the old and new
formula, and the `dagSchedule` priority tests only exercise edge-free graphs, so no
existing assertion encoded the defective behavior. All changes are therefore
strictly additive to the green suite.

New regression tests (6) pin the corrected behaviors and would fail against the old
code:

- `floyd_warshall_utils_test.dart` — parallel edges keep the minimum weight; a
  positive self-loop does not overwrite the diagonal `0`.
- `dag_scheduler_utils_test.dart` — topology wins when priority conflicts with a
  dependency edge; priority orders only nodes that are ready together.
- `line_simplify_utils_test.dart` — `epsilon` behaves as a true perpendicular
  distance (a point 5 units off a length-10 chord is kept at `epsilon = 2`).
- `num_more_extensions_test.dart` — `nextPowerOfTwo` handles 64-bit inputs above
  2³².

Commands run and results:

- `dart analyze lib/stats lib/graph lib/num test/stats test/graph test/num` → No
  issues found.
- `flutter test test/stats test/graph test/num` → 596 tests, all passed.

### Project Maintenance & Tracking

- CHANGELOG updated under `[Unreleased]` with the audit corrections.
- README verified — no updates needed (no public API surface changed; only internal
  behavior corrections and doc text).
- Version not bumped in this pass. The fixes are corrections to documented contracts
  (topology-respecting schedule, real-distance tolerance, non-overflowing results)
  rather than signature changes, so they are backward-compatible bug fixes. A later
  pass will decide whether any nullable-return improvements warrant a major bump.
- No bug archive — task did not close a `bugs/*.md` file.

### Known follow-ups (carried to later audit passes, not defects shipped here)

- `variance`/`standardDeviation` return `0` on empty input while sibling
  `median`/`percentile` in the same file return `null` — inconsistent undefined
  signaling (a nullable return would be a breaking change, deferred).
- `roundToSignificantDigits` uses `log`/`ln10` for the exponent, which can be off by
  one at exact powers of ten (floating-point precision).
- Integer square root is implemented twice (`num/math_utils.dart` private `_isqrt`
  and `num/num_more_extensions.dart` public `isqrt`) — a single source would be
  cleaner.
- `floydWarshall` does not detect negative cycles; `lowestCommonAncestor`/
  `treeDepths`/`criticalPathDistances` assume acyclic input and can loop on a cyclic
  parent array (documented preconditions).
