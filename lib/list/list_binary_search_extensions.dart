const String _kErrTMustImplementComparable = 'T must implement Comparable';

/// Binary search and merge sorted on lists.
extension ListBinarySearchExtensions<T> on List<T> {
  /// Returns the index of [value] in this sorted list, or -1 if not found.
  ///
  /// [compare] must be consistent with the list's sort order. Defaults to [Comparable.compare].
  /// List must be sorted in ascending order.
  int binarySearchIndex(T value, [int Function(T a, T b)? compare]) {
    final int Function(T a, T b) cmp =
        compare ??
        (T a, T b) => a is Comparable<dynamic>
            ? a.compareTo(b)
            : (throw ArgumentError(_kErrTMustImplementComparable));
    int low = 0;
    int high = length;
    while (low < high) {
      final int mid = (low + high) >> 1;
      final int c = cmp(this[mid], value);
      if (c < 0) {
        low = mid + 1;
      } else if (c > 0) {
        high = mid;
      } else {
        return mid;
      }
    }
    return -1;
  }

  /// Returns the insertion point for [value] (index where it would be inserted to preserve order).
  ///
  /// [compare] must be consistent with the list's sort order.
  int binarySearchInsertPoint(T value, [int Function(T a, T b)? compare]) {
    final int Function(T a, T b) cmp =
        compare ??
        (T a, T b) => a is Comparable<dynamic>
            ? a.compareTo(b)
            : (throw ArgumentError(_kErrTMustImplementComparable));
    int low = 0;
    int high = length;
    while (low < high) {
      final int mid = (low + high) >> 1;
      if (cmp(this[mid], value) < 0) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }
}

/// Merge two sorted lists into one sorted list.
List<T> mergeSorted<T>(List<T> a, List<T> b, [int Function(T a, T b)? compare]) {
  final int Function(T a, T b) cmp =
      compare ??
      (T a, T b) => a is Comparable<dynamic>
          ? a.compareTo(b)
          : (throw ArgumentError(_kErrTMustImplementComparable));
  final List<T> result = <T>[];
  int i = 0;
  int j = 0;
  while (i < a.length && j < b.length) {
    if (cmp(a[i], b[j]) <= 0) {
      result.add(a[i++]);
    } else {
      result.add(b[j++]);
    }
  }
  while (i < a.length) result.add(a[i++]);
  while (j < b.length) result.add(b[j++]);
  return result;
}
