import 'dart:collection';

extension GeneralIterableExtensions<T> on Iterable<T> {
  /// Finds the most common value in the list.
  ///
  /// Returns a record (tuple) containing the most common value and its
  ///  frequency.
  /// If the list is empty, returns null.
  (T, int)? mostOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final HashMap<T, int> frequencyMap = HashMap<T, int>();

    // Iterate over each integer in the list.
    for (final T item in this) {
      // Update the frequency of the current integer in the map, or set it to
      //   1 if it's not in the map yet.
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // NOTE: reduce throws an error if it’s used on an empty list, while fold
    // does not. This makes fold a safer choice if the list might be empty.

    // Find and return the key with the highest value (frequency) in the map.
    final MapEntry<T, int>? mostCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<T, int>? previous, MapEntry<T, int> element) =>
          previous == null || element.value > previous.value ? element : previous,
    );
    if (mostCommonEntry == null) {
      return null;
    }

    // Return a tuple with the most common value and its frequency.
    return (mostCommonEntry.key, mostCommonEntry.value);
  }

  /// Find the most common value in the list.
  (T, int)? leastOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final HashMap<T, int> frequencyMap = HashMap<T, int>();

    // Iterate over each integer in the list.
    for (final T item in this) {
      // Update the frequency of the current integer in the map,
      // or set it to 1 if it's not in the map yet.
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // Find and return the key with the highest value (frequency) in the map.
    final MapEntry<T, int>? leastCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<T, int>? previous, MapEntry<T, int> element) =>
          previous == null || element.value < previous.value ? element : previous,
    );

    if (leastCommonEntry == null) {
      return null;
    }

    // Return a tuple with the most common value and its frequency.
    return (leastCommonEntry.key, leastCommonEntry.value);
  }

  /// Returns a random element from this iterable.
  ///
  /// Returns null if the iterable is empty.
  T? randomElement() {
    if (isEmpty) return null;
    final int index = DateTime.now().microsecondsSinceEpoch % length;
    return elementAt(index);
  }

  /// Returns true if this iterable contains all elements from [other].
  bool containsAll(Iterable<T> other) {
    for (final T element in other) {
      if (!contains(element)) return false;
    }
    return true;
  }

  /// Counts elements that satisfy the given [predicate].
  int countWhere(bool Function(T) predicate) {
    int count = 0;
    for (final T element in this) {
      if (predicate(element)) count++;
    }
    return count;
  }
}
