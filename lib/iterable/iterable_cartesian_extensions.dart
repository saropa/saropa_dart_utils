import 'package:meta/meta.dart';

/// Cartesian product of two iterables.
extension IterableCartesianExtensions<T> on Iterable<T> {
  /// Cartesian product: all pairs (a, b) for a in this, b in [other].
  @useResult
  Iterable<(T, U)> cartesian<U>(Iterable<U> other) sync* {
    final List<T> thisList = toList();
    final List<U> otherList = other.toList();
    for (final T a in thisList) {
      for (final U b in otherList) {
        yield (a, b);
      }
    }
  }
}
