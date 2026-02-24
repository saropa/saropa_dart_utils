import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/iterable/occurrence.dart';

/// Extension on Iterable&lt;double&gt; to provide additional properties and
///  methods specifically for lists of doubles.
extension DoubleIterableExtensions on Iterable<double> {
  /// Finds the smallest occurrence in the list.
  ///
  /// Returns the smallest element in the list based on the Comparable
  /// implementation.
  @useResult
  double? smallestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce((double value, double element) => value.compareTo(element) < 0 ? value : element);
  }

  /// Finds the biggest occurrence in the list.
  ///
  /// Returns the biggest element in the list based on the Comparable
  /// implementation.
  @useResult
  double? biggestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce((double value, double element) => value.compareTo(element) > 0 ? value : element);
  }

  /// Finds the most common value in the list.
  ///
  /// Returns an [Occurrence] containing the most common value and its
  /// frequency.
  /// If the list is empty, returns null.
  @useResult
  Occurrence<double>? mostOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each double and its frequency.
    final HashMap<double, int> frequencyMap = HashMap<double, int>();

    // Iterate over each double in the list.
    for (final double item in this) {
      // Update the frequency of the current double in the map, or set it to
      // 1 if it's not in the map yet.
      // ignore: require_future_error_handling
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // Find and return the key with the highest value (frequency) in the map.
    final MapEntry<double, int>? mostCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<double, int>? previous, MapEntry<double, int> element) =>
          previous == null || element.value > previous.value ? element : previous,
    );
    if (mostCommonEntry == null) {
      return null;
    }

    return Occurrence<double>(mostCommonEntry.key, mostCommonEntry.value);
  }

  /// Finds the least common value in the list.
  ///
  /// Returns an [Occurrence] containing the least common value and its
  /// frequency.
  /// If the list is empty, returns null.
  @useResult
  Occurrence<double>? leastOccurrences() {
    if (isEmpty) {
      return null;
    }

    // Create a new HashMap to store each double and its frequency.
    final HashMap<double, int> frequencyMap = HashMap<double, int>();

    // Iterate over each double in the list.
    for (final double item in this) {
      // Update the frequency of the current double in the map,
      // or set it to 1 if it's not in the map yet.
      // ignore: require_future_error_handling
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // Find and return the key with the highest value (frequency) in the map.
    final MapEntry<double, int>? leastCommonEntry = frequencyMap.entries.fold(
      null,
      (MapEntry<double, int>? previous, MapEntry<double, int> element) =>
          previous == null || element.value < previous.value ? element : previous,
    );

    if (leastCommonEntry == null) {
      return null;
    }

    return Occurrence<double>(leastCommonEntry.key, leastCommonEntry.value);
  }
}
