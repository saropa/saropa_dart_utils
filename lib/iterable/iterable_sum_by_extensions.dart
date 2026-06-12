import 'package:meta/meta.dart';

/// Numeric aggregation by a selector function.
extension IterableSumByExtensions<T> on Iterable<T> {
  /// Sums [selector] applied to each element.
  ///
  /// Avoids the `.map(selector).fold(0, (a, b) => a + b)` boilerplate that gets
  /// rewritten in every app, and keeps the numeric reduction out of the
  /// element type (you cannot call `sum()` on `Iterable<Order>` — only on
  /// `Iterable<num>`). Returns `0` for an empty iterable, so the result is
  /// always usable without a null check.
  ///
  /// Example:
  /// ```dart
  /// orders.sumBy((o) => o.total); // total across all orders
  /// <Order>[].sumBy((o) => o.total); // 0
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  num sumBy(num Function(T element) selector) {
    num total = 0;
    for (final T element in this) {
      total += selector(element);
    }
    return total;
  }

  /// Mean of [selector] applied to each element, or `null` if the iterable is
  /// empty.
  ///
  /// Returns `null` rather than throwing or yielding `NaN` on an empty
  /// iterable, so the empty case is explicit at the call site (division by zero
  /// would otherwise silently produce `NaN`).
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 4].averageBy((n) => n); // 2.3333...
  /// <int>[].averageBy((n) => n);   // null
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  double? averageBy(num Function(T element) selector) {
    num total = 0;
    int count = 0;
    for (final T element in this) {
      total += selector(element);
      count++;
    }
    if (count == 0) {
      return null;
    }
    return total / count;
  }
}
