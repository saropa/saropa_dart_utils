import 'dart:collection';

/// NOTE: Dart’s type system doesn’t consider int to be a subtype of
///       Comparable<int>, even though int does implement Comparable<num>
///
extension IntIterableExtensions on Iterable<int> {
  /// find the most common value in the list.
  (int, int)? mostOccurrences() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final frequencyMap = HashMap<int, int>();

    // Iterate over each integer in the list.
    for (final item in this) {
      // Update the frequency of the current integer in the map, or
      // set it to 1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Find the key-value pair with the highest value (frequency) in the map.
    final mostCommonEntry = frequencyMap.entries.reduce(
      (MapEntry<int, int> a, MapEntry<int, int> b) => a.value > b.value ? a : b,
    );

    // Return a tuple with the most common value and its frequency.
    return (mostCommonEntry.key, mostCommonEntry.value);
  }

  /// find the most common value in the list.
  (int, int)? leastOccurrences() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final frequencyMap = HashMap<int, int>();
    // Iterate over each integer in the list.
    for (final item in this) {
      // Update the frequency of the current integer in the map, or
      // set it to 1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Find the key-value pair with the highest value (frequency) in the map.
    final mostCommonEntry = frequencyMap.entries.reduce(
      (MapEntry<int, int> a, MapEntry<int, int> b) => a.value < b.value ? a : b,
    );

    // Return a tuple with the most common value and its frequency.
    return (mostCommonEntry.key, mostCommonEntry.value);
  }
}
