# Interval tree for overlap queries (roadmap #494)

Item 9 of the "next 10" roadmap-utilities batch. A data structure answering "which intervals contain this point / overlap this range?" in logarithmic time — the lookup index the existing interval utilities don't provide.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/collections/interval_tree_utils.dart` (`IntervalTree<T>`, `IntervalEntry<T>`), new test, barrel export, CHANGELOG entry.

**Design:** an augmented balanced BST keyed by interval `low`, each node carrying `maxHigh` (the largest `high` in its subtree). Built once by median split of the sorted entries (`O(n log n)` build, `O(log n)` height). Stabbing/overlap queries run `O(log n + k)`: `_collect` recurses left only while the subtree's `maxHigh >= queryLow` (else nothing there reaches the query) and recurses right only while the node's `low <= queryHigh` (else all right intervals start too late). `queryPoint(x)` is the degenerate `queryRange(x, x)`. `hasOverlap` shares the pruning but returns on the first hit. Results are in ascending `low` order (in-order traversal of a low-keyed BST).

**Inclusivity:** `[low, high]` is inclusive on both ends, so boundary touches count as overlap (`[10,15]` overlaps an interval ending at 10 and one starting at 15) — tested explicitly. `IntervalEntry` asserts `low <= high`.

**Distinction from existing interval utils:** `IntervalSchedulingUtils` selects a maximum non-overlapping subset; `weightedIntervals` is a weighted-DP optimizer. Neither indexes for overlap lookup. No overlap; added alongside.

**Tests:** 14 cases — `IntervalEntry` containment/overlap inclusivity; tree size/emptiness; `queryPoint` (multi-match in low order, boundary touch, single match, gap, beyond-all); `queryRange` (multi-overlap, boundary touch, gap); `hasOverlap` true/false; an inverted-entry assertion; and a brute-force oracle test comparing `queryPoint` to a linear filter across 113 points over 50 overlapping intervals. All pass; `flutter analyze` clean.

**Reviewer notes:** the recursive helpers are instance (not static) methods so they use the class `T` directly — static generics re-declaring `<T>` tripped `avoid_shadowing_type_parameters`. `queryPoint`'s `queryRange(point, point)` carries an `// ignore: no_equal_arguments` with rationale (a point stab IS the degenerate range). `_Node.maxHigh` is seeded to `entry.high` in the constructor (no `late`) and finalized bottom-up during build. Functions ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
