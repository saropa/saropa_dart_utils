import 'dart:collection';

/// Saropa extensions for [List]s of [bool]s
///
extension BoolIterableExtensions on Iterable<bool> {
  /// Finds the most common value in the list.
  ///
  /// Returns a record (tuple) containing the most common value and its
  /// frequency.
  /// If the list is empty, returns null.
  (bool, int)? mostOccurrences() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each boolean and its frequency.
    final frequencyMap = HashMap<bool, int>();

    // Iterate over each boolean in the list.
    for (final item in this) {
      // Update the frequency of the current boolean in the map, or
      // set it to 1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Find the key-value pair with the highest value (frequency) in the map.
    final mostCommonEntry = frequencyMap.entries.reduce(
      (MapEntry<bool, int> a, MapEntry<bool, int> b) =>
          a.value > b.value ? a : b,
    );

    // Return a tuple with the most common value and its frequency.
    return (mostCommonEntry.key, mostCommonEntry.value);
  }

  /// Finds the least common value in the list.
  ///
  /// Returns a record (tuple) containing the least common value and its
  /// frequency.
  /// If the list is empty, returns null.
  (bool, int)? leastOccurrences() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each boolean and its frequency.
    final frequencyMap = HashMap<bool, int>();
    // Iterate over each boolean in the list.
    for (final item in this) {
      // Update the frequency of the current boolean in the map, or
      // set it to 1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Find the key-value pair with the lowest value (frequency) in the map.
    final leastCommonEntry = frequencyMap.entries.reduce(
      (MapEntry<bool, int> a, MapEntry<bool, int> b) =>
          a.value < b.value ? a : b,
    );

    // Return a tuple with the least common value and its frequency.
    return (leastCommonEntry.key, leastCommonEntry.value);
  }

  /// Checks if any element in the iterable is `true`.
  ///
  /// This getter iterates through each element in the iterable. If it
  /// encounters an element that is `true`, it returns `true`. If no such
  /// element is found after iterating through all elements, it returns
  /// `false`.
  ///
  /// Returns:
  /// - `true` if at least one element in the iterable is `true`.
  /// - `false` if no elements in the iterable are `true` or the iterable
  ///  is empty.
  bool get anyTrue {
    return where((bool e) => e).isNotEmpty;
  }

  /// Checks if any element in the iterable is `false`.
  ///
  /// This getter iterates through each element in the iterable. If it
  /// encounters an element that is `false`, it returns `true`. If no such
  /// element is found after iterating through all elements, it returns
  /// `false`.
  ///
  /// Returns:
  /// - `true` if at least one element in the iterable is `false`.
  /// - `false` if no elements in the iterable are `false` or the iterable is
  ///  empty.
  bool get anyFalse {
    return where((bool e) => !e).isNotEmpty;
  }

  /// Counts the number of `true` values in the iterable.
  ///
  /// This getter iterates through each element in the iterable and increments
  /// a counter each time it encounters a `true` value. The final count is
  /// returned.
  ///
  /// Returns:
  /// - The number of `true` values in the iterable.
  int get countTrue {
    return where((bool e) => e).length;
  }

  /// Counts the number of `false` values in the iterable.
  ///
  /// This getter iterates through each element in the iterable and increments
  /// a counter each time it encounters a `false` value. The final count is
  /// returned.
  ///
  /// Returns:
  /// - The number of `false` values in the iterable.
  int get countFalse {
    return where((bool e) => !e).length;
  }

  /// Reverses the boolean values in the list.
  ///
  /// This method iterates through each element in the list and flips its
  /// value. If the element is `true`, it becomes `false`, and vice versa.
  /// A new list with the reversed values is returned.
  ///
  /// Returns:
  /// - A new list with the boolean values reversed.
  List<bool> get reverse {
    return map((b) => !b).toList();
  }
}
