import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

/// First/last where with default.
extension IterableFirstLastWhereExtensions<T> on Iterable<T> {
  /// First element satisfying [predicate], or [orElse] if none.
  T firstWhereOrElse(ElementPredicate<T> predicate, T orElse) {
    for (final T element in this) {
      if (predicate(element)) return element;
    }
    return orElse;
  }

  /// Last element satisfying [predicate], or [orElse] if none.
  T lastWhereOrElse(ElementPredicate<T> predicate, T orElse) {
    T? found;
    for (final T element in this) {
      if (predicate(element)) found = element;
    }
    return found ?? orElse;
  }
}
