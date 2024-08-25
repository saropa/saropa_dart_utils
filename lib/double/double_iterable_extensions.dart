import 'dart:collection';

/// Extension on List<double> to provide additional properties and methods
/// specifically for lists of doubles.
extension DoubleIterableExtensions on Iterable<double> {
  /// Finds the smallest occurrence in the list.
  ///
  /// Returns the smallest element in the list based on the Comparable
  /// implementation.
  double? smallestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce(
      (double value, double element) =>
          value.compareTo(element) < 0 ? value : element,
    );
  }

  /// Finds the biggest occurrence in the list.
  ///
  /// Returns the biggest element in the list based on the Comparable
  /// implementation.
  double? biggestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce(
      (double value, double element) =>
          value.compareTo(element) > 0 ? value : element,
    );
  }

  /// Finds the most common value in the list.
  ///
  /// Returns a record (tuple) containing the most common value and its
  /// frequency.
  /// If the list is empty, returns null.
  (double, int)? mostOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each double and its frequency.
    final frequencyMap = HashMap<double, int>();

    // Iterate over each double in the list.
    for (final item in this) {
      // Update the frequency of the current double in the map, or set it to
      // 1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Find and return the key with the highest value (frequency) in the map.
    final mostCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<double, int>? previous, MapEntry<double, int> element) =>
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

  /// Finds the least common value in the list.
  ///
  /// Returns a record (tuple) containing the least common value and its
  /// frequency.
  /// If the list is empty, returns null.
  (double, int)? leastOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each double and its frequency.
    final frequencyMap = HashMap<double, int>();

    // Iterate over each double in the list.
    for (final item in this) {
      // Update the frequency of the current double in the map,
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
      (MapEntry<double, int>? previous, MapEntry<double, int> element) =>
          previous == null || element.value < previous.value
              ? element
              : previous,
    );

    if (leastCommonEntry == null) {
      return null;
    }

    // Return a tuple with the least common value and its frequency.
    return (leastCommonEntry.key, leastCommonEntry.value);
  }
}
