import 'package:meta/meta.dart';

/// Symmetric difference (elements in A or B but not both).
extension IterableSymmetricDifferenceExtensions<T> on Iterable<T> {
  /// Symmetric difference: elements in this or [other] but not in both.
  @useResult
  List<T> symmetricDifference(Iterable<T> other) {
    final Set<T> a = toSet();
    final Set<T> b = other.toSet();
    return <T>[...a.where((T x) => !b.contains(x)), ...b.where((T x) => !a.contains(x))];
  }
}
