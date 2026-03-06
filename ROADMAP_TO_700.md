# Saropa Dart Utils — Roadmap to 700 (advanced ideas)

**Purpose:** Follow‑on roadmap from 400 → 700, focused on **useful but more complex utilities only**. These are higher‑complexity algorithms, data structures, and helpers that many apps re‑implement badly or inconsistently.

All ideas must still respect **tree‑shaking**, **no global state**, and **small, composable files**, but we accept more logic per feature when it meaningfully replaces app‑level code.

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

## Roadmap progress (401–700)

| Section | Done | Total |
|---------|------|-------|
| Advanced String & Text (401–440) | 32 | 40 |
| Advanced Collections & Algorithms (441–490) | 39 | 50 |
| Data Structures & Indexes (491–530) | 11 | 40 |
| Graphs & Pathfinding (531–560) | 17 | 30 |
| Statistics & Analytics (561–590) | 18 | 30 |
| Calendars, Recurrence & Scheduling (591–620) | 5 | 30 |
| Parsing & Formats, Structured Data (621–650) | 8 | 30 |
| Async, Concurrency & Streams (651–680) | 18 | 30 |
| Validation, Security & Robustness (681–700) | 13 | 20 |
| **Total** | **161** | **300** |

---

## Advanced String & Text (40 ideas, 401–440)

**Focus:** heavier text operations (diff, patch, tokenization, fuzzy search, structured templating) that are widely useful but non‑trivial to implement robustly.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 401 | Myers diff for strings (minimal edit script with ops list) | High | High | High | ✅ | ✅ |
| 402 | Diff → colored/HTML/ANSI unified diff renderer | High | High | High | ✅ | ✅ |
| 403 | Apply patch (edit script) to string with validation and conflict detection | High | High | High | ✅ | ✅ |
| 404 | Tokenize text into sentences and words (locale‑aware, with abbreviations) | High | High | High | ✅ | ✅ |
| 405 | N‑gram generator for strings (character and word n‑grams) | High | High | Medium | ✅ | ✅ |
| 406 | Fuzzy search over list of strings (token + edit distance + ranking) | High | High | High | ✅ | ✅ |
| 407 | Simple search index over in‑memory documents (title/body, score by term frequency) | Medium | High | High | ✅ | ✅ |
| 408 | Text normalization pipeline (case, Unicode, punctuation, stopwords) with composable steps | High | High | High | ✅ | ✅ |
| 409 | Human name parser/normalizer (first/middle/last/suffix with locale‑aware rules) | High | High | High | ✅ | ✅ |
| 410 | Smart excerpt generator (best snippet around query terms with ellipsis) | High | High | High | ✅ | ✅ |
| 411 | Slug deduplicator (append incremental suffixes based on taken slugs) | High | High | Medium | ✅ | ✅ |
| 412 | Text folding/unfolding (wrap and unwrap while preserving quote markers, e.g. email replies) | Medium | Medium | High | ✅ | |
| 413 | Template engine with conditionals and loops (safe subset, no eval) | High | High | High | ✅ | ✅ |
| 414 | ICU‑style message formatting lite (pluralization, simple gender forms) | High | High | High | ✅ | |
| 415 | Diff of two paragraphs by sentences and words with structured result (for UIs) | High | High | High | ✅ | |
| 416 | Spelling‑tolerant key lookup (dictionary from canonical → variants) | Medium | Medium | High | ✅ | ✅ |
| 417 | Text fingerprinting (e.g. simhash/MinHash‑style signature) | Medium | Medium | High | ✅ | ✅ |
| 418 | Simplified “search query” parser (AND/OR, quotes, minus terms) | High | High | High | ✅ | ✅ |
| 419 | Markdown snippet extractor (extract heading sections, first code block, etc.) | Medium | Medium | Medium | ✅ | ✅ |
| 420 | Markdown to plain text summary (strip markup, keep lists/headings) | High | High | Medium | ✅ | ✅ |
| 421 | Text fold by width with hanging indents and bullet awareness | Medium | Medium | High | ✅ | |
| 422 | Code block detector/extractor from mixed text (Markdown, fenced, indented) | Medium | Medium | Medium | ✅ | ✅ |
| 423 | URL/link extractor with context (surrounding sentence, label) | High | High | Medium | ✅ | ✅ |
| 424 | Email reply quote stripper (remove previous threads, signatures heuristically) | Medium | High | High | ✅ | ✅ |
| 425 | Sensitive data scrubber (emails, phones, card numbers, SSNs) with pluggable patterns | High | Critical | High | ✅ | ✅ |
| 426 | Levenshtein automaton based “did you mean?” over dictionary | Medium | High | High | ✅ | ✅ |
| 427 | String compression helpers (DEFLATE/gzip wrapper for UTF‑8 text, with size thresholds) | Medium | Medium | Medium | ✅ | |
| 428 | Detect dominant language of short text (simple n‑gram profile) | Medium | Medium | High | ✅ | |
| 429 | Acronym/initialism extractor from document (e.g. “Saropa Dart Utils (SDU)”) | Medium | Medium | Medium | ✅ | ✅ |
| 430 | Text segmentation into “chunks” for indexing (by size and semantic boundaries) | High | High | High | ✅ | ✅ |
| 431 | Change log/semantic version section parser (extract version sections from text) | Medium | Medium | Medium | ✅ | |
| 432 | Keyphrase extractor (TF‑IDF over small corpus / doc) | Medium | Medium | High | ✅ | |
| 433 | Redline generator (track changes: who edited what and when, line‑based) | Medium | Medium | High | ✅ | |
| 434 | Customizable tokenizer pipeline (regex tokens with skip/keep rules) | High | High | High | ✅ | |
| 435 | CSV/TSV dialect detector (delimiter, quote char, header presence) | High | High | High | ✅ | |
| 436 | Pretty‑printer for nested JSON/YAML‑like text within strings (indent, sort keys) | High | High | Medium | ✅ | |
| 437 | Text similarity score (cosine similarity over TF vectors) | Medium | Medium | High | ✅ | ✅ |
| 438 | Duplicate document detector (near‑duplicate detection via fingerprints) | Medium | Medium | High | ✅ | ✅ |
| 439 | HTML sanitizer (allowlist tags/attributes, strip scripts/styles) | High | Critical | High | ✅ | ✅ |
| 440 | Safe HTML excerpt (truncate without breaking tags, keep basic formatting) | High | High | High | ✅ | ✅ |

---

## Advanced Collections & Algorithms (50 ideas, 441–490)

**Focus:** heavier list/iterable algorithms, dynamic programming, optimization, and combinatorics used in scheduling, recommendation, and analytics.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 441 | Longest increasing subsequence (LIS) with reconstruction | Medium | High | High | ✅ | ✅ |
| 442 | Longest common substring (not subsequence) for two lists/strings | Medium | High | High | ✅ | ✅ |
| 443 | Edit distance with transpositions (Damerau–Levenshtein) | Medium | High | High | ✅ | ✅ |
| 444 | Knapsack (0/1) solver for small item counts with reconstruction | Medium | High | High | ✅ | ✅ |
| 445 | Interval scheduling (max non‑overlapping intervals) | High | High | High | ✅ | ✅ |
| 446 | Weighted interval scheduling (max weight, DP) | Medium | High | High | ✅ | ✅ |
| 447 | Greedy set cover approximation (for recommendation/grouping) | Medium | High | High | ✅ | ✅ |
| 448 | Stable matching (Gale–Shapley) utilities | Medium | Medium | High | ✅ | |
| 449 | K‑means clustering on numeric vectors (small K, small N) | Medium | Medium | High | ✅ | ✅ |
| 450 | Hierarchical clustering (single/complete/average linkage) | Low | Medium | High | ✅ | |
| 451 | Sliding window aggregations (min/max/sum/avg over moving window) | High | High | High | ✅ | ✅ |
| 452 | Reservoir sampling for streaming data | High | High | High | ✅ | ✅ |
| 453 | Stream quantile/percentile estimation (e.g. P² algorithm or t‑digest‑lite) | Medium | High | High | ✅ | ✅ |
| 454 | Approximate distinct count (HyperLogLog‑lite) | Medium | Medium | High | ✅ | |
| 455 | Bloom filter with tunable false positive rate | Medium | High | High | ✅ | ✅ |
| 456 | In‑memory inverted index builder for small datasets | Medium | Medium | High | ✅ | ✅ |
| 457 | N‑way merge of multiple sorted iterables | High | High | Medium | ✅ | ✅ |
| 458 | External merge helper (merge many sorted chunks from disk‑sized lists) | Low | Medium | High | ✅ | |
| 459 | Top‑K by key via min‑heap utilities | High | High | Medium | ✅ | ✅ |
| 460 | Sliding window distinct count (using approximate structures) | Medium | Medium | High | ✅ | |
| 461 | Deduplicate by similarity (cluster near‑duplicates using similarity function) | Medium | Medium | High | ✅ | |
| 462 | Multi‑criteria sort helper with weighted comparators | Medium | Medium | Medium | ✅ | ✅ |
| 463 | Pareto frontier computation (dominance filtering in 2–3 dimensions) | Medium | Medium | High | ✅ | |
| 464 | Multi‑set utilities (bag union/intersection/difference) | Medium | High | Medium | ✅ | ✅ |
| 465 | Chunk + overlap windows (for streaming batch processing) | High | High | Medium | ✅ | ✅ |
| 466 | Online mean/variance for numeric streams | High | High | Medium | ✅ | ✅ |
| 467 | Outlier detection by MAD/Z‑score over iterable | Medium | Medium | High | ✅ | |
| 468 | Time‑bucketed aggregation (group events into fixed time buckets) | High | High | High | ✅ | ✅ |
| 469 | Pivot and unpivot utilities for tabular data (list of maps) | High | High | High | ✅ | ✅ |
| 470 | Columnar view of list<Map<String, Object?>> for analytics | High | High | Medium | ✅ | ✅ |
| 471 | Window functions (lag, lead, row_number, rank) over ordered data | High | High | High | ✅ | ✅ |
| 472 | Run detection (sequences of equal or increasing values with metadata) | Medium | Medium | Medium | ✅ | ✅ |
| 473 | Histogram builder with fixed and quantile‑based bins | High | High | Medium | ✅ | ✅ |
| 474 | Balanced partitioning (divide list into K partitions with similar sums) | Medium | High | High | ✅ | ✅ |
| 475 | Greedy bin packing helper (assign items to bins with capacities) | Medium | High | High | ✅ | ✅ |
| 476 | Random subset selection with constraints (weights, exclusion sets) | Medium | Medium | High | ✅ | |
| 477 | Multi‑key group/aggregate (group by several keys with aggregator functions) | High | High | High | ✅ | |
| 478 | Sparse matrix helpers (CSR/CSC simple representation for 2D data) | Low | Medium | High | ✅ | |
| 479 | Time‑decayed counters (weights decay exponentially over time) | Medium | Medium | High | ✅ | |
| 480 | LRU/LFU hybrid eviction policy utilities (beyond simple LRU/TTL) | Medium | Medium | High | ✅ | |
| 481 | Prefix frequency table builder (e.g. for autocomplete suggestions) | Medium | Medium | High | ✅ | ✅ |
| 482 | Rolling hash utilities (Rabin–Karp style) for substring search | Medium | Medium | High | ✅ | ✅ |
| 483 | Segment tree / Fenwick tree helpers for range queries | Low | Medium | High | ✅ | |
| 484 | Difference arrays for efficient range updates | Medium | Medium | Medium | ✅ | ✅ |
| 485 | Online clustering of timeseries points into sessions (gap‑based) | Medium | Medium | High | ✅ | |
| 486 | Generic backtracking framework with pruning and limits | Medium | Medium | High | ✅ | |
| 487 | Constraint satisfaction helper (variables, domains, simple backtracking solver) | Low | Medium | High | ✅ | |
| 488 | Turn key combinatorics utilities into lazily evaluated iterables | Medium | Medium | Medium | ✅ | |
| 489 | Heuristic search helpers (best‑first / beam search utilities) | Low | Medium | High | ✅ | |
| 490 | Simple recommendation utilities (co‑occurrence, item‑to‑item similarity matrix) | Medium | Medium | High | ✅ | |

---

## Data Structures & Indexes (40 ideas, 491–530)

**Focus:** in‑memory data structures that solve common product problems (prefix search, ranges, caching, indexing) without external dependencies.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 491 | Trie (prefix tree) with insert/delete/prefix search | High | High | High | ✅ | ✅ |
| 492 | Compressed radix tree for string keys | Medium | Medium | High | ✅ | |
| 493 | BK‑tree for approximate string matching | Medium | Medium | High | ✅ | |
| 494 | Interval tree for range overlap queries | Medium | High | High | ✅ | |
| 495 | Segment tree wrapper for range sum/min/max | Low | Medium | High | ✅ | |
| 496 | Disjoint‑set / union‑find with path compression | Medium | High | Medium | ✅ | ✅ |
| 497 | B‑tree/B+‑tree‑style structure for sorted in‑memory data (small scale) | Low | Medium | High | ✅ | |
| 498 | Indexed priority queue (support decrease‑key, remove arbitrary) | Medium | Medium | High | ✅ | ✅ |
| 499 | Double‑ended priority queue (min‑max heap) | Low | Medium | High | ✅ | |
| 500 | Ring buffer utilities (bounded queues with overwrite behavior) | High | High | Medium | ✅ | ✅ |
| 501 | Persistent immutable list/map wrappers with structural sharing (lightweight) | Medium | Medium | High | ✅ | |
| 502 | Skip list for ordered sets/maps | Low | Medium | High | ✅ | |
| 503 | Time‑ordered event store abstraction (append‑only, index by time and id) | Medium | Medium | High | ✅ | |
| 504 | Partitioned map (sharded by hash/range for concurrency) | Medium | Medium | Medium | ✅ | |
| 505 | Multi‑index collection (e.g. table that maintains several indexes) | Medium | High | High | ✅ | |
| 506 | Spatial index (grid/quadtree‑lite) for 2D points | Low | Medium | High | ✅ | |
| 507 | LRU‑segmented cache (multi‑tier cache behavior) | Medium | Medium | High | ✅ | |
| 508 | Write‑through/write‑back cache wrappers around async loaders | High | High | High | ✅ | |
| 509 | MRU cache and frequency tracking helpers | Medium | Medium | Medium | ✅ | |
| 510 | Time‑series buffer with down‑sampling (keep raw + aggregates) | Medium | Medium | High | ✅ | |
| 511 | Deduplicating set with expiry (remember‑seen recently, for idempotency) | High | High | Medium | ✅ | ✅ |
| 512 | Keyed priority scheduler (e.g. job queue with priorities and tags) | Medium | Medium | High | ✅ | |
| 513 | In‑memory “materialized view” index for list<Map<String, Object?>> | Medium | Medium | High | ✅ | |
| 514 | Bi‑directional map (Bijective map with checks) | Medium | Medium | Medium | ✅ | ✅ |
| 515 | Versioned map/list (keep small history of changes) | Low | Medium | High | ✅ | |
| 516 | Snapshot + diff for large nested structures with path‑aware diffs | Medium | Medium | High | ✅ | |
| 517 | Expression tree builder/evaluator for simple filter language | Medium | Medium | High | ✅ | |
| 518 | Memory‑conscious string pool (deduplicate many repeating strings) | Medium | Medium | Medium | ✅ | ✅ |
| 519 | Simple document store abstraction on top of Map+indexes | Medium | Medium | High | ✅ | |
| 520 | Event log with compaction (merge old events into summarized snapshots) | Low | Low | High | ✅ | |
| 521 | Lock‑free single‑producer/single‑consumer queue for streams (where applicable in Dart) | Low | Medium | High | ✅ | |
| 522 | Conflict‑free replicated data type (CRDT) sketches for counters/sets | Low | Medium | High | ✅ | |
| 523 | Generic cache interface + adapters (LRU, TTL, write‑through, etc.) | High | High | Medium | ✅ | |
| 524 | Simple rule engine representation (conditions + actions on objects) | Medium | Medium | High | ✅ | |
| 525 | Row‑oriented vs column‑oriented in‑memory table conversion | Medium | Medium | Medium | ✅ | ✅ |
| 526 | Partitioned ring buffers for multi‑tenant workloads | Low | Low | High | ✅ | |
| 527 | On‑disk indexer abstraction (pluggable persistence, but logic in memory) | Low | Low | High | ✅ | |
| 528 | Priority map (map keyed by priority → queues) | Medium | Medium | Medium | ✅ | ✅ |
| 529 | Deterministic pseudo‑random shuffler with reseedable state struct | Medium | Medium | Medium | ✅ | ✅ |
| 530 | Pattern‑indexed map (keys as patterns with fast matching lookup) | Low | Medium | High | ✅ | |

---

## Graphs & Pathfinding (30 ideas, 531–560)

**Focus:** graph utilities used in routing, dependency analysis, and recommendation systems.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 531 | Graph representation helpers (adjacency list/weighted edges) | Medium | High | Medium | ✅ | ✅ |
| 532 | BFS/DFS traversal with hooks (visit callbacks, depth limits) | Medium | High | Medium | ✅ | ✅ |
| 533 | Dijkstra shortest path on weighted graphs | Medium | High | High | ✅ | ✅ |
| 534 | A* shortest path with pluggable heuristic | Medium | Medium | High | ✅ | ✅ |
| 535 | Multi‑source shortest path utilities | Low | Medium | High | ✅ | |
| 536 | All‑pairs shortest paths for small graphs (Floyd–Warshall) | Low | Medium | High | ✅ | ✅ |
| 537 | Connected components and strongly connected components | Medium | High | High | ✅ | ✅ |
| 538 | Minimum spanning tree (Kruskal/Prim) helpers | Low | Medium | High | ✅ | ✅ |
| 539 | Topological sort with cycle detection (already basic; extend with metadata) | Medium | High | Medium | ✅ | ✅ |
| 540 | Dependency resolver with version constraints (acyclic) | Medium | High | High | ✅ | |
| 541 | Simple influence propagation / PageRank‑like scoring | Low | Medium | High | ✅ | |
| 542 | Community detection (modularity‑based, small graphs) | Low | Low | High | ✅ | |
| 543 | Path enumeration with constraints (max depth, unique nodes) | Low | Medium | High | ✅ | |
| 544 | K‑shortest paths (Yen’s algorithm simplified) | Low | Low | High | ✅ | |
| 545 | Graph simplification utilities (remove degree‑2 nodes, merge chains) | Low | Low | High | ✅ | |
| 546 | Bipartite graph checks and partitioning | Low | Medium | Medium | ✅ | ✅ |
| 547 | Line simplification for polylines (Douglas–Peucker) | Medium | Medium | High | ✅ | ✅ |
| 548 | Geo‑adjacent clustering (group nodes by proximity in coordinate graph) | Low | Low | High | ✅ | |
| 549 | Cycle basis enumeration for small graphs | Low | Low | High | ✅ | |
| 550 | Critical path analysis in DAGs (longest path) | Medium | Medium | High | ✅ | ✅ |
| 551 | Reachability matrix computation and caching | Low | Low | High | ✅ | |
| 552 | Simple route planner over weighted graph with constraints (avoid nodes/tags) | Low | Medium | High | ✅ | |
| 553 | Graph diff (added/removed nodes/edges, weight changes) | Medium | Medium | Medium | ✅ | ✅ |
| 554 | Graph serialization/deserialization helpers (compact text/JSON forms) | Medium | Medium | Medium | ✅ | |
| 555 | Tree utilities (LCA, subtree size, depth) | Medium | Medium | High | ✅ | ✅ |
| 556 | Hierarchy flattener (tree → ordered list with level metadata) | High | High | Medium | ✅ | ✅ |
| 557 | Hierarchy builder from flat list with parent ids | High | High | Medium | ✅ | ✅ |
| 558 | DAG‑based task scheduler (simple topological scheduling with priorities) | Medium | High | High | ✅ | ✅ |
| 559 | Heap‑based event simulation helpers (discrete‑event simulation core) | Low | Low | High | ✅ | |
| 560 | Planarity and simple layout heuristics for small graphs (very basic) | Low | Low | High | ✅ | |

---

## Statistics & Analytics (30 ideas, 561–590)

**Focus:** analytic helpers, robust statistics, and forecasting primitives for dashboards and reporting.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 561 | Robust statistics (median absolute deviation, trimmed mean) | High | High | Medium | ✅ | ✅ |
| 562 | Confidence intervals for mean (normal approximation, t‑distribution) | Medium | Medium | High | ✅ | ✅ |
| 563 | Correlation coefficients (Pearson, Spearman) | Medium | Medium | High | ✅ | ✅ |
| 564 | Linear regression (simple and multiple) with diagnostics | Medium | Medium | High | ✅ | ✅ |
| 565 | Moving averages (simple, exponential, weighted) | High | High | Medium | ✅ | ✅ |
| 566 | Time series smoothing (Holt‑Winters‑lite) | Low | Medium | High | ✅ | |
| 567 | Seasonality/period detection (autocorrelation heuristics) | Low | Low | High | ✅ | |
| 568 | Change‑point detection (CUSUM‑style) | Low | Low | High | ✅ | |
| 569 | Anomaly detection in time series (threshold + residual heuristics) | Medium | Medium | High | ✅ | ✅ |
| 570 | Bucketed aggregation with multiple aggregators (sum/count/avg/min/max) | High | High | Medium | ✅ | ✅ |
| 571 | Grouped statistics helpers (per key aggregates over iterable) | High | High | Medium | ✅ | |
| 572 | Quantile summary object (pre‑compute percentiles, median, quartiles) | Medium | High | Medium | ✅ | ✅ |
| 573 | Gini coefficient / inequality metrics | Low | Low | High | ✅ | |
| 574 | Histogram + CDF builder for numeric samples | High | High | Medium | ✅ | |
| 575 | Log/exp transformations helpers (for log‑scale analytics) | Medium | Medium | Low | ✅ | ✅ |
| 576 | Data normalization (z‑score, min‑max scaling) | High | High | Medium | ✅ | ✅ |
| 577 | Rolling correlation between two time series | Low | Medium | High | ✅ | |
| 578 | Timeseries alignment and resampling (different granularities) | Medium | Medium | High | ✅ | |
| 579 | Cohort analysis utilities (group by start date, track over time) | Medium | Medium | High | ✅ | |
| 580 | Funnel analysis (drop‑off between ordered steps) | Medium | Medium | Medium | ✅ | ✅ |
| 581 | Retention curves (N‑day, week, month retention) | Medium | Medium | High | ✅ | ✅ |
| 582 | AB‑test metrics helpers (lift, p‑value approximations, sample sizing hints) | Medium | Medium | High | ✅ | |
| 583 | Percentile rank and inverse percentile utilities | Medium | Medium | Medium | ✅ | ✅ |
| 584 | Sampling helpers (stratified, systematic sampling) | Medium | Medium | Medium | ✅ | ✅ |
| 585 | Data binning by custom boundaries (quantile, equal‑width, domain‑specific) | Medium | Medium | Medium | ✅ | |
| 586 | Index/benchmark comparison utilities (relative to baseline series) | Low | Low | Medium | ✅ | |
| 587 | Metric roll‑up helpers (daily → weekly → monthly) | High | High | Medium | ✅ | ✅ |
| 588 | Error bar/calibration helpers for forecasts | Low | Low | Medium | ✅ | |
| 589 | Feature scaling/encoding utilities (bucketization, one‑hot encoding) | Medium | Medium | Medium | ✅ | ✅ |
| 590 | Small in‑memory OLAP‑lite cube (multi‑dim group/aggregate cache) | Low | Medium | High | ✅ | |

---

## Calendars, Recurrence & Scheduling (30 ideas, 591–620)

**Focus:** advanced time and calendar logic beyond simple date math: recurrences, business rules, scheduling.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 591 | RFC 5545‑style recurrence rule parser (subset of RRULE) | Medium | High | High | ✅ | |
| 592 | Recurrence iterator (generate next N occurrences from RRULE‑like object) | Medium | High | High | ✅ | |
| 593 | Business calendar abstraction (workdays, custom holidays, half‑days) | Medium | High | High | ✅ | |
| 594 | Multi‑timezone meeting finder (minimal overlap, candidate suggestions) | Low | Medium | High | ✅ | |
| 595 | SLA calculators (resolve due dates given business hours + holidays) | Medium | High | High | ✅ | |
| 596 | Calendar merge utilities (merge several calendars, conflict detection) | Medium | Medium | High | ✅ | |
| 597 | Recurring event exceptions (skip/override particular instances) | Medium | Medium | High | ✅ | |
| 598 | Next open/closed time helpers for stores (per weekly schedule and holidays) | Medium | Medium | High | ✅ | |
| 599 | Humanized recurrence description (“every 2nd Tuesday”) | Medium | Medium | Medium | ✅ | |
| 600 | Flexible time rounding (nearest 5/10/15 minutes, ceiling/floor) | High | High | Medium | ✅ | ✅ |
| 601 | Sliding window schedule conflict detection across users | Medium | Medium | High | ✅ | |
| 602 | Timezone‑safe “local day” utilities for recurring events | Medium | Medium | High | ✅ | |
| 603 | Calendar heatmap data generator (counts per day/week) | Medium | Medium | Medium | ✅ | |
| 604 | Workload balancer (spread tasks across days given capacities) | Low | Medium | High | ✅ | |
| 605 | Date rules engine (e.g. pay day rules, last business day, etc.) | Medium | Medium | High | ✅ | |
| 606 | Time series gap detector/filler (find missing samples and fill strategies) | Medium | Medium | High | ✅ | |
| 607 | Vacation/leave period overlap resolution utilities | Medium | Medium | Medium | ✅ | |
| 608 | Calendar diff (added/removed/changed events) | Medium | Medium | Medium | ✅ | |
| 609 | Monthly billing cycle helper (anniversary dates, edge cases) | Medium | High | Medium | ✅ | |
| 610 | Period splitting helpers (split by month/week/business week) | High | High | Medium | ✅ | ✅ |
| 611 | Rolling window schedule generation (e.g. next 90 days of occurrences) | Medium | Medium | Medium | ✅ | |
| 612 | Rate limiting schedule (max N events per period with cooldowns) | Medium | High | High | ✅ | |
| 613 | “Quiet hours” helpers (mute notifications during configured times) | Medium | Medium | Medium | ✅ | |
| 614 | Globally consistent “now” abstraction with injectible clock (for tests) | High | High | Medium | ✅ | ✅ |
| 615 | Localized date formatting presets for dashboards (short/medium/long) | High | High | Medium | ✅ | |
| 616 | Relative date bucketing (“today”, “yesterday”, “last 7 days”, etc.) | High | High | Medium | ✅ | ✅ |
| 617 | SLO/SLI time window helpers (rolling windows, burn‑rate style) | Low | Low | High | ✅ | |
| 618 | Timebox helpers (measure execution within given time budget) | Medium | Medium | Medium | ✅ | ✅ |
| 619 | Multi‑calendar interop utilities (Gregorian / ISO weeks; hooks for others) | Low | Low | High | ✅ | |
| 620 | Human‑friendly recurrence editor helpers (turn UI choices into RRULE objects) | Medium | Medium | High | ✅ | |

---

## Parsing & Formats, Structured Data (30 ideas, 621–650)

**Focus:** more complex parsers and format helpers that sit above core JSON/URI APIs.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 621 | Robust CSV parser with streaming, quoting, escaping, and large file support | High | High | High | ✅ | ✅ |
| 622 | CSV writer with configurable dialects and auto‑quoting | High | High | Medium | ✅ | |
| 623 | Simple JSONPath‑like query helper (subset of JSONPath) | Medium | High | High | ✅ | |
| 624 | JSON diff/patch generator and applier | High | High | High | ✅ | ✅ |
| 625 | YAML/JSON “dual” loader (accept either, normalize to Map) for config | Medium | High | Medium | ✅ | |
| 626 | INI/“.env” parser with sections, includes, and overrides | Medium | High | Medium | ✅ | |
| 627 | TOML‑lite parser (subset sufficient for most configs) | Low | Medium | High | ✅ | |
| 628 | Query string / form body parser that supports nested keys (a[b][c]) | High | High | Medium | ✅ | ✅ |
| 629 | URL template expansion (RFC 6570 subset) | Medium | Medium | High | ✅ | |
| 630 | URI pattern matcher (path templates with typed params) | High | High | Medium | ✅ | |
| 631 | Log line parsers (Apache, nginx, custom patterns via templates) | Medium | Medium | High | ✅ | |
| 632 | HTTP header parsing helpers (ETag, Cache‑Control, etc., without HTTP dep) | Medium | Medium | Medium | ✅ | |
| 633 | Simple SQL‑like filter expression parser for in‑memory filtering | Medium | Medium | High | ✅ | |
| 634 | Expression evaluator with safe sandbox for arithmetic/boolean ops | Medium | Medium | High | ✅ | |
| 635 | Binary data encoding helpers (base32, crockford, varints) | Medium | Medium | Medium | ✅ | ✅ |
| 636 | Schema validation for JSON‑like data (type checks, required, enums) | Medium | High | High | ✅ | |
| 637 | Mapping arbitrary JSON to typed models with validation errors | High | High | High | ✅ | |
| 638 | Diff/patch for tabular data (rows added/removed/changed) | Medium | Medium | High | ✅ | |
| 639 | Canonicalization helpers (sort keys, normalize numbers/booleans) | Medium | Medium | Medium | ✅ | ✅ |
| 640 | Structured log event model helpers (normalize level, timestamp, fields) | Medium | Medium | Medium | ✅ | |
| 641 | CSV/JSON schema inference from samples | Low | Low | High | ✅ | |
| 642 | Basic Protobuf‑like varint wire decoding (not full proto) | Low | Low | High | ✅ | |
| 643 | Filter + projection language compiler for in‑memory queries | Low | Low | High | ✅ | |
| 644 | Config precedence resolver (defaults → env → file → CLI) | High | High | Medium | ✅ | ✅ |
| 645 | “Secrets in config” detector (flags likely secret values) | Medium | Medium | High | ✅ | |
| 646 | ISO‑8601 interval parser and formatter (start/end/duration forms) | Medium | Medium | High | ✅ | |
| 647 | Rich error reporting for parsers (line/column, caret hints, context) | High | High | Medium | ✅ | ✅ |
| 648 | CSV/JSON normalizer for BI tools (flatten nested objects, explode arrays) | Low | Medium | High | ✅ | |
| 649 | Checksum and hash helpers for structured data (stable field ordering) | Medium | Medium | Medium | ✅ | |
| 650 | Data migration helpers (map from old schema to new with rules) | Medium | Medium | High | ✅ | |

---

## Async, Concurrency & Streams (30 ideas, 651–680)

**Focus:** higher‑level async patterns, coordination helpers, and stream utilities that many apps reinvent.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 651 | Async semaphore with permits and timeout | High | High | Medium | ✅ | ✅ |
| 652 | Async mutex with tryLock and timeout | High | High | Medium | ✅ | ✅ |
| 653 | Read/write lock abstraction (prioritizing writers/readers) | Low | Medium | High | ✅ | |
| 654 | Bounded work queue with backpressure (async producer/consumer) | Medium | High | High | ✅ | |
| 655 | Task scheduler with priority and concurrency limit | Medium | High | High | ✅ | |
| 656 | Retry policy DSL (fixed, backoff, jitter, circuit breaker states) | High | High | High | ✅ | ✅ |
| 657 | Circuit breaker implementation (open/half‑open/closed with metrics) | Medium | High | High | ✅ | ✅ |
| 658 | Bulkhead pattern (isolate resource pools, independent limits) | Low | Medium | High | ✅ | |
| 659 | Async pipeline builder (stages with concurrency per stage) | Medium | Medium | High | ✅ | |
| 660 | Stream windowing utilities (time‑ and count‑based windows) | High | High | Medium | ✅ | ✅ |
| 661 | Stream join/zip/combineLatest operators | High | High | Medium | ✅ | |
| 662 | Stream debouncing/throttling with trailing/leading options | High | High | Medium | ✅ | |
| 663 | Stream retry/resubscribe with backoff | Medium | Medium | Medium | ✅ | |
| 664 | Stream buffering operators (bufferUntil, bufferCount, bufferTime) | High | High | Medium | ✅ | ✅ |
| 665 | Stream tee/branching utilities (fan‑out to multiple listeners) | Medium | Medium | Medium | ✅ | |
| 666 | Async resource pool (e.g. DB connections, HTTP clients) | Medium | High | High | ✅ | |
| 667 | “Race with cancellation” helper (first success wins, cancel rest) | Medium | High | Medium | ✅ | ✅ |
| 668 | Idempotent async operation wrappers (deduplicate concurrent calls) | Medium | High | High | ✅ | ✅ |
| 669 | Async timeout policies with fallbacks and cancellation hooks | High | High | Medium | ✅ | ✅ |
| 670 | Stream‑based rate limiter (token bucket/leaky bucket) | Medium | High | High | ✅ | |
| 671 | Batch/flush helpers (collect events and flush on size/time conditions) | High | High | Medium | ✅ | ✅ |
| 672 | Saga‑style orchestrator primitives (steps with compensation functions) | Low | Medium | High | ✅ | |
| 673 | Async retry with per‑error‑type strategies | Medium | Medium | High | ✅ | |
| 674 | Cancellable computations abstraction (cooperative cancellation tokens) | Medium | Medium | High | ✅ | |
| 675 | Heartbeat/keepalive utilities for long‑running tasks | Medium | Medium | Medium | ✅ | ✅ |
| 676 | Async barrier/latch primitives (wait for N events) | Medium | Medium | Medium | ✅ | ✅ |
| 677 | Exponential backoff helper shared across HTTP and other APIs | High | High | Medium | ✅ | ✅ |
| 678 | Stream reconciliation helper (compare two streams, emit diffs) | Low | Low | High | ✅ | |
| 679 | Async “watchdog” utilities (restart tasks that stop unexpectedly) | Medium | Medium | High | ✅ | |
| 680 | Observability helpers (wrap async ops with timing, logging hooks) | High | High | Medium | ✅ | |

---

## Validation, Security & Robustness (20 ideas, 681–700)

**Focus:** higher‑stakes validation and robustness helpers that, while not cryptography libraries, help avoid common bugs and vulnerabilities.

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 681 | Declarative validation DSL for objects (rules, messages, nested paths) | High | High | High | ✅ | ✅ |
| 682 | Cross‑field validation helpers (e.g. start < end, one‑of fields required) | High | High | Medium | ✅ | ✅ |
| 683 | Normalized error model (code, message, details, cause) with mappers | High | High | Medium | ✅ | |
| 684 | Error aggregation helpers (collect multiple validation errors) | High | High | Medium | ✅ | |
| 685 | Rate‑limit helper (sliding window counter with storage abstraction) | Medium | High | High | ✅ | |
| 686 | IP/network utilities (CIDR parsing, subnet contains, range checks) | Medium | Medium | High | ✅ | ✅ |
| 687 | Password strength estimation (entropy heuristics, blacklist words) | Medium | High | High | ✅ | ✅ |
| 688 | Token format validators (JWT structural checks without crypto) | Medium | Medium | Medium | ✅ | ✅ |
| 689 | Signed URL helper (HMAC‑based signatures over path/query; crypto delegated to caller) | Low | Medium | High | ✅ | |
| 690 | Request replay detection helpers (nonce + timestamp windows) | Low | Medium | High | ✅ | |
| 691 | PII detector for free‑form text (emails, phones, IDs) | Medium | Medium | High | ✅ | ✅ |
| 692 | Data redaction policies (masking rules per field path) | High | High | High | ✅ | ✅ |
| 693 | Robust file path validators (prevent traversal, normalize roots) | High | Critical | Medium | ✅ | ✅ |
| 694 | Safe temp‑file naming helpers (randomized, collision‑resistant IDs) | Medium | Medium | Medium | ✅ | ✅ |
| 695 | Safe parsing wrappers (no‑throw, rich error objects, logging hooks) | High | High | Medium | ✅ | ✅ |
| 696 | Input shaping helpers (clamp/normalize numbers, trim/limit strings, sanitize) | High | High | Medium | ✅ | ✅ |
| 697 | Typed “non empty”/“positive” wrappers with runtime validation helpers | Medium | Medium | Medium | ✅ | ✅ |
| 698 | Security header suggestion helpers for web backends (non‑HTTP specific models) | Low | Medium | Medium | ✅ | |
| 699 | Threat model checklist utilities (generate checklists for certain components) | Low | Low | Medium | ✅ | |
| 700 | Defensive coding helpers (guard patterns, invariant checkers) | High | High | Medium | ✅ | ✅ |

