/// Min/max by key (return element).
extension IterableMinMaxByExtensions<T> on Iterable<T> {
  /// Element with minimum [keyOf] value; null if empty.
  T? minBy<K extends Comparable<K>>(K Function(T) keyOf) {
    T? minElem;
    K? minKey;
    for (final T element in this) {
      final K key = keyOf(element);
      if (minKey == null || key.compareTo(minKey) < 0) {
        minKey = key;
        minElem = element;
      }
    }
    return minElem;
  }

  /// Element with maximum [keyOf] value; null if empty.
  T? maxBy<K extends Comparable<K>>(K Function(T) keyOf) {
    T? maxElem;
    K? maxKey;
    for (final T element in this) {
      final K key = keyOf(element);
      if (maxKey == null || key.compareTo(maxKey) > 0) {
        maxKey = key;
        maxElem = element;
      }
    }
    return maxElem;
  }
}
