/// Diff two lists: added, removed, unchanged.
extension IterableDiffExtensions<T> on Iterable<T> {
  /// Returns (added, removed, unchanged) relative to [other]. Uses [Object.==].
  /// Audited: 2026-06-12 11:26 EDT
  (List<T> added, List<T> removed, List<T> unchanged) diff(Iterable<T> other) {
    // Convert both sides to sets so membership tests are constant-time and the
    // three categories below are a single linear scan each, not a quadratic
    // nested comparison. Note the
    // consequence: duplicates collapse and original ordering is lost — diff is
    // defined over the distinct element sets, compared by Object.==.
    final Set<T> thisSet = toSet();
    final Set<T> otherSet = other.toSet();
    // added = in other but not this; removed = in this but not other;
    // unchanged = the intersection.
    final List<T> added = otherSet.where((T x) => !thisSet.contains(x)).toList();
    final List<T> removed = thisSet.where((T x) => !otherSet.contains(x)).toList();
    final List<T> unchanged = thisSet.where((T x) => otherSet.contains(x)).toList();
    return (added, removed, unchanged);
  }
}
