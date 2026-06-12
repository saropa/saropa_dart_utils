# Full-Project Audit — Summary (all 476 lib files)

A complete correctness audit of the utility library examined every source file
in `lib/` (476 files, ~37.5k LOC across 33 categories) against six criteria:
algorithm accuracy, unit-test coverage, edge-case handling, documentation
accuracy, non-crashing behavior on invalid input (sanitize/return rather than
throw), and useful nullable returns over misleading zero/empty defaults. Every
public method now carries a per-method audit-date stamp (`/// Audited:
2026-06-12 ...`) recording the review — 1780 stamps across 466 files (the
remaining 10 files are data/enum/barrel files with no callable methods).

## Finish Report (2026-06-12)

This work will be reviewed by another AI.

### Scope

(A) Dart library code (`lib/`, `test/`). Pure utility package — no Flutter UI,
no extension, no shipped scripts; l10n out of scope. Delivered across seven
commits (audit passes 1–7), each scoped to a category group, each with its own
green analyze + test gate.

### Outcome

- **Full test suite: 8190 passing** (2 pre-existing skips), `dart analyze lib
  test` clean.
- **~40 genuine defects fixed** (correctness, crashes, hangs, security), plus
  ~30 documentation-accuracy corrections.
- **40 new regression tests** that fail/hang against the pre-audit code.
- No public method signature was changed; all fixes preserve the existing API
  (behavior corrections align code with documented contracts), so the changes
  are backward-compatible bug fixes rather than a breaking release.

### Defects fixed, by class

Correctness / algorithm (highest impact):
- `floydWarshall` multigraph/self-loop min-seeding; `dagSchedule`
  topology-respecting priority (priority-aware Kahn); `douglasPeucker`
  perpendicular-distance divisor; `nextPowerOfTwo` 64-bit bit-smear; `lcm`
  overflow ordering; `kmeans2D` maximin seeding (was collapsing to ≤2 clusters);
  `BloomFilter` ln sizing; `bucketByTime`/`TimeSeriesBuffer` negative-epoch
  flooring; ISO `parseIsoWeekString` week-53 over-acceptance; `isAnnualDateInRange`
  Feb-29 rollover; DST/calendar-field fixes in `heatmapGrid`, `dayOfYear`/
  `numOfWeeks`, `getNthWeekdayOfMonthInYear`, `splitByMonth`; `SemverUtils`
  §11 pre-release ordering; varint negative/large round-trip; `parseHexColor`
  embedded-non-hex rejection; `parseChangelogSections` grapheme/code-unit offset;
  Soundex vowel adjacency; `substituteTemplate` double-substitution;
  `markdownToPlainText` image syntax; `mapDiff` null-value reporting;
  `lastWhereOrElse`/`runLengthEncode` nullable-T sentinels; `truncateToByteLength`
  non-BMP byte count; `unflattenKeys`/`setNested` collision leak; `jwtPayload`
  base64 padding + UTF-8 decode.

Crashes / hangs guarded (no longer throw / spin on invalid input):
- Graph `dijkstra`/`astar`/`bfs`/`dfs`/`criticalPath` empty/out-of-range guards;
  `expandRecurrence` impossible-rule bound; `fillMissing` zero-interval;
  `chunkText` overlap ≥ maxChars; async `mapBatched`, `raceFirst` empty,
  `retryWithJitter` zero-jitter, `bufferCount`/`windowCount` count;
  `parseQueryString` malformed percent-escape; `takeLast`/`randomAlphanumeric`/
  `getRandomListExcept`/`shapeString`/`formatPrecision` guards; difference-array
  reversed range; time-bucket zero width.

Concurrency:
- `AsyncSemaphoreUtils` permit double-counting race (admitted two holders under a
  one-permit gate) — `release` now hands the permit directly to a waiter without
  returning it to the pool.

Documentation accuracy:
- ~30 corrections where dartdoc claimed behavior the code did not implement
  (wrong example outputs, false "prints a warning"/"simhash"/"half-open"/
  "conditionals"/"partial sort" claims, misdescribed Unicode handling, sentinel
  vs nullable wording). `CircuitBreakerUtils`, `memoizeFuture`, `compareVersions`,
  `toBoolJson`, `String.reversed`, `textFingerprint`, and others now describe
  their real contracts.

### Verification discipline

Each category was first swept by parallel read-only audit agents, then EVERY
flagged defect was re-verified against the source and reconciled with the
existing tests before any edit. Verification overturned several agent reports —
e.g. a "sensitive-scrub un-grouped card not masked" claim (false: the card regex
matches `\b\d{16}\b`), a "bloom 24% mis-size" (actually ~2%), and a "toBoolJson
returns false is a bug" (the false-default is tested/intended; the doc was the
defect). Where a behavior change was warranted, the matching tests were updated
to pin the corrected contract.

### Known follow-ups (flagged, not changed)

These are documented limitations or breaking-change candidates deferred for a
separate decision:
- Several string helpers index by UTF-16 code unit where graphemes are intended
  (`getRandomChar`, `breakLongWords`, `wordWrap`, `parseKeyValuePairs`,
  `redactPhone` char split, `wildcardMatch`) — corrupt astral input; many are
  documented as ASCII-oriented.
- `PriorityMapUtils` honors priority by insertion order, not key value; true
  value-ordering needs a `Comparable` bound + `SplayTreeMap` (breaking).
- `textFingerprint` uses `String.hashCode` (not guaranteed portable); a content
  hash is needed for persisted fingerprints.
- `tokenizeSentences` mis-splits on abbreviations; `language_detect` has two
  malformed 4-char trigram-profile entries; `histogramQuantile` degenerates on
  heavily-duplicated data; `natural_sort` mixes int/string compare for numeric
  runs above 2^63.
- Several stats `double` returns use `NaN`-on-undefined (house convention);
  `variance`/`stdDev` return `0` on empty while `median`/`percentile` return
  `null` (inconsistent). Converting these to nullable would be a breaking change.

### Persisted records

This summary plus three per-pass reports live under
`plans/history/2026.06/2026.06.12/`:
`audit-pass-1-stats-graph-num.md`,
`audit-pass-2-collections-datetime.md`,
`audit-pass-3-async-parsing-string.md`, and this file. The CHANGELOG `[Unreleased]`
section documents every fix per category.
