import 'package:meta/meta.dart';

/// Flatten nested iterables.
extension IterableFlattenExtensions<E> on Iterable<Iterable<E>> {
  /// Flattens one level: Iterable<Iterable<E>> → Iterable<E>.
  @useResult
  Iterable<E> flatten() => expand((Iterable<E> x) => x);
}
