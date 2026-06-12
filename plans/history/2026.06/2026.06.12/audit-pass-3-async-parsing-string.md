# Audit Pass 4–5 — async, parsing, string

Continuing the full-project correctness audit, the `lib/async` (34 files),
`lib/parsing` (37 files), and `lib/string` (78 files) categories were examined
for algorithm accuracy, concurrency safety, crash/hang-on-invalid-input,
documentation accuracy, and Unicode handling. The pass found a permit-handling
race in the async semaphore, several process-hang guards, a set of parsing
correctness bugs (semver ordering, varint round-trip, hex-color validation), and
string algorithm bugs (Soundex vowel handling, template re-substitution). Every
public method in all three categories now carries an audit-date stamp.

## Finish Report (2026-06-12)

This work will be reviewed by another AI.

### Scope

(A) Dart library code (`lib/`, `test/`). No Flutter UI, no extension, no shipped
scripts. l10n out of scope (pure utility library).

### Method

Each category was swept by parallel read-only audit agents, then every flagged
defect was re-verified against the actual code and reconciled with the existing
test suite before editing. Verification overturned several agent reports: a
sensitive-data scrubber "un-grouped card not masked" claim was false (the card
regex's separators are optional, so a 16-digit run matches `\b\d{16}\b`); a
changelog-section "garbled output" was confirmed real (grapheme-indexed
`substringSafe` fed RegExp code-unit offsets); a bloom-filter "24% mis-size" was
actually ~2%.

### Async — corrections

- `AsyncSemaphoreUtils`: fixed a permit double-counting race. `release`
  incremented the available count even when handing the permit directly to a
  waiter, and the woken `acquire` decremented again; a fast-path acquirer
  arriving in the wake-up microtask gap could take the over-counted permit,
  admitting a second holder under a one-permit semaphore and driving the count
  negative. `release` now transfers directly to a waiter without touching the
  pool, and the woken waiter no longer decrements.
- Hang guards: `mapBatched` (non-positive batch size → 1, was an infinite loop);
  `raceFirst` (empty producer list → fail fast, was a never-completing future);
  `retryWithJitter` (zero jitter → `nextInt(0)` RangeError; backoff shift
  clamped); `bufferCount`/`windowCount` (non-positive count → 1); `retryTimes`
  (clamp times to ≥ 1).
- Doc: `CircuitBreakerUtils` documented as two-state (no real half-open gating);
  `memoizeFuture` notes failures are cached permanently; `raceFirst` header no
  longer claims it cancels losers.

### Parsing — corrections

- `SemverUtils.compareTo`: pre-release identifiers now compared per semver §11
  (dot-separated, numeric-vs-numeric numerically, numeric below alphanumeric,
  longer ranks higher) instead of a plain string compare that made `alpha.2 >
  alpha.10`.
- `encodeVarint`/`decodeVarint`: round-trip negative and >2^35 values — encode
  uses a logical shift with a mask test (negatives emit the full 10-byte form),
  decode's cap raised from 35 to 64 bits.
- `parseHexColor`: rejects an embedded non-hex character instead of stripping it
  and parsing the coincidentally-valid remainder.
- `parseChangelogSections`: slices with code-unit `substring`, not the
  grapheme-indexed `substringSafe`, so emoji/non-BMP content no longer misaligns
  section bodies.
- `parseNestedQuery`: skips a scalar/nested key collision (`a=1&a[b]=2`) instead
  of leaking the nested leaf to the root. `compareVersions` doc warns it ignores
  pre-release suffixes.

### String — corrections

- `SoundexUtils.encode`: vowels (A,E,I,O,U,Y) now break code adjacency (the run
  resets) while H/W remain transparent, so same-coded consonants separated by a
  vowel are re-coded — `Gauss` → `G200`, `Tymczak` → `T522`. The old code
  treated vowels and H/W identically and collapsed them.
- `substituteTemplate`: single regex pass so a value containing another key's
  placeholder is not re-expanded on a later iteration.
- `markdownToPlainText`: strips `![alt](url)` images before the link rule, so no
  stray leading `!` remains.
- `chunkText`: forces ≥1 char of forward progress, so `overlap >= maxChars`
  terminates instead of looping forever and overflowing the pre-sized buffer.
- `parseSearchQuery`: skips a bare `-` token instead of emitting an empty
  negated term.
- `extractUrlsWithContext`: trims trailing sentence punctuation the greedy match
  swallowed, leaving brackets intact for paren-bearing URLs.
- Doc accuracy: `truncateMiddle`/`redactPhone` example outputs corrected;
  `String.reversed` documented as rune-based (does not preserve grapheme
  clusters); `template_engine_utils` no longer claims conditionals;
  `textFingerprint` documented as an order-sensitive identity hash, not a
  simhash.

### Testing Validation

Existing tests for each changed file were read before editing. New regression
tests (16 groups across the three categories) pin the corrected behaviors and
would fail/hang against the old code: semver §11 ordering, varint negative/large
round-trip, hex-color embedded-non-hex rejection, nested-query collision,
empty-producer `raceFirst`, Soundex vowel handling (`Gauss`/`Tymczak`), template
no-re-substitution, markdown image drop, `chunkText` overlap-hang, search bare
`-`, URL trailing-punctuation trim.

Commands run and results:

- `dart analyze lib/async lib/parsing test/async test/parsing` → No issues found.
- `dart analyze lib/string test/string` → No issues found.
- `flutter test test/async test/parsing` → 702 passed.
- `flutter test test/string` → 2379 passed.

### Project Maintenance & Tracking

- CHANGELOG updated under `[Unreleased]` (audit passes 4 async/parsing and 5
  string).
- README verified — no updates needed (no public signature changes).
- No bug archive — task did not close a `bugs/*.md` file.

### Known follow-ups (flagged, not changed in this pass)

- Several string helpers index by UTF-16 code unit where graphemes are intended
  (`getRandomChar`, `breakLongWords`, `wordWrap`, `parseKeyValuePairs`,
  `redactPhone`'s char split, `wildcardMatch`); these corrupt or split astral
  (emoji) input. Many are documented as ASCII-oriented; a grapheme-aware pass is
  deferred as it is high-churn.
- `language_detect_utils` has two 4-character entries in its trigram profile
  data (`' a l'`, `'ção '`) that can never match a length-3 gram and skew es/pt
  ranking; correcting language-model data is deferred (intended trigram unknown).
- `textFingerprint` uses `String.hashCode` (deterministic within a run, not
  guaranteed portable); a stable content hash would be needed for persisted
  fingerprints.
- `tokenizeSentences` mis-splits on abbreviations (`Dr.`, `Mt.`, `p.`).
- `glob` `match('', '**')` returns false (the all-`**` empty-path edge case).
- `PriorityMapUtils` value-ordered priority would need a `Comparable` bound
  (carried from pass 2).
