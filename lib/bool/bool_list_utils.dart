extension BoolListExtensions on Iterable<bool> {
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
    return where((final bool e) => e).isNotEmpty;
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
    return where((final bool e) => !e).isNotEmpty;
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
    return where((final bool e) => e).length;
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
    return where((final bool e) => !e).length;
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
