import 'dart:collection';
import 'package:meta/meta.dart';

/// Extracts a key of type [E] from an element of type [T].
typedef KeyExtractor<T, E> = E Function(T element);

extension UniqueIterableExtensions<T> on Iterable<T> {
  /// Returns a new list with duplicate elements removed, preserving order.
  ///
  /// Uses a [LinkedHashSet] to retain ordering. If [ignoreNulls] is `true`
  /// (default), null elements are also removed.
  @useResult
  List<T> toUnique({bool ignoreNulls = true}) =>
      LinkedHashSet<T>.of(where((T? e) => !ignoreNulls || e != null)).toList();
}

extension UniqueListExtensionsUniqueBy<T> on List<T> {
  /// Returns a new list with unique elements based on the provided
  /// [keyExtractor] function.
  ///
  /// When duplicates are found, the LAST element from the original list is
  /// kept. The relative order of the kept elements is preserved.
  /// If [ignoreNullKeys] is `true` (default), items where the key is `null`
  /// will be removed.
  @useResult
  List<T> toUniqueBy<E>(KeyExtractor<T, E> keyExtractor, {bool ignoreNullKeys = true}) {
    if (isEmpty || length == 1) {
      return List<T>.of(this);
    }

    // 1. Iterate backwards to find the index of the LAST occurrence of each key.
    final Map<E, int> lastIndices = <E, int>{};
    for (int i = length - 1; i >= 0; i--) {
      final T item = this[i];
      final E key = keyExtractor(item);

      if (ignoreNullKeys && key == null) {
        continue;
      }

      // Since we iterate backwards, the first time we see a key, it's the
      // last occurrence in the list. putIfAbsent ensures we only store it once.
      // ignore: require_future_error_handling
      lastIndices.putIfAbsent(key, () => i);
    }

    // 2. The values of the map are the indices of the items we need to keep.
    final List<int> indicesToKeep = lastIndices.values.toList();

    // 3. Sort the indices to restore the original relative order.
    indicesToKeep.sort();

    // 4. Build the final list from the sorted indices.
    return indicesToKeep.map((int index) => this[index]).toList();
  }

  /// Modifies the original list to contain only unique elements based on the
  /// provided [keyExtractor] function.
  ///
  /// When duplicates are found, the LAST element from the original list is
  /// kept. If [ignoreNullKeys] is `true` (default), items where the key is
  /// `null` will be removed.
  void toUniqueByInPlace<E>(KeyExtractor<T, E> keyExtractor, {bool ignoreNullKeys = true}) {
    if (isEmpty || length == 1) {
      return;
    }

    // Use the non-in-place version to calculate the correct list.
    final List<T> uniqueItems = toUniqueBy(keyExtractor, ignoreNullKeys: ignoreNullKeys);

    // Replace the content of the current list.
    clear();
    addAll(uniqueItems);
  }
}
