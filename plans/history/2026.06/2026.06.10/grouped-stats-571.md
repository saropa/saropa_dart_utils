# Grouped numeric statistics (roadmap #571)

Item 5 of the "next 5" roadmap-utilities batch. Adds a one-pass per-key numeric stat bundle, distinct from #477's custom-reducer `aggregateByKeys`.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/stats/grouped_stats_utils.dart` (`NumericStats`, `groupedStats`), new test, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** `groupedStats(items, keyOf:, valueOf:)` groups by key and accumulates count/sum/min/max into a private `_Acc` in a single pass (`putIfAbsent(...).add(...)`), then maps each accumulator to an immutable `NumericStats` (adding `mean = sum / count`). A key exists only if ≥ 1 item maps to it, so every `NumericStats` has `count ≥ 1` — no divide-by-zero. `_Acc.min/max` are seeded to 0 but the first `add` overwrites both before any read (documented on the class), avoiding a null-assertion.

**Distinction from #477:** `aggregateByKeys` takes a caller-supplied reducer for arbitrary aggregates; `groupedStats` is the ready-made numeric descriptive bundle for the common "totals and averages per category" report. Different ergonomics, no overlap.

**Tests:** 4 cases — two-key count/sum/min/max/mean, single-value group (min==max==mean), negative values, empty input. All pass; `flutter analyze` clean.

**Reviewer notes:** `NumericStats` immutable with value equality (eases assertions). No unsafe accessors; `_Acc` seed rationale documented to justify the non-null fields. Class doc on `_Acc` resolves the `prefer_doc_comments_over_regular` info that an inline `//` above a field triggered.

No bug archive — task did not close a bugs/*.md file.
