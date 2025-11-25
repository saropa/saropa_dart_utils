import 'package:saropa_dart_utils/list/unique_list_extensions.dart';

extension ListOfListExtension<T> on List<List<T>> {
  /// sum the total number of items
  ///
  int get totalLength {
    if (isEmpty) {
      return 0;
    }

    // use the fold method to iterate over each List<int> in myList
    // and add its length to a running total. The initial value
    // for the total is 0.
    return fold(0, (int sum, final List<T> list) => sum + list.length);
  }

  /// Getting the length of [toFlattenedList]
  ///
  int get totalUniqueLength {
    if (isEmpty) {
      return 0;
    }

    return toFlattenedList()?.length ?? 0;
  }

  /// Extension method that returns a flattened set of type T
  ///
  List<T>? toFlattenedList({bool ignoreNulls = true}) {
    if (isEmpty) {
      return null;
    }

    // Use expand() method to flatten the 2D list and create a
    // new set with the same elements as this iterable
    return expand((List<T> e) => e).toUnique(ignoreNulls: ignoreNulls);
  }

  /// Returns a list containing the lengths of the child lists in parentList.
  ///
  /// The returned list will have the same length as parentList, with each element
  /// corresponding to the length of the child list at the same index in parentList.
  ///
  /// Example:
  /// ```dart
  /// List<List<int>> myParentList =<List<int>>[[1, 2], [3, 4, 5], [6]];
  ///
  /// List<int> childListLengths = getChildListLengths(myParentList);
  ///
  /// print(childListLengths); // [2, 3, 1]
  /// ```
  ///
  List<int>? getChildListLengths() => map((List<T> childList) => childList.length).toList();

  /// Copies the elements of this list into [destination].
  ///
  /// The dimensions of [destination] must be the same as this list.
  ///
  bool copy(List<List<T>> destination) {
    // Check row count first
    if (length != destination.length) {
      return false;
    }

    // Check column count for ALL rows before starting the copy
    for (int i = 0; i < length; i++) {
      if (this[i].length != destination[i].length) {
        return false;
      }
    }

    // If dimensions match, perform the copy
    for (int i = 0; i < length; i++) {
      for (int j = 0; j < this[i].length; j++) {
        destination[i][j] = this[i][j];
      }
    }
    return true;
  }

  /// Returns a new list that is an exact duplicate of this list.
  ///
  List<List<T>> clone() {
    final List<List<T>> newList = <List<T>>[];

    for (List<T> innerList in this) {
      newList.add(List<T>.from(innerList));
    }

    return newList;
  }

  /// Converts a two-dimensional matrix into a string with comma-separated
  /// values and line breaks between rows.
  ///
  /// Returns a string representation of the matrix with comma-separated
  /// values and line breaks between rows.
  ///
  String? toMatrixString({String lineBreak = '\n'}) {
    // Create a StringBuffer to store the result
    final StringBuffer result = StringBuffer();

    // Iterate over each row in the matrix
    for (int i = 0; i < length; i++) {
      // Map each element to its string representation, converting nulls to
      // empty strings, then join the parts with a comma.
      result.write(this[i].map((dynamic e) => e?.toString() ?? '').join(','));

      // If this is not the last row, add a line break to the result string
      if (i < length - 1) {
        result.write(lineBreak);
      }
    }

    // Return the result string
    return result.toString();
  }
}
