import 'dart:collection';

extension UniqueIterableExtensions<T> on Iterable<T> {
  /// LinkedHashSet retains ordering
  /// NOTE: Removes null elements by default.
  List<T> toUnique({bool ignoreNulls = true}) =>
      LinkedHashSet<T>.from(where((T? e) => !ignoreNulls || e != null)).toList();
}

extension UniqueListExtensionsUniqueBy<T> on List<T> {
  /// Returns a new list with unique elements based on the provided key extractor.
  /// When duplicates are found, the LAST element from the original list is kept.
  /// The relative order of the kept elements is preserved.
  /// If [ignoreNullKeys] is true (default), items where the key is null will be removed.
  List<T> toUniqueBy<E>(E Function(T) keyExtractor, {bool ignoreNullKeys = true}) {
    if (isEmpty || length == 1) {
      return List<T>.from(this);
    }

    final Map<E, int> lastIndices = <E, int>{};

    // 1. Iterate backwards to find the index of the LAST occurrence of each key.
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

  /// Modifies the original list to contain only unique elements based on the provided key extractor.
  /// When duplicates are found, the LAST element from the original list is kept.
  /// If [ignoreNullKeys] is true (default), items where the key is null will be removed.
  void toUniqueByInPlace<E>(E Function(T) keyExtractor, {bool ignoreNullKeys = true}) {
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
