/// Saropa extensions for [List]s of [bool]s
///
extension BoolIterableExtensions on Iterable<bool> {
  /// Finds the most common value in the list.
  ///
  /// Returns a record (tuple) containing the most common value and its
  /// frequency.
  /// If the list is empty, returns null.
  (bool, int)? mostOccurrences() {
    if (isEmpty) {
      return null;
    }

    final int trueCount = countTrue;
    final int falseCount = length - trueCount;

    // When counts are equal, true is returned (consistent behavior)
    if (trueCount >= falseCount) {
      return (true, trueCount);
    }
    return (false, falseCount);
  }

  /// Finds the least common value in the list.
  ///
  /// Returns a record (tuple) containing the least common value and its
  /// frequency.
  /// If the list is empty, returns null.
  (bool, int)? leastOccurrences() {
    if (isEmpty) {
      return null;
    }

    final int trueCount = countTrue;
    final int falseCount = length - trueCount;

    // When counts are equal, false is returned (consistent behavior)
    if (falseCount <= trueCount) {
      return (false, falseCount);
    }
    return (true, trueCount);
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
  bool get anyTrue => any((bool e) => e);

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
  bool get anyFalse => any((bool e) => !e);

  /// Counts the number of `true` values in the iterable.
  ///
  /// This getter iterates through each element in the iterable and increments
  /// a counter each time it encounters a `true` value. The final count is
  /// returned.
  ///
  /// Returns:
  /// - The number of `true` values in the iterable.
  int get countTrue => where((bool e) => e).length;

  /// Counts the number of `false` values in the iterable.
  ///
  /// This getter iterates through each element in the iterable and increments
  /// a counter each time it encounters a `false` value. The final count is
  /// returned.
  ///
  /// Returns:
  /// - The number of `false` values in the iterable.
  int get countFalse => where((bool e) => !e).length;

  /// Reverses the boolean values in the list.
  ///
  /// This method iterates through each element in the list and flips its
  /// value. If the element is `true`, it becomes `false`, and vice versa.
  /// A new list with the reversed values is returned.
  ///
  /// Returns:
  /// - A new list with the boolean values reversed.
  List<bool> get reverse => map((bool b) => !b).toList();
}
