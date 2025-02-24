/// Extension methods for [List].
extension ListExtensions<T> on List<T> {
  /// Returns the element that occurs most frequently in the list.
  ///
  /// This method iterates through the list, counts the occurrences of each element,
  /// and returns the element with the highest count. In case of a tie (multiple elements
  /// with the same highest frequency), the first encountered element with that frequency is returned.
  ///
  /// Returns:
  /// The most frequently occurring element of type `T` in the list.
  /// Returns `null` if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// List<String> items = ['apple', 'banana', 'apple', 'orange', 'apple'];
  /// String? mostFrequent = items.topOccurrence(); // Returns 'apple'
  ///
  /// List<int> numbers = [1, 2, 2, 3, 3, 3];
  /// int? topNumber = numbers.topOccurrence(); // Returns 3
  ///
  /// List<String> emptyList = [];
  /// String? topEmpty = emptyList.topOccurrence(); // Returns null
  /// ```
  T? topOccurrence() {
    // Check if the list is empty. If it is, return null.
    if (isEmpty) {
      return null;
    }

    final Map<T, int> counts = <T, int>{};
    for (final T element in this) {
      counts[element] = (counts[element] ?? 0) + 1;
    }

    T? mostFrequentElement;
    int maxCount = 0;
    for (final MapEntry<T, int> entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequentElement = entry.key;
      }
    }

    return mostFrequentElement;
  }

  /// Adds a value to the list only if it is not null.
  ///
  /// This method provides a null-safe way to add elements to a list, preventing
  /// `null` values from being added.
  ///
  /// Parameters:
  ///   - `value`: The value of type `T` to add to the list. If `value` is null, nothing is added.
  ///
  /// Example:
  /// ```dart
  /// List<String> items = [];
  /// items.addNotNull('apple'); // 'apple' is added
  /// items.addNotNull(null);    // Nothing is added
  /// print(items); // Output: ['apple']
  /// ```
  void addNotNull(T? value) {
    if (value != null) {
      add(value);
    }
  }

  /// Returns a new list containing the first `count` elements of this list.
  ///
  /// If the list is empty, or if `count` is zero or negative, the original list is returned.
  /// If `count` is greater than or equal to the length of the list, the original list is also returned.
  ///
  /// Parameters:
  ///   - `count`: The maximum number of elements to include in the new list. Must be a positive integer to have effect.
  ///
  /// Returns:
  /// A new [List<T>] containing at most the first `count` elements of the original list,
  /// or the original list if `count` is not positive or greater than or equal to the list's length, or if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// List<int> numbers = [1, 2, 3, 4, 5];
  /// List<int> limitedNumbers = numbers.limit(3); // Returns [1, 2, 3]
  ///
  /// List<String> emptyList = [];
  /// List<String> limitedEmpty = emptyList.limit(2); // Returns []
  ///
  /// List<int> numbersLimitZero = numbers.limit(0); // Returns [1, 2, 3, 4, 5] (original list)
  /// ```
  List<T> limit(int count) {
    if (isEmpty || count <= 0 || length <= count) {
      return this;
    }

    return take(count).toList();
  }

  /// Returns the last element in the list, or `null` if the list is empty.
  ///
  /// This getter provides a safe way to access the last element of a list without
  /// throwing an exception if the list is empty.
  ///
  /// Returns:
  /// The last element of type `T` in the list, or `null` if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// List<String> items = ['apple', 'banana', 'cherry'];
  /// String? lastItem = items.lastOrNull; // Returns 'cherry'
  ///
  /// List<int> emptyList = [];
  /// int? lastEmptyItem = emptyList.lastOrNull; // Returns null
  /// ```
  T? get lastOrNull {
    if (isEmpty) {
      return null;
    }

    return last;
  }

  /// Returns the element at the specified index in the list, or `null` if the index is out of bounds or null.
  ///
  /// This method provides a safe way to access list elements by index, preventing
  /// `RangeError` exceptions for out-of-bounds indices and handling null index gracefully.
  ///
  /// Parameters:
  ///   - `index`: The index of the element to retrieve. Can be null.
  ///
  /// Returns:
  /// The element of type `T` at the specified `index`, or `null` if the list is empty,
  /// `index` is null, or `index` is out of range (negative or greater than or equal to list length).
  ///
  /// Example:
  /// ```dart
  /// List<String> items = ['apple', 'banana', 'cherry'];
  /// String? itemAtIndex1 = items.itemAt(1); // Returns 'banana'
  /// String? itemAtIndex10 = items.itemAt(10); // Returns null (out of range)
  /// String? itemAtNullIndex = items.itemAt(null); // Returns null (null index)
  ///
  /// List<int> emptyList = [];
  /// int? itemAtEmptyList = emptyList.itemAt(0); // Returns null (empty list)
  /// ```
  T? itemAt(int? index) {
    // Check if index is null
    if (isEmpty || index == null) {
      return null;
    }

    // Check if index is within range
    if (index >= 0 && index < length) {
      // Return item at index
      return this[index];
    }

    // Return null if index is out of range
    return null;
  }

  // /// Alias for [itemAt].
  // @Deprecated('Use itemAt instead')
  // T? safeIndex(int? index) => itemAt(index);

  /// Returns `null` if the list is empty, otherwise returns the list itself.
  ///
  /// This method is useful for converting an empty list to `null`, which can be
  /// helpful in scenarios where `null` represents the absence of data, and an empty list
  /// might be treated differently.
  ///
  /// Returns:
  /// The list itself (`this`) if it is not empty, otherwise returns `null`.
  ///
  /// Example:
  /// ```dart
  /// List<String> items = ['apple', 'banana'];
  /// List<String>? notNullList = items.nullIfEmpty(); // Returns items (not null)
  ///
  /// List<int> emptyList = [];
  /// List<int>? nullList = emptyList.nullIfEmpty(); // Returns null
  /// ```
  List<T>? nullIfEmpty() => isEmpty ? null : this;

  /// Returns a new list containing at most the first `count` elements of this list, in a safe manner.
  ///
  /// This method is designed to safely take a specified number of elements from a list, handling
  /// cases where the count is null, zero, or negative, and providing an option to ignore zero or less counts.
  ///
  /// Parameters:
  ///   - `count`: The number of elements to take. If `null`, the original list is returned.
  ///   - `ignoreZeroOrLess`: If `true` (default), when `count` is zero or less, the original list is returned.
  ///                         If `false`, when `count` is zero or less, an empty list is returned.
  ///
  /// Returns:
  /// A new [List<T>] containing at most the first `count` elements, or the original list
  /// if `count` is `null`, or based on `ignoreZeroOrLess` behavior when `count` is zero or less, or if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// List<int> numbers = [1, 2, 3, 4, 5];
  /// List<int> safeTakenNumbers = numbers.takeSafe(3); // Returns [1, 2, 3]
  /// List<int> safeTakenZero = numbers.takeSafe(0); // Returns [1, 2, 3, 4, 5] (ignoreZeroOrLess is true by default)
  /// List<int> safeTakenZeroEmpty = numbers.takeSafe(0, ignoreZeroOrLess: false); // Returns []
  /// List<int> safeTakenNullCount = numbers.takeSafe(null); // Returns [1, 2, 3, 4, 5]
  /// ```
  List<T> takeSafe(int? count, {bool ignoreZeroOrLess = true}) {
    // Return the unaltered list if the iterable is empty, count is null,
    // or ignoreZeroOrLess is true and count is less than or equal to zero
    if (isEmpty || count == null || (ignoreZeroOrLess && count <= 0)) {
      return this;
    }

    // Handle negative count when ignoreZeroOrLess is false: return empty list
    if (!ignoreZeroOrLess && count < 0) {
      // Return empty list for negative count when not ignoring zero or less
      return <T>[];
    }

    // Return the taken elements
    return take(count).toList();
  }

  /// Returns a new list containing elements from this list, excluding any elements that are present in the `items` list.
  ///
  /// This method iterates over the original list and includes elements in the result list only if they are not found in the `items` list.
  /// It handles null or empty lists for both the original list and the `items` list gracefully, returning the original list if either is null or empty.
  ///
  /// Parameters:
  ///   - `items`: A [List<T>] of items to exclude from the original list. If `null` or empty, no elements are excluded.
  ///
  /// Returns:
  /// A new [List<T>] containing elements from the original list, excluding those present in `items`.
  /// Returns the original list if it's null or empty, or if `items` is null or empty.
  ///
  /// Example:
  /// ```dart
  /// List<int> numbers = [1, 2, 3, 4, 5];
  /// List<int> excludedNumbers = numbers.exclude([2, 4]); // Returns [1, 3, 5]
  ///
  /// List<String> items = ['apple', 'banana', 'cherry', 'date'];
  /// List<String> excludedItems = items.exclude(['banana', 'date']); // Returns ['apple', 'cherry']
  ///
  /// List<int> numbersExcludeEmpty = numbers.exclude([]); // Returns [1, 2, 3, 4, 5] (no exclusion)
  /// List<int> emptyListExclude = [].exclude([1, 2]); // Returns [] (empty list remains empty)
  /// ```
  List<T> exclude(List<T> items) {
    // nothing in list to process
    if (isEmpty) {
      return this;
    }

    // nothing to exclude
    if (items.isEmpty) {
      return this;
    }

    return where((T e) => !items.contains(e)).toList();
  }

  /// Checks if this list contains any element that is also present in the `inThis` list.
  ///
  /// The method iterates through each element in the current list and checks if that element
  /// is contained within the `inThis` list. If a match is found, it immediately returns `true`.
  /// If no matches are found after checking all elements, it returns `false`.
  /// It handles null or empty lists for both the original list and `inThis` list gracefully, returning `false` if either is null or empty.
  ///
  /// Parameters:
  ///   - `inThis`: A [List<T>?] to check for any common elements with the original list. If `null` or empty, returns `false`.
  ///
  /// Returns:
  /// `true` if at least one element from this list is also present in `inThis`, otherwise `false`.
  /// Returns `false` if this list is empty, or if `inThis` is null or empty.
  ///
  /// Example:
  /// ```dart
  /// List<int> numbers = [1, 2, 3, 4, 5];
  /// bool containsAnyOf = numbers.containsAny([3, 6]); // Returns true (because 3 is in both lists)
  /// bool containsAnyNone = numbers.containsAny([6, 7]); // Returns false (no common elements)
  ///
  /// List<String> items = ['apple', 'banana', 'cherry'];
  /// bool containsAnyItem = items.containsAny(['cherry', 'date']); // Returns true (because 'cherry' is common)
  ///
  /// List<int> emptyListContainsAny = [].containsAny([1, 2]); // Returns false (empty list)
  /// bool containsAnyNullList = numbers.containsAny(null); // Returns false (null inThis list)
  /// ```
  bool containsAny(List<T>? inThis) {
    if (isEmpty) {
      return false;
    }

    if (inThis == null || inThis.isEmpty) {
      return false;
    }

    for (final T find in this) {
      if (inThis.contains(find)) {
        // fund
        return true;
      }
    }

    // not found
    return false;
  }
}
