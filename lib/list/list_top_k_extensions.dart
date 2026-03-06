import 'package:meta/meta.dart';

const String _kErrKPositive = 'k must be positive';
const String _kParamK = 'k';
const String _kErrTMustImplementComparable = 'T must implement Comparable';

/// Top K elements (partial sort).
extension ListTopKExtensions<T> on List<T> {
  /// Returns the [k] smallest elements by [compare]. Default [compare] is [Comparable.compare].
  /// [k] must be positive; returns full list if k >= length.
  @useResult
  List<T> topK(int k, [int Function(T a, T b)? compare]) {
    if (k < 1) throw ArgumentError(_kErrKPositive, _kParamK);
    if (length <= k) return toList();
    final int Function(T a, T b) cmp =
        compare ??
        (T a, T b) => a is Comparable<dynamic>
            ? a.compareTo(b)
            : (throw ArgumentError(_kErrTMustImplementComparable));
    final List<T> copy = toList();
    copy.sort(cmp);
    return copy.sublist(0, k);
  }
}
