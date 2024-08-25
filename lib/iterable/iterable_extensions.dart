import 'dart:collection';

/// Extension on Iterable to provide additional properties and methods for lists
/// containing elements that implement Comparable.
extension IterableExtensions<T extends Comparable<T>> on Iterable<T> {
  /// Finds the smallest occurrence in the list.
  ///
  /// Returns the smallest element in the list based on the Comparable
  /// implementation.
  T? smallestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce(
      (T value, T element) => value.compareTo(element) < 0 ? value : element,
    );
  }

  /// Finds the biggest occurrence in the list.
  ///
  /// Returns the biggest element in the list based on the Comparable
  /// implementation.
  T? biggestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce(
      (T value, T element) => value.compareTo(element) > 0 ? value : element,
    );
  }

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
    final frequencyMap = HashMap<T, int>();

    // Iterate over each integer in the list.
    for (final item in this) {
      // Update the frequency of the current integer in the map, or set it to
      //   1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // NOTE: reduce throws an error if it’s used on an empty list, while fold
    // does not. This makes fold a safer choice if the list might be empty.

    // Find and return the key with the highest value (frequency) in the map.
    final mostCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<T, int>? previous, MapEntry<T, int> element) =>
          previous == null || element.value > previous.value
              ? element
              : previous,
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
    final frequencyMap = HashMap<T, int>();

    // Iterate over each integer in the list.
    for (final item in this) {
      // Update the frequency of the current integer in the map,
      // or set it to 1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Find and return the key with the highest value (frequency) in the map.
    final leastCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<T, int>? previous, MapEntry<T, int> element) =>
          previous == null || element.value < previous.value
              ? element
              : previous,
    );

    if (leastCommonEntry == null) {
      return null;
    }

    // Return a tuple with the most common value and its frequency.
    return (leastCommonEntry.key, leastCommonEntry.value);
  }
}
