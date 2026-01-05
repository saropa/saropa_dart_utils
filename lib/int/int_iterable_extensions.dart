import 'dart:collection';

/// NOTE: Dart’s type system doesn’t consider int to be a subtype of
///       Comparable&lt;int&gt;, even though int does implement
///       Comparable&lt;num&gt;
///
extension IntIterableExtensions on Iterable<int> {
  /// find the most common value in the list.
  (int, int)? mostOccurrences() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final HashMap<int, int> frequencyMap = HashMap<int, int>();

    // Iterate over each integer in the list.
    for (final int item in this) {
      // Update the frequency of the current integer in the map, or
      // set it to 1 if it's not in the map yet.
      // ignore: require_future_error_handling
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // Find the key-value pair with the highest value (frequency) in the map.
    // The map is guaranteed non-empty since we checked isEmpty above.
    MapEntry<int, int>? mostCommonEntry;
    for (final MapEntry<int, int> entry in frequencyMap.entries) {
      if (mostCommonEntry == null || entry.value > mostCommonEntry.value) {
        mostCommonEntry = entry;
      }
    }

    // Return a tuple with the most common value and its frequency.
    // mostCommonEntry is guaranteed non-null since the list is non-empty.
    return mostCommonEntry == null ? null : (mostCommonEntry.key, mostCommonEntry.value);
  }

  /// find the most common value in the list.
  (int, int)? leastOccurrences() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final HashMap<int, int> frequencyMap = HashMap<int, int>();
    // Iterate over each integer in the list.
    for (final int item in this) {
      // Update the frequency of the current integer in the map, or
      // set it to 1 if it's not in the map yet.
      // ignore: require_future_error_handling
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // Find the key-value pair with the lowest value (frequency) in the map.
    // The map is guaranteed non-empty since we checked isEmpty above.
    MapEntry<int, int>? leastCommonEntry;
    for (final MapEntry<int, int> entry in frequencyMap.entries) {
      if (leastCommonEntry == null || entry.value < leastCommonEntry.value) {
        leastCommonEntry = entry;
      }
    }

    // Return a tuple with the least common value and its frequency.
    // leastCommonEntry is guaranteed non-null since the list is non-empty.
    return leastCommonEntry == null ? null : (leastCommonEntry.key, leastCommonEntry.value);
  }
}
