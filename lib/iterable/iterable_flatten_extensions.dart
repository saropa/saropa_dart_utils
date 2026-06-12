import 'package:meta/meta.dart';

/// Flatten nested iterables.
extension IterableFlattenExtensions<E> on Iterable<Iterable<E>> {
  /// Flattens one level: Iterable<Iterable<E>> → Iterable<E>.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Iterable<E> flatten() => expand((Iterable<E> x) => x);
}
