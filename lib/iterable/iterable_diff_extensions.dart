/// Diff two lists: added, removed, unchanged.
extension IterableDiffExtensions<T> on Iterable<T> {
  /// Returns (added, removed, unchanged) relative to [other]. Uses [Object.==].
  (List<T> added, List<T> removed, List<T> unchanged) diff(Iterable<T> other) {
    final Set<T> thisSet = toSet();
    final Set<T> otherSet = other.toSet();
    final List<T> added = otherSet.where((T x) => !thisSet.contains(x)).toList();
    final List<T> removed = thisSet.where((T x) => !otherSet.contains(x)).toList();
    final List<T> unchanged = thisSet.where((T x) => otherSet.contains(x)).toList();
    return (added, removed, unchanged);
  }
}
