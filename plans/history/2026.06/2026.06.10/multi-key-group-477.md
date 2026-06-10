# Multi-key group/aggregate (roadmap #477)

Item 5 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch. Extends the existing single-key `groupBy` to grouping (and reducing) by several keys at once, the analytics staple for pivot-style roll-ups.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/collections/multi_key_group_utils.dart` (`MultiKey`, `groupByKeys`, `aggregateByKeys`), new test, barrel export, CODE_INDEX rows, CHANGELOG entry.

**Design:** `MultiKey` wraps the ordered selector values and gives them value equality via `ListEquality` (from the existing `collection` dep) + `Object.hashAll`, so a tuple like `(country, year)` works as a `Map` key where a raw `List` (identity equality) would not. `groupByKeys(items, keys)` applies every selector and buckets rows via `putIfAbsent` (preserving first-seen order). `aggregateByKeys(items, keys, aggregator)` reduces each bucket — count, sum, average, anything.

**Tests:** 6 cases — MultiKey value-equality/hash/inequality, two-key bucketing, single-key behaves like normal group-by, empty input, count aggregation, field-sum aggregation. All pass; `flutter analyze` clean.

**Reviewer notes:** Reuses `collection.ListEquality` and `meta.@immutable` (both existing deps) rather than hand-rolling equality. `putIfAbsent` avoids a nested-assignment lint. No unsafe accessors.

No bug archive — task did not close a bugs/*.md file.
