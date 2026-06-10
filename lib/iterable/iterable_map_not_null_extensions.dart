import 'package:meta/meta.dart';

/// Map-and-filter-nulls in a single pass.
extension IterableMapNotNullExtensions<T> on Iterable<T> {
  /// Applies [selector] to each element and yields only the non-null results.
  ///
  /// Replaces the common `.map(...).whereType<U>()` /
  /// `.map(...).where((e) => e != null).cast<U>()` two-step, which allocates an
  /// intermediate iterable of nullables and forces a cast. Doing both in one
  /// pass means [selector] runs exactly once per element and the result type is
  /// already the non-nullable `U` — no `cast` and no late null surprises.
  ///
  /// Lazy: nothing runs until the result is iterated.
  ///
  /// Example:
  /// ```dart
  /// ['1', 'x', '3'].mapNotNull(int.tryParse); // (1, 3)
  /// ```
  @useResult
  Iterable<U> mapNotNull<U>(U? Function(T element) selector) sync* {
    for (final T element in this) {
      final U? mapped = selector(element);
      if (mapped != null) {
        yield mapped;
      }
    }
  }
}

/// Drops `null` entries from an iterable of nullable elements.
extension IterableWhereNotNullExtensions<T extends Object> on Iterable<T?> {
  /// Returns the non-null elements as an `Iterable<T>`.
  ///
  /// Unlike `whereType<T>()`, the element type is recovered as the
  /// non-nullable [T] directly, so callers do not need a separate cast.
  ///
  /// Lazy: nothing runs until the result is iterated.
  ///
  /// Example:
  /// ```dart
  /// [1, null, 3].whereNotNull(); // (1, 3)
  /// ```
  @useResult
  Iterable<T> whereNotNull() sync* {
    for (final T? element in this) {
      if (element != null) {
        yield element;
      }
    }
  }
}
