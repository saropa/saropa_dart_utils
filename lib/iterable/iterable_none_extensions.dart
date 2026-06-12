import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

/// The boolean complement of [Iterable.any].
extension IterableNoneExtensions<T> on Iterable<T> {
  /// Returns `true` if no element satisfies [predicate].
  ///
  /// Equivalent to `!any(predicate)`, but reads as intent at the call site and
  /// avoids the easy-to-misplace `!` that flips the meaning silently.
  /// Short-circuits on the first match, so it is cheap on long iterables.
  ///
  /// An empty iterable returns `true` (vacuously: nothing violates the
  /// predicate), matching the convention of [Iterable.every].
  ///
  /// Example:
  /// ```dart
  /// [1, 3, 5].none((n) => n.isEven); // true
  /// [1, 2, 3].none((n) => n.isEven); // false
  /// <int>[].none((n) => n.isEven);   // true
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  bool none(ElementPredicate<T> predicate) {
    for (final T element in this) {
      if (predicate(element)) {
        return false;
      }
    }
    return true;
  }
}
