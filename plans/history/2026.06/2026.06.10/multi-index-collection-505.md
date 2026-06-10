# Multi-index collection (roadmap #505)

Item 6 of the second "next 10" roadmap-utilities batch. An in-memory table maintaining several secondary indexes for O(1) lookup by different keys — what a list scanned by multiple fields otherwise costs O(n) per query.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/collections/multi_index_collection_utils.dart` (`MultiIndexCollection<T>`), new test, barrel export, CHANGELOG entry.

**Design:** constructed with named key extractors (`{'email': (u) => u.email, ...}`, ≥1 required). Holds a master `List<T>` plus, per index, a `Map<Object, List<T>>` (non-unique: a key maps to a bucket of items). `add` appends to the master list and pushes the item into each index's bucket; `remove` (matched by `==`) drops it from the master list and every bucket, pruning a bucket that becomes empty so the index doesn't accumulate dead keys. `getBy` returns an unmodifiable matching list (empty if absent, throws on unknown index name), `getOneBy` the first match (unique-index convenience), `containsKey` tests presence. `all` is an unmodifiable view.

**Distinction from existing utils:** `buildInvertedIndex` is a text term→document search index; `row_column_table_utils` transposes row/column shape. Neither maintains live, mutable, multi-key record indexes — this does. No overlap.

**Documented constraints:** index keys must be non-null and stable while the item is in the collection (mutating an indexed field after insert desyncs the index — remove then re-add). `remove` uses `==`, so value-equal items are interchangeable for removal.

**Tests:** 8 cases — require-≥1-index assert, lookup by each of three indexes (incl. a non-unique city bucket returning both users), empty-list/null/false for absent keys, unknown-index throws, remove keeps all indexes in sync, empty-bucket pruning, false-on-absent-remove, and `all`/`indexNames` exposure with an unmodifiable-`all` guard. All pass; `flutter analyze` clean.

**Reviewer notes:** `add`/`remove` iterate `_indexers.entries` and null-check `_indexes[name]` rather than using `!` (nullable-safe-accessor rule). The IDE's `prefer_correct_callback_field_name` Info on the extractor-map field is not in the project tier (`flutter analyze` clean). Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
