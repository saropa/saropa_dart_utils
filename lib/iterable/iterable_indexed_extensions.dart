import 'package:meta/meta.dart';

/// Indexed map and fold.
extension IterableIndexedExtensions<T> on Iterable<T> {
  /// Maps each element with its index: (index, element) -> newValue.
  @useResult
  Iterable<U> mapIndexed<U>(U Function(int index, T element) f) sync* {
    int i = 0;
    for (final T element in this) {
      yield f(i++, element);
    }
  }

  /// Fold with index: (prev, index, element) -> next.
  @useResult
  U foldIndexed<U>(U initial, U Function(U previous, int index, T element) f) {
    U value = initial;
    int i = 0;
    for (final T element in this) {
      value = f(value, i++, element);
    }
    return value;
  }
}
