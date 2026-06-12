# Saropa Dart Utils — Roadmap to 700 (advanced ideas)

> **Status: forward-looking backlog — ready for work.**
> Every item in this file is **unbuilt remaining work**. Completed items (and the
> old done/total progress table) have been removed so the page shows only what is
> left to do. The list was reconciled against `lib/` on disk on **2026-06-11**
> (actual file existence, not the old "Done" column — several items the old column
> still showed as pending were already implemented and have been dropped). A few
> fuzzy matches were kept conservatively when it was not certain a file already
> covered them. Items are independent; pick any row.

**Purpose:** Follow‑on roadmap from 400 → 700, focused on **useful but more complex utilities only**. These are higher‑complexity algorithms, data structures, and helpers that many apps re‑implement badly or inconsistently.

All ideas must still respect **tree‑shaking**, **no global state**, and **small, composable files**, but we accept more logic per feature when it meaningfully replaces app‑level code.

<!-- cspell:disable -->

---

## ⚠️ Tree-shaking and complexity

This package **must** remain fully tree-shakeable even as complexity increases.

- **One feature per file (or a tight family).** Even for complex utilities, keep files focused.
- **Consumers import only what they use:**  
  `import 'package:saropa_dart_utils/collections/graph_shortest_path_utils.dart';`
- **No single “kitchen sink” barrel** that forces advanced features into apps that do not need them.
- **Pure functions, immutable results, and extension methods** wherever possible.
- **No heavy dependencies** (crypto, HTTP, JSON, etc.). These utilities should build on the Dart core libraries plus existing dependencies only.

---

## Legend

| Tag | Meaning |
|-----|--------|
| **Usefulness** | High = used in many apps; Medium = common in some domains; Low = niche but valuable |
| **Importance** | Critical = often duplicated badly; High = frequently reimplemented; Medium/Low = nice to have |
| **Complexity** | High = non-trivial algo/edge cases; Medium = moderate logic; Low = thin wrapper or simple logic |
| **Size** | ✅ = replaces common complex/algorithmic code in apps (reduces app size). |

In this roadmap, we bias strongly toward **High** complexity items that justify their footprint.

---

## Remaining by section

| Section | Remaining |
|---------|-----------|
| Advanced String & Text (401–440) | 1 |
| Advanced Collections & Algorithms (441–490) | 5 |
| Data Structures & Indexes (491–530) | 19 |
| Graphs & Pathfinding (531–560) | 7 |
| Statistics & Analytics (561–590) | 8 |
| Calendars, Recurrence & Scheduling (591–620) | 13 |
| Parsing & Formats, Structured Data (621–650) | 8 |
| Async, Concurrency & Streams (651–680) | 8 |
| Validation, Security & Robustness (681–700) | 4 |
| **Total remaining** | **73** |

---

## Advanced String & Text (401–440)

**Focus:** heavier text operations (diff, patch, tokenization, fuzzy search, structured templating) that are widely useful but non‑trivial to implement robustly.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 421 | Text fold by width with hanging indents and bullet awareness | Medium | Medium | High | ✅ |

---

## Advanced Collections & Algorithms (441–490)

**Focus:** heavier list/iterable algorithms, dynamic programming, optimization, and combinatorics used in scheduling, recommendation, and analytics.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 458 | External merge helper (merge many sorted chunks from disk‑sized lists) | Low | Medium | High | ✅ |
| 460 | Sliding window distinct count (using approximate structures) | Medium | Medium | High | ✅ |
| 478 | Sparse matrix helpers (CSR/CSC simple representation for 2D data) | Low | Medium | High | ✅ |
| 487 | Constraint satisfaction helper (variables, domains, simple backtracking solver) | Low | Medium | High | ✅ |
| 489 | Heuristic search helpers (best‑first / beam search utilities) | Low | Medium | High | ✅ |

---

## Data Structures & Indexes (491–530)

**Focus:** in‑memory data structures that solve common product problems (prefix search, ranges, caching, indexing) without external dependencies.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 492 | Compressed radix tree for string keys | Medium | Medium | High | ✅ |
| 497 | B‑tree/B+‑tree‑style structure for sorted in‑memory data (small scale) | Low | Medium | High | ✅ |
| 501 | Persistent immutable list/map wrappers with structural sharing (lightweight) | Medium | Medium | High | ✅ |
| 503 | Time‑ordered event store abstraction (append‑only, index by time and id) | Medium | Medium | High | ✅ |
| 504 | Partitioned map (sharded by hash/range for concurrency) | Medium | Medium | Medium | ✅ |
| 507 | LRU‑segmented cache (multi‑tier cache behavior) | Medium | Medium | High | ✅ |
| 512 | Keyed priority scheduler (e.g. job queue with priorities and tags) | Medium | Medium | High | ✅ |
| 513 | In‑memory “materialized view” index for list<Map<String, Object?>> | Medium | Medium | High | ✅ |
| 515 | Versioned map/list (keep small history of changes) | Low | Medium | High | ✅ |
| 516 | Snapshot + diff for large nested structures with path‑aware diffs | Medium | Medium | High | ✅ |
| 517 | Expression tree builder/evaluator for simple filter language | Medium | Medium | High | ✅ |
| 519 | Simple document store abstraction on top of Map+indexes | Medium | Medium | High | ✅ |
| 520 | Event log with compaction (merge old events into summarized snapshots) | Low | Low | High | ✅ |
| 521 | Lock‑free single‑producer/single‑consumer queue for streams (where applicable in Dart) | Low | Medium | High | ✅ |
| 522 | Conflict‑free replicated data type (CRDT) sketches for counters/sets | Low | Medium | High | ✅ |
| 524 | Simple rule engine representation (conditions + actions on objects) | Medium | Medium | High | ✅ |
| 526 | Partitioned ring buffers for multi‑tenant workloads | Low | Low | High | ✅ |
| 527 | On‑disk indexer abstraction (pluggable persistence, but logic in memory) | Low | Low | High | ✅ |
| 530 | Pattern‑indexed map (keys as patterns with fast matching lookup) | Low | Medium | High | ✅ |

---

## Graphs & Pathfinding (531–560)

**Focus:** graph utilities used in routing, dependency analysis, and recommendation systems.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 542 | Community detection (modularity‑based, small graphs) | Low | Low | High | ✅ |
| 544 | K‑shortest paths (Yen’s algorithm simplified) | Low | Low | High | ✅ |
| 548 | Geo‑adjacent clustering (group nodes by proximity in coordinate graph) | Low | Low | High | ✅ |
| 549 | Cycle basis enumeration for small graphs | Low | Low | High | ✅ |
| 552 | Simple route planner over weighted graph with constraints (avoid nodes/tags) | Low | Medium | High | ✅ |
| 559 | Heap‑based event simulation helpers (discrete‑event simulation core) | Low | Low | High | ✅ |
| 560 | Planarity and simple layout heuristics for small graphs (very basic) | Low | Low | High | ✅ |

---

## Statistics & Analytics (561–590)

**Focus:** analytic helpers, robust statistics, and forecasting primitives for dashboards and reporting.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 566 | Time series smoothing (Holt‑Winters‑lite) | Low | Medium | High | ✅ |
| 567 | Seasonality/period detection (autocorrelation heuristics) | Low | Low | High | ✅ |
| 578 | Timeseries alignment and resampling (different granularities) | Medium | Medium | High | ✅ |
| 579 | Cohort analysis utilities (group by start date, track over time) | Medium | Medium | High | ✅ |
| 582 | AB‑test metrics helpers (lift, p‑value approximations, sample sizing hints) | Medium | Medium | High | ✅ |
| 586 | Index/benchmark comparison utilities (relative to baseline series) | Low | Low | Medium | ✅ |
| 588 | Error bar/calibration helpers for forecasts | Low | Low | Medium | ✅ |
| 590 | Small in‑memory OLAP‑lite cube (multi‑dim group/aggregate cache) | Low | Medium | High | ✅ |

---

## Calendars, Recurrence & Scheduling (591–620)

**Focus:** advanced time and calendar logic beyond simple date math: recurrences, business rules, scheduling.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 594 | Multi‑timezone meeting finder (minimal overlap, candidate suggestions) | Low | Medium | High | ✅ |
| 596 | Calendar merge utilities (merge several calendars, conflict detection) | Medium | Medium | High | ✅ |
| 597 | Recurring event exceptions (skip/override particular instances) | Medium | Medium | High | ✅ |
| 598 | Next open/closed time helpers for stores (per weekly schedule and holidays) | Medium | Medium | High | ✅ |
| 601 | Sliding window schedule conflict detection across users | Medium | Medium | High | ✅ |
| 602 | Timezone‑safe “local day” utilities for recurring events | Medium | Medium | High | ✅ |
| 604 | Workload balancer (spread tasks across days given capacities) | Low | Medium | High | ✅ |
| 605 | Date rules engine (e.g. pay day rules, last business day, etc.) | Medium | Medium | High | ✅ |
| 607 | Vacation/leave period overlap resolution utilities | Medium | Medium | Medium | ✅ |
| 611 | Rolling window schedule generation (e.g. next 90 days of occurrences) | Medium | Medium | Medium | ✅ |
| 617 | SLO/SLI time window helpers (rolling windows, burn‑rate style) | Low | Low | High | ✅ |
| 619 | Multi‑calendar interop utilities (Gregorian / ISO weeks; hooks for others) | Low | Low | High | ✅ |
| 620 | Human‑friendly recurrence editor helpers (turn UI choices into RRULE objects) | Medium | Medium | High | ✅ |

---

## Parsing & Formats, Structured Data (621–650)

**Focus:** more complex parsers and format helpers that sit above core JSON/URI APIs.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 625 | YAML/JSON “dual” loader (accept either, normalize to Map) for config | Medium | High | Medium | ✅ |
| 627 | TOML‑lite parser (subset sufficient for most configs) | Low | Medium | High | ✅ |
| 638 | Diff/patch for tabular data (rows added/removed/changed) | Medium | Medium | High | ✅ |
| 640 | Structured log event model helpers (normalize level, timestamp, fields) | Medium | Medium | Medium | ✅ |
| 641 | CSV/JSON schema inference from samples | Low | Low | High | ✅ |
| 643 | Filter + projection language compiler for in‑memory queries | Low | Low | High | ✅ |
| 645 | “Secrets in config” detector (flags likely secret values) | Medium | Medium | High | ✅ |
| 650 | Data migration helpers (map from old schema to new with rules) | Medium | Medium | High | ✅ |

---

## Async, Concurrency & Streams (651–680)

**Focus:** higher‑level async patterns, coordination helpers, and stream utilities that many apps reinvent.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 658 | Bulkhead pattern (isolate resource pools, independent limits) | Low | Medium | High | ✅ |
| 659 | Async pipeline builder (stages with concurrency per stage) | Medium | Medium | High | ✅ |
| 663 | Stream retry/resubscribe with backoff | Medium | Medium | Medium | ✅ |
| 665 | Stream tee/branching utilities (fan‑out to multiple listeners) | Medium | Medium | Medium | ✅ |
| 672 | Saga‑style orchestrator primitives (steps with compensation functions) | Low | Medium | High | ✅ |
| 673 | Async retry with per‑error‑type strategies | Medium | Medium | High | ✅ |
| 678 | Stream reconciliation helper (compare two streams, emit diffs) | Low | Low | High | ✅ |
| 679 | Async “watchdog” utilities (restart tasks that stop unexpectedly) | Medium | Medium | High | ✅ |

---

## Validation, Security & Robustness (681–700)

**Focus:** higher‑stakes validation and robustness helpers that, while not cryptography libraries, help avoid common bugs and vulnerabilities.

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 689 | Signed URL helper (HMAC‑based signatures over path/query; crypto delegated to caller) | Low | Medium | High | ✅ |
| 690 | Request replay detection helpers (nonce + timestamp windows) | Low | Medium | High | ✅ |
| 698 | Security header suggestion helpers for web backends (non‑HTTP specific models) | Low | Medium | Medium | ✅ |
| 699 | Threat model checklist utilities (generate checklists for certain components) | Low | Low | Medium | ✅ |
