/// Safe mutation-during-iteration for lists. Closes the suite's
/// `concurrent-modification` crash family (Suite Integration plan, R3):
/// adding to or removing from a list inside a plain `for-in` over that same
/// list throws `ConcurrentModificationError`.
library;

/// Iterating a list while mutating it from the loop body.
extension ListMutateDuringIterationExtensions<T> on List<T> {
  /// Runs [action] for each element of a point-in-time snapshot of this list,
  /// so [action] may safely add to or remove from this list during iteration.
  ///
  /// A plain `for (final e in list) { list.remove(e); }` throws
  /// `ConcurrentModificationError` because the iterator detects the length
  /// change mid-walk. This takes one snapshot up front (`List<T>.of(this)`) and
  /// walks the snapshot, so structural edits to the original never invalidate
  /// the iterator.
  ///
  /// Snapshot semantics — important and easy to get wrong:
  /// - Elements **added** by [action] are NOT visited this pass (they are not in
  ///   the snapshot).
  /// - Elements **removed** by [action] are still visited if they were present
  ///   when the snapshot was taken — `action` sees the element even though it is
  ///   already gone from the original.
  /// - Visit order is the snapshot order at call time.
  ///
  /// For a pure conditional removal with no other effect, prefer the built-in
  /// `removeWhere` — it is a single in-place pass with no snapshot copy. Reach
  /// for this when the body does work AND mutates (e.g. process an item, then
  /// remove or enqueue more).
  ///
  /// Example:
  /// ```dart
  /// final queue = <int>[1, 2, 3, 4];
  /// queue.forEachSnapshot((n) {
  ///   if (n.isEven) queue.remove(n); // safe: no ConcurrentModificationError
  /// });
  /// // queue is now [1, 3]
  /// ```
  void forEachSnapshot(void Function(T element) action) {
    // Copy once; an empty list yields an empty snapshot and a no-op walk.
    for (final T element in List<T>.of(this)) {
      action(element);
    }
  }
}
