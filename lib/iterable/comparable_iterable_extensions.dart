extension ComparableIterableExtensions<T extends Comparable<T>> on Iterable<T> {
  /// Finds the smallest occurrence in the list.
  ///
  /// Returns the smallest element in the list based on the Comparable
  /// implementation.
  T? smallestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce((T value, T element) => value.compareTo(element) < 0 ? value : element);
  }

  /// Finds the biggest occurrence in the list.
  ///
  /// Returns the biggest element in the list based on the Comparable
  /// implementation.
  T? biggestOccurrence() {
    // check if the list is empty before calling reduce
    if (isEmpty) {
      return null;
    }

    return reduce((T value, T element) => value.compareTo(element) > 0 ? value : element);
  }
}
