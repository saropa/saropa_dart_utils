/// Multi-criteria sort with weighted comparators — roadmap #462.
library;

/// Returns a new list with [list]'s elements sorted by [compare].
/// The original [list] is not modified.
List<T> sortByCriteria<T>(List<T> list, int Function(T a, T b) compare) {
  final copy = list.toList();
  copy.sort(compare);
  return copy;
}

/// Builds a comparator that uses [primary] and then [thenByCompare] for ties.
int Function(T, T) thenBy<T>(int Function(T, T) primary, int Function(T, T) thenByCompare) {
  return (T a, T b) {
    final int p = primary(a, b);
    return p != 0 ? p : thenByCompare(a, b);
  };
}
