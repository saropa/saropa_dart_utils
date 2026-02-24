import 'dart:collection';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/iterable/occurrence.dart';

/// A function that tests whether an element of type [T] satisfies a condition.
typedef ElementPredicate<T> = bool Function(T element);

// Module-level instance avoids allocating a new Random on every randomElement() call.
final Random _random = Random();

extension GeneralIterableExtensions<T extends Object> on Iterable<T> {
  /// Finds the most common value in the list.
  ///
  /// Returns an [Occurrence] containing the most common value and its
  ///  frequency.
  /// If the list is empty, returns null.
  @useResult
  Occurrence<T>? mostOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final HashMap<T, int> frequencyMap = HashMap<T, int>();

    // Iterate over each integer in the list.
    for (final T item in this) {
      // Update the frequency of the current integer in the map, or set it to
      //   1 if it's not in the map yet.
      // ignore: require_future_error_handling
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

    return Occurrence<T>(mostCommonEntry.key, mostCommonEntry.value);
  }

  /// Returns an [Occurrence] of the least common value and its frequency,
  /// or `null` if the iterable is empty.
  @useResult
  Occurrence<T>? leastOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each integer and its frequency.
    final HashMap<T, int> frequencyMap = HashMap<T, int>();

    // Iterate over each integer in the list.
    for (final T item in this) {
      // Update the frequency of the current integer in the map,
      // or set it to 1 if it's not in the map yet.
      // ignore: require_future_error_handling
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // Find and return the key with the lowest value (frequency) in the map.
    final MapEntry<T, int>? leastCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<T, int>? previous, MapEntry<T, int> element) =>
          previous == null || element.value < previous.value ? element : previous,
    );

    if (leastCommonEntry == null) {
      return null;
    }

    return Occurrence<T>(leastCommonEntry.key, leastCommonEntry.value);
  }

  /// Returns a random element from this iterable.
  ///
  /// Returns null if the iterable is empty.
  @useResult
  T? randomElement() {
    if (isEmpty) {
      return null;
    }

    return elementAt(_random.nextInt(length));
  }

  /// Returns true if this iterable contains all elements from [other].
  @useResult
  bool containsAll(Iterable<T> other) {
    for (final T element in other) {
      if (!contains(element)) {
        return false;
      }
    }

    return true;
  }

  /// Returns the number of elements that satisfy the given [predicate].
  @useResult
  int countWhere(ElementPredicate<T> predicate) {
    int count = 0;
    for (final T element in this) {
      if (predicate(element)) count++;
    }

    return count;
  }
}
