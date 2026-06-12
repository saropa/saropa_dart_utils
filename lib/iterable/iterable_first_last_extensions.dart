import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

/// First/last where with default.
extension IterableFirstLastWhereExtensions<T> on Iterable<T> {
  /// First element satisfying [predicate], or [orElse] if none.
  /// Audited: 2026-06-12 11:26 EDT
  T firstWhereOrElse(ElementPredicate<T> predicate, T orElse) {
    for (final T element in this) {
      if (predicate(element)) return element;
    }
    return orElse;
  }

  /// Last element satisfying [predicate], or [orElse] if none.
  /// Audited: 2026-06-12 11:26 EDT
  T lastWhereOrElse(ElementPredicate<T> predicate, T orElse) {
    // Start from orElse and overwrite on each match so the LAST match wins and a
    // matched `null` (nullable T) is preserved. `found ?? orElse` would wrongly
    // drop a matched null and return orElse instead.
    T result = orElse;
    for (final T element in this) {
      if (predicate(element)) result = element;
    }
    return result;
  }
}
