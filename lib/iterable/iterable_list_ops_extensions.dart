import 'package:meta/meta.dart';

/// List/set operations: difference, intersection, union, interleave.
extension IterableListOpsExtensions<T> on Iterable<T> {
  /// Elements in this iterable that are not in [other]. Uses Object.== and hashCode.
  ///
  /// Returns a new list of elements in this iterable not present in [other].
  @useResult
  List<T> difference(Iterable<T> other) {
    final Set<T> otherSet = other.toSet();
    return where((T x) => !otherSet.contains(x)).toList();
  }

  /// Elements that appear in both this and [other].
  ///
  /// Returns a new list of elements present in both iterables.
  @useResult
  List<T> intersection(Iterable<T> other) {
    final Set<T> otherSet = other.toSet();
    return where((T x) => otherSet.contains(x)).toList();
  }

  /// Distinct union of this and [other] (all elements, no duplicates).
  ///
  /// Returns a new list containing each distinct element from both iterables.
  @useResult
  List<T> union(Iterable<T> other) => <T>{...this, ...other}.toList();

  /// Interleaves this with [other]: [a0, b0, a1, b1, ...]. Stops when the shorter runs out.
  ///
  /// Returns a new list with elements from this and [other] interleaved.
  @useResult
  List<T> interleave(Iterable<T> other) {
    final Iterator<T> iterA = iterator;
    final Iterator<T> iterB = other.iterator;
    final List<T> result = <T>[];
    while (true) {
      if (iterA.moveNext()) {
        result.add(iterA.current);
      } else {
        break;
      }
      if (iterB.moveNext()) {
        result.add(iterB.current);
      } else {
        break;
      }
    }
    return result;
  }
}
