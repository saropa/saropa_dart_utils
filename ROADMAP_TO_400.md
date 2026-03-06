# Saropa Dart Utils — Roadmap (400 ideas)

**Purpose:** Candidate utility methods and small algorithms. Prioritized by usefulness, importance, complexity, and **impact on app size** (many ideas target common complex/boilerplate code so apps can delete their own copies).

---

## ⚠️ Tree-shaking is critical

This package **must** remain fully tree-shakeable or it will be **dead** in production.

- **One file per feature (or small cohesive group).** No mega-files that pull in unrelated code.
- **Consumers import only what they use:**  
  `import 'package:saropa_dart_utils/string/levenshtein_utils.dart';`  
  Not required: `import 'package:saropa_dart_utils/saropa_dart_utils.dart';` for one helper.
- **No global state or static registries** that force inclusion of unused code.
- **Pure functions and extensions only.** No side-effectful initialization that blocks dead-code elimination.
- **Document in README:** “For minimal bundle size, import specific files instead of the barrel.”

---

## Legend

| Tag | Meaning |
|-----|--------|
| **Usefulness** | High = used in many apps; Medium = common in some domains; Low = niche but valuable |
| **Importance** | Critical = often duplicated badly; High = frequently reimplemented; Medium/Low = nice to have |
| **Complexity** | High = non-trivial algo/edge cases; Medium = moderate logic; Low = thin wrapper or simple logic |
| **Size** | ✅ = replaces common complex/algorithmic code in apps (reduces app size). |
| **Done** | ✅ = implemented (lint/idea completed). **TODO** = not yet implemented. |

---

## Roadmap progress

| Section | Done | Total |
|---------|------|-------|
| String (1–30) | 30 | 30 |
| Collections (31–70) | 20 | 40 |
| Map/Object (71–90) | 19 | 20 |
| DateTime (91–115) | 25 | 25 |
| Number/Math (116–140) | 25 | 25 |
| Parsing (141–160) | 13 | 20 |
| URL/Path (161–175) | 12 | 15 |
| Async (176–185) | 9 | 10 |
| Regex (186–193) | 8 | 8 |
| Caching (194–198) | 5 | 5 |
| Object/Equality (199–210) | 12 | 12 |
| Niche (211–230) | 20 | 20 |
| Lower priority (231–250) | 20 | 20 |
| String More (251–265) | 15 | 15 |
| Collections More (266–290) | 25 | 25 |
| Map More (291–300) | 10 | 10 |
| DateTime More (301–310) | 10 | 10 |
| Number More (311–325) | 15 | 15 |
| Parsing More (326–335) | 10 | 10 |
| URL More (336–345) | 10 | 10 |
| Async More (346–350) | 5 | 5 |
| Type/Null (351–365) | 15 | 15 |
| Testing/Debug (366–375) | 10 | 10 |
| Niche More (376–390) | 15 | 15 |
| Lower More (391–400) | 10 | 10 |
| **Total** | **368** | **400** |

---

## String — Algorithms & complex logic (30 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 1 | Levenshtein distance (edit distance) | High | High | High | ✅ | ✅ |
| 2 | Fuzzy substring match (e.g. contains with typos) | High | High | High | ✅ | ✅ |
| 3 | Word wrap at column with break opportunities | High | High | High | ✅ | ✅ |
| 4 | Line break normalization (CRLF/LF/CR → one form) | High | Medium | Medium | ✅ | ✅ |
| 5 | Slug from title (lowercase, replace spaces/special → hyphen) | High | High | Medium | ✅ | ✅ |
| 6 | Sanitize filename (remove invalid chars, length cap) | High | High | Medium | ✅ | ✅ |
| 7 | Mask string (e.g. show last 4 digits, rest `*`) | High | High | Low | ✅ | ✅ |
| 8 | Redact email/phone (e.g. j***@example.com) | High | Medium | Medium | ✅ | ✅ |
| 9 | Simple template substitution (e.g. `Hello {{name}}`) | High | High | Medium | ✅ | ✅ |
| 10 | Escape string for use inside regex | High | High | Medium | ✅ | ✅ |
| 11 | Wildcard match (`*` and `?`) | High | High | Medium | ✅ | ✅ |
| 12 | Glob-style match (e.g. `**/*.dart`) | Medium | Medium | High | ✅ | ✅ |
| 13 | Soundex / Metaphone (phonetic match) | Medium | Medium | High | ✅ | ✅ |
| 14 | Strip BOM (byte order mark) from string | Medium | Medium | Low | ✅ | ✅ |
| 15 | Normalize Unicode (NFC/NFD) for comparison/storage | High | High | Medium | ✅ | ✅ |
| 16 | Truncate at grapheme boundary (no broken emoji) | High | High | Medium | ✅ | ✅ |
| 17 | Wrap in quotes and escape internal quotes (CSV-style) | High | High | Medium | ✅ | ✅ |
| 18 | Indent all lines by prefix | High | Medium | Low | ✅ | ✅ |
| 19 | Dedent (remove common leading whitespace) | High | Medium | Medium | ✅ | ✅ |
| 20 | Count words (locale-aware boundaries) | High | Medium | Medium | ✅ | ✅ |
| 21 | Highlight substring (return string with marker around match) | Medium | Medium | Low | ✅ | ✅ |
| 22 | Split keeping delimiter (e.g. split by regex, keep matches) | Medium | Medium | Medium | ✅ | ✅ |
| 23 | Replace first N occurrences only | High | Medium | Low | ✅ | ✅ |
| 24 | Replace last occurrence only | Medium | Low | Low | ✅ | ✅ |
| 25 | Common prefix of list of strings | Medium | Medium | Medium | ✅ | ✅ |
| 26 | Common suffix of list of strings | Medium | Low | Medium | ✅ | ✅ |
| 27 | Strip ANSI escape codes | Medium | Medium | Medium | ✅ | ✅ |
| 28 | Parse simple key=value pairs (e.g. `a=1 b=2`) | High | High | Medium | ✅ | ✅ |
| 29 | Camel/snake conversion that handles acronyms (e.g. HTTP → http) | High | High | Medium | ✅ | ✅ |
| 30 | Break long words (insert soft hyphen or break at N chars) | Medium | Low | Medium | ✅ | ✅ |

---

## Collections — Algorithms & complex logic (40 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 31 | Chunk list into fixed-size chunks | High | High | Low | ✅ | ✅ |
| 32 | Sliding window (e.g. windows of 3) | High | High | Medium | ✅ | ✅ |
| 33 | Partition by predicate (two lists: true / false) | High | High | Low | ✅ | ✅ |
| 34 | Group by key (Map<K, List<V>>) | High | Critical | Medium | ✅ | ✅ |
| 35 | Group by key with value transform (Map<K, List<U>>) | High | High | Medium | ✅ | ✅ |
| 36 | Flatten nested iterable one level | High | High | Low | ✅ | ✅ |
| 37 | Flatten nested iterable to depth N or fully deep | High | High | Medium | ✅ | ✅ |
| 38 | Distinct by key (first occurrence per key) | High | High | Medium | ✅ | ✅ |
| 39 | Sort by comparable key (e.g. sortBy((x) => x.name)) | High | Critical | Medium | ✅ | ✅ |
| 40 | Sort by multiple keys (thenBy) | High | High | Medium | ✅ | ✅ |
| 41 | Binary search in sorted list (index or insertion point) | High | High | Medium | ✅ | ✅ |
| 42 | Merge two sorted lists into one sorted | High | High | Medium | ✅ | ✅ |
| 43 | Dedupe consecutive equal elements | High | Medium | Low | ✅ | ✅ |
| 44 | Run-length encode (value + count pairs) | Medium | Medium | Medium | ✅ | ✅ |
| 45 | Run-length decode | Medium | Medium | Low | ✅ | ✅ |
| 46 | Cartesian product of two (or N) lists | Medium | Medium | Medium | ✅ | ✅ |
| 47 | Permutations of list (or count) | Medium | Medium | High | ✅ | ✅ |
| 48 | Combinations (choose K from N) | Medium | Medium | High | ✅ | ✅ |
| 49 | Zip with index ([(0,a),(1,b),...]) | High | High | Low | ✅ | ✅ |
| 50 | Interleave two lists (a1,b1,a2,b2,...) | Medium | Medium | Low | ✅ | ✅ |
| 51 | Top K elements (partial sort or heap) | High | High | High | ✅ | TODO |
| 52 | Nth element (e.g. 2nd smallest) without full sort | Medium | Medium | High | ✅ | TODO |
| 53 | Take every Nth element | High | Medium | Low | ✅ | TODO |
| 54 | Skip every Nth element | Medium | Low | Low | ✅ | TODO |
| 55 | Rotate list left/right by N | High | Medium | Low | ✅ | TODO |
| 56 | Shuffle with seed (reproducible) | High | High | Medium | ✅ | TODO |
| 57 | Stable sort by key (preserve order for equal keys) | High | High | Medium | ✅ | TODO |
| 58 | Topological sort (DAG) from edges | Medium | High | High | ✅ | TODO |
| 59 | Split at index / split at predicate (first where true) | High | High | Low | ✅ | TODO |
| 60 | Indexed map (map with (index, value)) | High | High | Low | ✅ | TODO |
| 61 | Fold with index (reduce with index) | Medium | Medium | Low | ✅ | TODO |
| 62 | First where / last where (with default) | High | High | Low | ✅ | TODO |
| 63 | Min/max by key (return element, not value) | High | High | Medium | ✅ | TODO |
| 64 | All pairs (i,j) i < j from list | Medium | Medium | Low | ✅ | TODO |
| 65 | Difference of two lists (elements in A not in B) | High | High | Medium | ✅ | TODO |
| 66 | Symmetric difference (A Δ B) | Medium | Medium | Medium | ✅ | TODO |
| 67 | Intersection of two lists (with optional count) | High | High | Medium | ✅ | TODO |
| 68 | Union of two lists (distinct) | High | High | Low | ✅ | TODO |
| 69 | LCS (longest common subsequence) of two lists | Medium | Medium | High | ✅ | TODO |
| 70 | Diff two lists (added/removed/unchanged) | High | High | High | ✅ | TODO |

---

## Map / Object — Deep and structural (20 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 71 | Deep merge maps (recursive, with overwrite/combine policy) | High | Critical | High | ✅ | ✅ |
| 72 | Deep copy map (and list values) | High | High | Medium | ✅ | ✅ |
| 73 | Flatten keys (e.g. `a.b.c` → value) | High | High | Medium | ✅ | ✅ |
| 74 | Unflatten keys to nested map | High | High | Medium | ✅ | ✅ |
| 75 | Pick keys (new map with only listed keys) | High | High | Low | ✅ | ✅ |
| 76 | Omit keys (new map without listed keys) | High | High | Low | ✅ | ✅ |
| 77 | Map diff (keys added/removed/changed) | High | High | Medium | ✅ | ✅ |
| 78 | Invert map (K→V to V→K; handle collisions) | High | Medium | Medium | ✅ | ✅ |
| 79 | Map from list of pairs / entries to map | High | High | Low | ✅ | ✅ |
| 80 | Map entries to list of pairs | High | Medium | Low | ✅ | ✅ |
| 81 | Get nested value by path (list of keys) with default | High | High | Medium | ✅ | ✅ |
| 82 | Set nested value by path (create missing keys) | High | High | Medium | ✅ | ✅ |
| 83 | Deep equality for map/list (recursive) | High | Critical | Medium | ✅ | ✅ |
| 84 | Map values (transform values, keep keys) | High | High | Low | ✅ | ✅ |
| 85 | Map keys (transform keys, keep values) | High | High | Low | ✅ | ✅ |
| 86 | Filter map by key predicate | High | High | Low | ✅ | ✅ |
| 87 | Filter map by value predicate | High | High | Low | ✅ | ✅ |
| 88 | Merge list of maps (reduce with merge) | High | High | Low | ✅ | ✅ |
| 89 | Default map (return default for missing key, optional set) | Medium | Medium | Low | ✅ | ✅ |
| 90 | Freeze / deep freeze (immutable view; if feasible in Dart) | Low | Low | High | ✅ | TODO |

---

## DateTime / Duration — Business & display (25 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 91 | Business days between two dates (exclude weekends/holidays) | High | High | High | ✅ | ✅ |
| 92 | Add business days | High | High | Medium | ✅ | ✅ |
| 93 | Next weekday (skip weekend) | High | High | Low | ✅ | ✅ |
| 94 | Format duration (e.g. "2h 30m" or "2 hours 30 minutes") | High | High | Medium | ✅ | ✅ |
| 95 | Parse duration string (e.g. "1.5h", "90m") | High | High | Medium | ✅ | ✅ |
| 96 | Relative time string ("2 hours ago", "in 3 days") | High | Critical | Medium | ✅ | ✅ |
| 97 | Quarter of date (Q1–Q4) | High | High | Low | ✅ | ✅ |
| 98 | Fiscal year start/end (configurable month) | Medium | High | Medium | ✅ | ✅ |
| 99 | Week number in month | Medium | Medium | Low | ✅ | ✅ |
| 100 | Start of week (configurable weekday) | High | High | Low | ✅ | ✅ |
| 101 | End of week | High | High | Low | ✅ | ✅ |
| 102 | Start/end of month | High | High | Low | ✅ | ✅ |
| 103 | Start/end of quarter | Medium | Medium | Low | ✅ | ✅ |
| 104 | Start/end of year | High | Medium | Low | ✅ | ✅ |
| 105 | Days in month (account for leap year) | High | High | Low | ✅ | ✅ |
| 106 | Format as ISO week (e.g. 2026-W09) | Medium | Medium | Low | ✅ | ✅ |
| 107 | Parse ISO week string | Medium | Medium | Medium | ✅ | ✅ |
| 108 | Timezone offset string (e.g. +01:00) from DateTime | Medium | Medium | Low | ✅ | ✅ |
| 109 | Same time on another day (copy time, change date) | High | Medium | Low | ✅ | ✅ |
| 110 | Clamp DateTime to range | High | High | Low | ✅ | ✅ |
| 111 | Min/max of list of DateTime | High | High | Low | ✅ | ✅ |
| 112 | Sort list of DateTime (return new list) | High | Medium | Low | ✅ | ✅ |
| 113 | Generate range of dates (day step) | High | High | Low | ✅ | ✅ |
| 114 | Overlap of two date ranges (start, end) | High | High | Medium | ✅ | ✅ |
| 115 | Contains (date in range) for range type | High | High | Low | ✅ | ✅ |

---

## Number / Math — Stats and algorithms (25 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 116 | GCD (greatest common divisor) | High | High | Medium | ✅ | ✅ |
| 117 | LCM (least common multiple) | High | Medium | Low | ✅ | ✅ |
| 118 | Clamp to int (round then clamp) | High | High | Low | ✅ | ✅ |
| 119 | Round to significant digits | High | High | Medium | ✅ | ✅ |
| 120 | Format compact number (1.2K, 3.5M) | High | High | Medium | ✅ | ✅ |
| 121 | Parse compact number ("1.2K" → 1200) | High | Medium | Medium | ✅ | ✅ |
| 122 | Variance of list of numbers | High | High | Medium | ✅ | ✅ |
| 123 | Standard deviation | High | High | Low | ✅ | ✅ |
| 124 | Median | High | High | Medium | ✅ | ✅ |
| 125 | Percentile / quantile | High | High | Medium | ✅ | ✅ |
| 126 | Is prime (small numbers) | Medium | Medium | Medium | ✅ | ✅ |
| 127 | Prime factors | Medium | Low | Medium | ✅ | ✅ |
| 128 | Factorial (with overflow guard) | Medium | Low | Low | ✅ | ✅ |
| 129 | Modulo that handles negative (e.g. -1 % 7 → 6) | High | High | Low | ✅ | ✅ |
| 130 | Lerp (linear interpolation) | High | High | Low | ✅ | ✅ |
| 131 | Inverse lerp (value to 0–1) | High | Medium | Low | ✅ | ✅ |
| 132 | Map value from one range to another | High | High | Low | ✅ | ✅ |
| 133 | Round to multiple (e.g. round to nearest 0.05) | High | High | Low | ✅ | ✅ |
| 134 | Floor/ceil to multiple | High | Medium | Low | ✅ | ✅ |
| 135 | Sum/count/average for iterable of num (generic) | High | High | Low | ✅ | ✅ |
| 136 | Min/max of two or N numbers | High | High | Low | ✅ | ✅ |
| 137 | Is in closed/open range (inclusive vs exclusive) | High | High | Low | ✅ | ✅ |
| 138 | Parse int/double with locale (e.g. 1,234.56) | Medium | Medium | Medium | ✅ | ✅ |
| 139 | Format number with locale (thousands sep, decimals) | High | High | Medium | ✅ | ✅ |
| 140 | Safe division (avoid division by zero, return optional or default) | High | High | Low | ✅ | ✅ |

---

## Parsing & validation (20 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 141 | Parse CSV line (handle quoted fields) | High | Critical | High | ✅ | ✅ |
| 142 | Parse key=value or "key"="value" pairs | High | High | Medium | ✅ | ✅ |
| 143 | Parse duration string ("2h 30m", "90s") | High | High | Medium | ✅ | ✅ |
| 144 | Parse size string ("1.5 MB", "512K") to bytes | High | High | Medium | ✅ | ✅ |
| 145 | Format bytes to human (1.5 MB) | High | High | Low | ✅ | ✅ |
| 146 | Email validation (reasonable regex, not RFC-perfect) | High | High | Medium | ✅ | ✅ |
| 147 | Phone number normalize (digits only or E.164-ish) | High | High | Medium | ✅ | ✅ |
| 148 | Luhn check (credit card / ID validation) | High | High | Medium | ✅ | ✅ |
| 149 | ISBN-10/13 validation | Medium | Medium | Medium | ✅ | ✅ |
| 150 | Semver parse and compare | High | High | Medium | ✅ | ✅ |
| 151 | Parse version string (major.minor.patch) | High | High | Low | ✅ | ✅ |
| 152 | Parse hex color string (#RGB, #RRGGBB, #AARRGGBB) | High | High | Medium | ✅ | ✅ |
| 153 | Parse simple boolean ("on"/"off", "1"/"0", "yes"/"no") — extend existing | High | High | Low | — | ✅ |
| 154 | Parse list from string (e.g. "a,b,c" or JSON array string) | High | High | Medium | ✅ | TODO |
| 155 | Validate non-empty after trim | High | High | Low | ✅ | TODO |
| 156 | Coerce to int/double (parse or default) — extend existing | High | High | Low | — | TODO |
| 157 | Parse JSON path (e.g. "$.a.b[0]") for dynamic access | Medium | Medium | High | ✅ | TODO |
| 158 | Parse simple cron expression (next run time) | Low | Low | High | ✅ | TODO |
| 159 | Parse Accept-Language header (q-values) | Medium | Medium | Medium | ✅ | TODO |
| 160 | Parse Range header (bytes=0-499) | Low | Low | Medium | ✅ | TODO |

---

## URL / Path / Encoding (15 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 161 | Join path segments (cross-platform, no double slash) | High | High | Medium | ✅ | ✅ |
| 162 | Normalize path (resolve . and ..) | High | High | Medium | ✅ | ✅ |
| 163 | Relative path from base to target | High | High | Medium | ✅ | ✅ |
| 164 | File extension / without extension | High | High | Low | ✅ | ✅ |
| 165 | Change extension | High | Medium | Low | ✅ | ✅ |
| 166 | URL encode/decode (component vs full) | High | High | Low | ✅ | ✅ |
| 167 | Form encode (application/x-www-form-urlencoded) | High | High | Medium | ✅ | ✅ |
| 168 | Parse query string to map (and back) | High | High | Medium | ✅ | ✅ |
| 169 | Add/remove/replace query params (immutable) | High | High | Low | ✅ | ✅ |
| 170 | Build URL from base + path + query | High | High | Low | ✅ | ✅ |
| 171 | Safe decode URI (return null on failure) | High | High | Low | ✅ | ✅ |
| 172 | Parse data URL (e.g. data:image/png;base64,...) | Medium | Medium | Medium | ✅ | ✅ |
| 173 | Strip fragment from URL | High | Medium | Low | ✅ | TODO |
| 174 | Is absolute URL / is relative path | High | High | Low | ✅ | TODO |
| 175 | Canonicalize URL (sort query, remove defaults) | Medium | Medium | Medium | ✅ | TODO |

---

## Async / Stream / Time (10 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 176 | Debounce (time) — return new function that debounces | High | Critical | Medium | ✅ | ✅ |
| 177 | Throttle (time) — max one call per interval | High | High | Medium | ✅ | ✅ |
| 178 | Retry with backoff (exponential/linear) | High | High | Medium | ✅ | ✅ |
| 179 | Timeout with fallback value | High | High | Low | ✅ | ✅ |
| 180 | Cache single async result (memoize Future) | High | High | Low | ✅ | ✅ |
| 181 | Sequential async map (one after another) | Medium | Medium | Low | ✅ | ✅ |
| 182 | Batch async (e.g. 5 at a time) | High | High | Medium | ✅ | ✅ |
| 183 | Cancel previous (only latest async wins) | High | High | Low | ✅ | ✅ |
| 184 | Delay by duration (Future.delayed wrapper) | High | Medium | Low | ✅ | ✅ |
| 185 | Debounce stream (emit after silence) | Medium | Medium | Medium | ✅ | TODO |

---

## Regex & patterns (8 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 186 | Escape string for regex | High | High | Medium | ✅ | ✅ |
| 187 | Common regex: email (simple) | High | High | Low | ✅ | ✅ |
| 188 | Common regex: phone (digits) | High | Medium | Low | ✅ | ✅ |
| 189 | Common regex: URL (loose) | High | High | Low | ✅ | ✅ |
| 190 | Match all (return all matches with groups) | High | High | Low | ✅ | ✅ |
| 191 | Replace with callback (replace all with function of match) | High | High | Low | ✅ | ✅ |
| 192 | Split by regex keeping delimiters | Medium | Medium | Low | ✅ | ✅ |
| 193 | Named group map (Map<String, String> from match) | Medium | Medium | Low | ✅ | ✅ |

---

## Caching & memoization (5 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 194 | LRU cache (max size, pure Dart) | High | High | High | ✅ | ✅ |
| 195 | TTL cache (expire after duration) | High | High | Medium | ✅ | ✅ |
| 196 | Memoize sync function (by argument equality) | High | High | Medium | ✅ | ✅ |
| 197 | Single-value cache (compute once) | High | High | Low | ✅ | ✅ |
| 198 | Cache with size limit (evict oldest) | Medium | Medium | Medium | ✅ | ✅ |

---

## Object / Copy / Equality (12 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 199 | Deep equality (list, map, primitives) | High | Critical | Medium | ✅ | ✅ |
| 200 | Copy with defaults (merge with default object) | High | High | Low | ✅ | ✅ |
| 201 | Require non-null (throw descriptive if null) | High | High | Low | ✅ | ✅ |
| 202 | Also/let style (pipe value through function) | Medium | Medium | Low | ✅ | ✅ |
| 203 | Null coalesce chain (first non-null of list) | High | High | Low | ✅ | ✅ |
| 204 | Cast or null (safe cast) | High | High | Low | ✅ | ✅ |
| 205 | Assert with message (only in debug if desired) | High | Medium | Low | ✅ | ✅ |
| 206 | Identity equality (same reference) | Medium | Low | Low | ✅ | ✅ |
| 207 | Shallow copy list/map | High | High | Low | ✅ | ✅ |
| 208 | Pick/omit for typed objects (via map intermediate) | Medium | Medium | Low | ✅ | ✅ |
| 209 | Merge two objects (copyWith-style from maps) | High | High | Low | ✅ | ✅ |
| 210 | Default map for null (map null to default value) | High | High | Low | ✅ | ✅ |

---

## Niche / domain (20 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 211 | Color hex to RGB/HSL components | Medium | Medium | Low | ✅ | ✅ |
| 212 | RGB/HSL to hex | Medium | Medium | Low | ✅ | ✅ |
| 213 | Contrast ratio (WCAG) | Medium | Medium | Low | ✅ | ✅ |
| 214 | Simple hash (e.g. for cache key from objects) | High | High | Medium | ✅ | ✅ |
| 215 | Slug with max length (truncate words) | High | High | Medium | ✅ | ✅ |
| 216 | Abbreviate name (e.g. "John Doe" → "J. Doe") | Medium | Medium | Low | ✅ | ✅ |
| 217 | Initials from name (e.g. "John Doe" → "JD") | High | High | Low | ✅ | ✅ |
| 218 | Wrap text at width (monospace or approximate) | High | High | Medium | ✅ | ✅ |
| 219 | Indent with tab/space option | High | Medium | Low | ✅ | ✅ |
| 220 | Pad number with leading zeros | High | High | Low | ✅ | ✅ |
| 221 | Format file size in appropriate unit | High | High | Low | ✅ | ✅ |
| 222 | Pluralize with count (e.g. "1 item" / "2 items") — extend | High | High | Low | — | ✅ |
| 223 | Ordinal suffix (1st, 2nd, 3rd) — exists, extend i18n | Medium | Low | Low | — | ✅ |
| 224 | Diff two strings (line-by-line or character) | Medium | Medium | High | ✅ | ✅ |
| 225 | Apply patch (simple line-based) | Low | Low | High | ✅ | ✅ |
| 226 | Checksum (e.g. simple additive for integrity) | Low | Low | Medium | ✅ | ✅ |
| 227 | Generate random string (alphanumeric, length) | High | High | Low | ✅ | ✅ |
| 228 | Generate random UUID v4 | High | High | Medium | ✅ | ✅ |
| 229 | Parse and validate UUID (extend existing) | High | High | Low | — | ✅ |
| 230 | Sort strings naturally (human: a2 before a10) | High | High | Medium | ✅ | ✅ |

---

## Lower priority / polish (20 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 231 | Truncate with custom ellipsis (e.g. "...") | High | Low | Low | — | ✅ |
| 232 | Pad string left/right to length | High | Medium | Low | — | ✅ |
| 233 | Repeat string N times | High | Low | Low | — | ✅ |
| 234 | Is whitespace only | High | Medium | Low | — | ✅ |
| 235 | Swap two elements in list | Medium | Low | Low | — | ✅ |
| 236 | Reverse list in place (or return new) | High | Medium | Low | — | ✅ |
| 237 | Insert at index (return new list) | High | Medium | Low | — | ✅ |
| 238 | Replace at index (return new list) | High | Medium | Low | — | ✅ |
| 239 | Safe get for list (null if out of range) | High | High | Low | — | ✅ |
| 240 | Default if empty (list/map/string) | High | High | Low | — | ✅ |
| 241 | First or compute (lazy default) | High | Medium | Low | — | ✅ |
| 242 | Exhaustiveness check for enum (compile-time where possible) | Medium | Medium | Low | — | ✅ |
| 243 | Enum from string (case-insensitive) — extend | High | High | Low | — | ✅ |
| 244 | Try parse (return Result/Optional style) | High | High | Low | — | ✅ |
| 245 | Also (tap) for any type (side effect, return same) | Medium | Medium | Low | — | ✅ |
| 246 | Pipe (chain unary functions) | Medium | Low | Low | — | ✅ |
| 247 | Compose (f(g(x))) | Low | Low | Low | — | ✅ |
| 248 | Once (run block only once) | Medium | Low | Low | — | ✅ |
| 249 | Lazy singleton (compute on first access) | Medium | Medium | Low | — | ✅ |
| 250 | Version compare (semver or dotted) | High | High | Low | — | ✅ |

---

## String — More (15 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 251 | Strip leading/trailing substring (not just whitespace) | High | High | Low | ✅ | ✅ |
| 252 | Split into lines (handle CRLF/LF/CR) | High | High | Low | ✅ | ✅ |
| 253 | Join lines with separator | High | Medium | Low | ✅ | ✅ |
| 254 | Wrap string at N chars (hard break) | High | High | Low | ✅ | ✅ |
| 255 | Capitalize sentence (first letter of each sentence) | Medium | Medium | Medium | ✅ | ✅ |
| 256 | Swap case (upper↔lower) | Medium | Low | Low | ✅ | ✅ |
| 257 | Remove repeated chars (consecutive duplicates) | High | Medium | Low | ✅ | ✅ |
| 258 | Count occurrences of substring | High | High | Low | ✅ | ✅ |
| 259 | Find all indices of substring | Medium | Medium | Low | ✅ | ✅ |
| 260 | Is palindrome (ignore case/punctuation optional) | Medium | Low | Low | ✅ | ✅ |
| 261 | Reverse words (order of words, not chars) | Medium | Low | Low | ✅ | ✅ |
| 262 | Extract first N words | High | High | Low | ✅ | ✅ |
| 263 | Extract last N words | Medium | Medium | Low | ✅ | ✅ |
| 264 | Pad to fixed width (left/right/center) | High | High | Low | ✅ | ✅ |
| 265 | Strip HTML comments | Medium | Medium | Medium | ✅ | ✅ |

---

## Collections — More (25 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 266 | Take while inclusive (include first that fails predicate) | Medium | Medium | Low | ✅ | ✅ |
| 267 | Drop last N elements | High | High | Low | ✅ | ✅ |
| 268 | Take last N elements | High | High | Low | ✅ | ✅ |
| 269 | Replace first occurrence (by value or predicate) | High | High | Low | ✅ | ✅ |
| 270 | Replace all occurrences (by value or predicate) | High | High | Low | ✅ | ✅ |
| 271 | Replace at index (return new list) | High | High | Low | ✅ | ✅ |
| 272 | Swap two indices (return new list) | Medium | Medium | Low | ✅ | ✅ |
| 273 | Cycle (infinite iterable repeating list) | Medium | Medium | Low | ✅ | ✅ |
| 274 | Pad list to length (with fill value) | High | High | Low | ✅ | ✅ |
| 275 | Unzip (list of pairs → two lists) | High | High | Low | ✅ | ✅ |
| 276 | Zip longest (pad shorter with default) | Medium | Medium | Low | ✅ | ✅ |
| 277 | Segment by predicate (split at boundaries where predicate changes) | High | High | Medium | ✅ | ✅ |
| 278 | Consecutive pairs ([(a,b),(b,c),(c,d),...]) | High | High | Low | ✅ | ✅ |
| 279 | Consecutive triples / N-tuples | Medium | Medium | Low | ✅ | ✅ |
| 280 | Find index of min/max by key | High | High | Low | ✅ | ✅ |
| 281 | Argmin / argmax (index of min/max element) | High | High | Low | ✅ | ✅ |
| 282 | All equal (all elements identical) | High | High | Low | ✅ | ✅ |
| 283 | Count by key (Map<T, int> frequencies) | High | High | Low | ✅ | ✅ |
| 284 | Mode (most frequent value; handle ties) | High | High | Medium | ✅ | ✅ |
| 285 | Sample N elements without replacement | High | High | Medium | ✅ | ✅ |
| 286 | Sample N elements with replacement | Medium | Medium | Low | ✅ | ✅ |
| 287 | Split into N roughly equal parts | High | High | Medium | ✅ | ✅ |
| 288 | Batch by size with overlap (sliding batches) | Medium | Medium | Low | ✅ | ✅ |
| 289 | Scan (prefix sum / fold that yields intermediates) | High | High | Low | ✅ | ✅ |
| 290 | Tee (duplicate iterable for multiple consumers) | Low | Low | Medium | ✅ | ✅ |

---

## Map / Object — More (10 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 291 | Map from iterable (key + value selector) | High | High | Low | ✅ | ✅ |
| 292 | Map to list of keys / list of values | High | High | Low | ✅ | ✅ |
| 293 | Find key by value | High | High | Low | ✅ | ✅ |
| 294 | Merge maps with conflict resolver (e.g. sum, last wins) | High | High | Medium | ✅ | ✅ |
| 295 | Recursive map transform (visit all keys/values) | Medium | Medium | High | ✅ | ✅ |
| 296 | Rename key (return new map) | High | High | Low | ✅ | ✅ |
| 297 | Rename keys (map of old → new) | High | High | Low | ✅ | ✅ |
| 298 | Map where (filter + transform in one) | High | High | Low | ✅ | ✅ |
| 299 | Ensure key exists (set if absent) | High | High | Low | ✅ | ✅ |
| 300 | Update or insert (upsert by key) | High | High | Low | ✅ | ✅ |

---

## DateTime / Duration — More (10 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 301 | Format date only (no time) in locale-friendly form | High | High | Medium | ✅ | ✅ |
| 302 | Format time only (no date) | High | High | Low | ✅ | ✅ |
| 303 | Parse loose date string (e.g. "tomorrow", "next Monday") | Medium | Medium | High | ✅ | ✅ |
| 304 | Is same day (two DateTimes) | High | High | Low | ✅ | ✅ |
| 305 | Is morning / afternoon / evening (time of day buckets) | High | Medium | Low | ✅ | ✅ |
| 306 | Round DateTime to nearest minute/hour/day | High | High | Medium | ✅ | ✅ |
| 307 | Duration between two DateTimes (absolute) | High | High | Low | ✅ | ✅ |
| 308 | Is within last N days / hours | High | High | Low | ✅ | ✅ |
| 309 | List of months between two dates | Medium | Medium | Low | ✅ | ✅ |
| 310 | List of years between two dates | Medium | Low | Low | ✅ | ✅ |

---

## Number / Math — More (15 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size |
|---|------|------------|------------|------------|------|
| 311 | Clamp int to 0..N (non-negative) | High | High | Low | ✅ | ✅ |
| 312 | Is integer (double has no fractional part) | High | High | Low | ✅ | ✅ |
| 313 | Is even / is odd (for int) | High | High | Low | — | ✅ |
| 314 | Round half up / half down (banker's rounding option) | High | High | Medium | ✅ | ✅ |
| 315 | Truncate to decimal places (no rounding) | High | Medium | Low | ✅ | ✅ |
| 316 | Percentage change (from A to B) | High | High | Low | ✅ | ✅ |
| 317 | Percentage of (what % is A of B) | High | High | Low | ✅ | ✅ |
| 318 | Degrees to radians / radians to degrees | High | High | Low | ✅ | ✅ |
| 319 | Normalize angle to 0..360 or -180..180 | Medium | Medium | Low | ✅ | ✅ |
| 320 | Digit sum (sum of digits of integer) | Medium | Low | Low | ✅ | ✅ |
| 321 | Is power of two | High | High | Low | ✅ | ✅ |
| 322 | Next power of two (ceiling) | Medium | Medium | Low | ✅ | ✅ |
| 323 | Integer square root (floor) | Medium | Medium | Medium | ✅ | ✅ |
| 324 | Format as currency (symbol, decimals, locale) | High | High | Medium | ✅ | ✅ |
| 325 | Parse currency string to num | High | High | Medium | ✅ | ✅ |

---

## Parsing & validation — More (10 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 326 | Parse integer with base (2, 8, 16, etc.) | High | High | Low | ✅ | ✅ |
| 327 | Validate URL format (loose) | High | High | Low | ✅ | ✅ |
| 328 | Validate IPv4 / IPv6 address | Medium | Medium | Medium | ✅ | ✅ |
| 329 | Parse port from "host:port" | High | High | Low | ✅ | ✅ |
| 330 | Parse key:value lines (e.g. .env style) | High | High | Medium | ✅ | ✅ |
| 331 | Validate strong password (length, digit, special) | High | High | Medium | ✅ | ✅ |
| 332 | Parse MIME type (e.g. "text/plain; charset=utf-8") | Medium | Medium | Medium | ✅ | ✅ |
| 333 | Parse Content-Disposition filename | Low | Low | Medium | ✅ | ✅ |
| 334 | Validate hex string (length optional) | High | High | Low | ✅ | ✅ |
| 335 | Parse dotted decimal (e.g. "1.2.3.4" → list) | Medium | Medium | Low | ✅ | ✅ |

---

## URL / Path / Encoding — More (10 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 336 | Get directory from path (parent path) | High | High | Low | ✅ | ✅ |
| 337 | Get base name (filename without extension) | High | High | Low | ✅ | ✅ |
| 338 | Path separator (platform-specific) | High | Medium | Low | ✅ | ✅ |
| 339 | Is path absolute | High | High | Low | ✅ | ✅ |
| 340 | Collapse repeated separators | High | Medium | Low | ✅ | ✅ |
| 341 | Append path segment (with separator handling) | High | High | Low | ✅ | ✅ |
| 342 | Encode for cookie value | Medium | Medium | Low | ✅ | ✅ |
| 343 | Parse cookie header to map | Medium | Medium | Medium | ✅ | ✅ |
| 344 | Build cookie header from map | Medium | Medium | Low | ✅ | ✅ |
| 345 | Parse Authorization header (Bearer token) | Medium | Medium | Low | ✅ | ✅ |

---

## Async / Stream / Concurrency — More (5 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 346 | Race (first of N futures to complete) | High | High | Low | ✅ | ✅ |
| 347 | All settled (wait all, return results + errors) | High | High | Medium | ✅ | ✅ |
| 348 | Retry N times (simple count) | High | High | Low | ✅ | ✅ |
| 349 | Throttle stream (max N per duration) | Medium | Medium | Medium | ✅ | ✅ |
| 350 | Buffer stream (collect until N or timeout) | Medium | Medium | Medium | ✅ | ✅ |

---

## Type / Null / Result (15 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 351 | Require non-null or throw with name | High | High | Low | ✅ | ✅ |
| 352 | When non-null (run callback, return same) | High | High | Low | ✅ | ✅ |
| 353 | Map if non-null (optional transform) | High | High | Low | ✅ | ✅ |
| 354 | Else get (value or compute default) | High | High | Low | ✅ | ✅ |
| 355 | To optional (T → T?) for API compatibility | Low | Low | Low | — | ✅ |
| 356 | Try cast (T? → U? where U extends T) | High | High | Low | ✅ | ✅ |
| 357 | Is type (check without cast) | High | High | Low | ✅ | ✅ |
| 358 | As type or default (cast or fallback) | High | High | Low | ✅ | ✅ |
| 359 | Result type (Ok/Err) for parse-style ops | Medium | High | Medium | ✅ | ✅ |
| 360 | Unwrap or throw (Result → value) | Medium | Medium | Low | ✅ | ✅ |
| 361 | Partition by type (List<A> and List<B> from List<Object>) | Medium | Medium | Medium | ✅ | ✅ |
| 362 | First of type (find first A in List<Object>) | High | High | Low | ✅ | ✅ |
| 363 | Where type (filter + cast in one) | High | High | Low | ✅ | ✅ |
| 364 | Default if null (extension on T?) | High | High | Low | — | ✅ |
| 365 | To list if not null (T? → List<T>) | Medium | Medium | Low | ✅ | ✅ |

---

## Testing / Debug / Dev (10 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 366 | Pretty-print object (nested, indented) | High | High | Low | ✅ | ✅ |
| 367 | Dump iterable (truncated if long) | Medium | Medium | Low | ✅ | ✅ |
| 368 | Assert equals with tolerance (for doubles) | High | High | Low | ✅ | ✅ |
| 369 | Generate range of ints (start, end, step) | High | High | Low | ✅ | ✅ |
| 370 | Generate range of doubles | Medium | Medium | Low | ✅ | ✅ |
| 371 | Repeat value N times (list of same element) | High | High | Low | ✅ | ✅ |
| 372 | Identity function (return same value) | Medium | Medium | Low | — | ✅ |
| 373 | Constant function (always return same value) | Medium | Low | Low | — | ✅ |
| 374 | Timed (measure duration of sync call) | Medium | Medium | Low | ✅ | ✅ |
| 375 | Retry until (repeat until predicate, max N) | Medium | Medium | Low | ✅ | ✅ |

---

## Niche / domain — More (15 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 376 | Hex dump (bytes to readable hex + ASCII) | Low | Low | Medium | ✅ | ✅ |
| 377 | Parse hex string to bytes (Uint8List) | High | High | Low | ✅ | ✅ |
| 378 | Bytes to hex string | High | High | Low | ✅ | ✅ |
| 379 | Mask credit card (show last 4) | High | High | Low | ✅ | ✅ |
| 380 | Format phone for display (add spaces/dashes) | High | High | Medium | ✅ | ✅ |
| 381 | Strip control characters (ASCII 0–31) | High | Medium | Low | ✅ | ✅ |
| 382 | Is ASCII only | High | High | Low | ✅ | ✅ |
| 383 | Truncate to byte length (UTF-8 safe) | High | High | Medium | ✅ | ✅ |
| 384 | Word boundary split (for search highlighting) | Medium | Medium | Medium | ✅ | ✅ |
| 385 | Highlight matches (wrap matches in tag/string) | High | High | Low | ✅ | ✅ |
| 386 | Levenshtein ratio (distance / max length) | High | High | Low | ✅ | ✅ |
| 387 | Jaro–Winkler similarity | Medium | Medium | High | ✅ | ✅ |
| 388 | N-grams (character or word) | Medium | Medium | Medium | ✅ | ✅ |
| 389 | Prefix/suffix array (for string search) | Low | Low | High | ✅ | ✅ |
| 390 | Damerau–Levenshtein (with transposition) | Medium | Medium | High | ✅ | ✅ |

---

## Lower priority / polish — More (10 ideas)

| # | Idea | Usefulness | Importance | Complexity | Size | Done |
|---|------|------------|------------|------------|------|------|
| 391 | Trim to length (substring from start) | High | Medium | Low | — | ✅ |
| 392 | Ensure suffix (add if missing) | High | Medium | Low | — | ✅ |
| 393 | Ensure prefix (add if missing) | High | Medium | Low | — | ✅ |
| 394 | Remove suffix (if present) | High | High | Low | — | ✅ |
| 395 | Remove prefix (if present) | High | High | Low | — | ✅ |
| 396 | Second / third element (safe) | High | Medium | Low | — | ✅ |
| 397 | Single element or null (list of 1 → element) | High | High | Low | — | ✅ |
| 398 | To set (from iterable) | High | High | Low | — | ✅ |
| 399 | To list (from iterable; for API consistency) | High | Medium | Low | — | ✅ |
| 400 | Default empty string/list/map for null | High | High | Low | — | ✅ |

---

## Summary

- **Total ideas:** 400  
- **Marked as “reduces app size” (✅):** 250+ (complex/algorithmic or common boilerplate).  
- **Tree-shaking:** Non-negotiable. Every new addition must be in a small, directly importable file with no global state.

**Suggested implementation order:** Start with high usefulness + high importance + ✅ size impact (e.g. groupBy, sortBy, deep merge, LRU cache, debounce/throttle, Levenshtein, CSV parse, relative time, format duration, business days). Then fill in parsing/validation and number/collection algorithms. Keep each feature in its own file and document direct imports in the README.
