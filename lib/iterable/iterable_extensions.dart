import 'dart:collection';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/iterable/occurrence.dart';

const String _kErrSizePositive = 'size must be positive';
const String _kParamSize = 'size';
const String _kErrWindowSizePositive = 'windowSize must be positive';
const String _kParamWindowSize = 'windowSize';
const String _kErrNPositive = 'n must be positive';
const String _kParamN = 'n';

/// A function that tests whether an element of type [T] satisfies a condition.
typedef ElementPredicate<T> = bool Function(T element);

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

    return elementAt(Random().nextInt(length));
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

  List<T> _thisAsListOrToList() {
    final Iterable<T> self = this;
    if (self is List<T>) return self;
    return toList();
  }

  /// Splits this iterable into chunks of size [size].
  ///
  /// The last chunk may have fewer than [size] elements. [size] must be positive.
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 3, 4, 5].chunks(2); // [[1, 2], [3, 4], [5]]
  /// ```
  @useResult
  Iterable<List<T>> chunks(int size) {
    if (size < 1) {
      throw ArgumentError(_kErrSizePositive, _kParamSize);
    }
    final List<T> list = _thisAsListOrToList();
    final List<List<T>> result = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      final int end = i + size > list.length ? list.length : i + size;
      result.add(list.sublist(i, end));
    }
    return result;
  }

  /// Partitions elements into two lists: those that satisfy [predicate] and those that do not.
  ///
  /// Returns a record `(matched, unmatched)` where order is preserved.
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 3, 4].partition((x) => x.isEven); // ([2, 4], [1, 3])
  /// ```
  @useResult
  (List<T>, List<T>) partition(ElementPredicate<T> predicate) {
    final List<T> matched = <T>[];
    final List<T> unmatched = <T>[];
    for (final T element in this) {
      if (predicate(element)) {
        matched.add(element);
      } else {
        unmatched.add(element);
      }
    }
    return (matched, unmatched);
  }

  /// Groups elements by the key produced by [keyOf].
  ///
  /// Returns a map from key to list of elements in encounter order. [keyOf] must not return null.
  ///
  /// Example:
  /// ```dart
  /// ['a', 'ab', 'b'].groupBy((s) => s.length); // {1: ['a', 'b'], 2: ['ab']}
  /// ```
  @useResult
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final Map<K, List<T>> result = <K, List<T>>{};
    for (final T element in this) {
      final K key = keyOf(element);
      result.putIfAbsent(key, () => <T>[]).add(element);
    }
    return result;
  }

  /// Sliding windows of size [windowSize]. Each window is a list of [windowSize] elements.
  ///
  /// [windowSize] must be positive. Fewer than [windowSize] elements at the end are skipped.
  @useResult
  Iterable<List<T>> slidingWindow(int windowSize) {
    if (windowSize < 1) throw ArgumentError(_kErrWindowSizePositive, _kParamWindowSize);
    final List<T> list = _thisAsListOrToList();
    if (list.length < windowSize) return <List<T>>[];
    return Iterable<List<T>>.generate(
      list.length - windowSize + 1,
      (int i) => list.sublist(i, i + windowSize),
    );
  }

  /// Distinct elements by key; keeps first occurrence of each key.
  @useResult
  List<T> distinctBy<K>(K Function(T) keyOf) {
    final Set<K> seen = <K>{};
    final List<T> result = <T>[];
    for (final T element in this) {
      final K key = keyOf(element);
      if (seen.add(key)) result.add(element);
    }
    return result;
  }

  /// Sorts by [keyOf] and returns a new list. [keyOf] must return [Comparable].
  @useResult
  List<T> sortBy<K extends Comparable<K>>(K Function(T) keyOf) {
    final List<T> list = toList();
    list.sort((T a, T b) => keyOf(a).compareTo(keyOf(b)));
    return list;
  }

  /// Zip with index: [(0, e0), (1, e1), ...].
  @useResult
  Iterable<(int, T)> zipWithIndex() sync* {
    int i = 0;
    for (final T element in this) {
      yield (i++, element);
    }
  }

  /// Takes every [n]-th element (1-based: first, then 1+n, 1+2n, ...). [n] must be positive.
  @useResult
  Iterable<T> takeEveryNth(int n) {
    if (n < 1) throw ArgumentError(_kErrNPositive, _kParamN);
    return zipWithIndex().where(((int, T) p) => p.$1 % n == 0).map(((int, T) p) => p.$2);
  }

  /// Skips every [n]-th element. [n] must be positive.
  @useResult
  Iterable<T> skipEveryNth(int n) {
    if (n < 1) throw ArgumentError(_kErrNPositive, _kParamN);
    return zipWithIndex().where(((int, T) p) => p.$1 % n != 0).map(((int, T) p) => p.$2);
  }

  /// Removes consecutive duplicate elements (keeps first of each run).
  @useResult
  Iterable<T> dedupeConsecutive() sync* {
    T? prev;
    for (final T element in this) {
      if (prev == null || element != prev) {
        yield element;
        prev = element;
      }
    }
  }
}
