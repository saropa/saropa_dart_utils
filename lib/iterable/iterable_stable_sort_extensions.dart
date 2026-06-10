import 'package:meta/meta.dart';

/// Stable sorting that preserves the input order of equal elements.
///
/// Dart's `List.sort` is NOT guaranteed stable — equal elements may be
/// reordered, which silently corrupts multi-pass sorts (sort by date, then by
/// name, expecting same-name rows to stay in date order). These methods break
/// ties by original index, so equal elements keep their relative order.
extension IterableStableSortExtensions<T> on Iterable<T> {
  /// Returns a new list sorted by [keyOf], keeping equal-key elements in their
  /// original relative order.
  ///
  /// Example:
  /// ```dart
  /// // Two rows with key 1 stay in input order.
  /// [(1,'a'), (2,'x'), (1,'b')].stableSortBy((r) => r.$1);
  /// // [(1,'a'), (1,'b'), (2,'x')]
  /// ```
  @useResult
  List<T> stableSortBy<K extends Comparable<K>>(K Function(T) keyOf) =>
      stableSort((T a, T b) => keyOf(a).compareTo(keyOf(b)));

  /// Returns a new list sorted by [compare], keeping elements that compare
  /// equal in their original relative order.
  ///
  /// Implemented by decorating each element with its original index and using
  /// that index as the tie-breaker — the standard way to make any comparator
  /// stable regardless of the underlying sort algorithm.
  @useResult
  List<T> stableSort(Comparator<T> compare) {
    final List<T> source = toList();
    final List<int> order = List<int>.generate(source.length, (int i) => i);
    order.sort((int i, int j) {
      final int byValue = compare(source[i], source[j]);
      // Equal by the caller's comparator: fall back to original index so the
      // earlier element stays earlier.
      return byValue != 0 ? byValue : i.compareTo(j);
    });
    return <T>[for (final int i in order) source[i]];
  }
}
