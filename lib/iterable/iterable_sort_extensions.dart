import 'package:meta/meta.dart';

/// Sort by multiple keys (thenBy).
extension IterableSortByExtensions<T> on Iterable<T> {
  /// Sorts by [keyOf] then by [thenBy] if present. Returns new list.
  @useResult
  List<T> sortByThenBy<K extends Comparable<K>>(
    K Function(T) keyOf, [
    int Function(T a, T b)? thenBy,
  ]) {
    final List<T> list = toList();
    list.sort((T a, T b) {
      final int c = keyOf(a).compareTo(keyOf(b));
      if (c != 0) return c;
      if (thenBy == null) return 0;
      return thenBy(a, b);
    });
    return list;
  }
}
