import 'package:meta/meta.dart';

/// Clamp [DateTime] to a range.
extension DateTimeClampExtensions on DateTime {
  /// Returns this [DateTime] clamped to [min] and [max].
  @useResult
  DateTime clampTo(DateTime min, DateTime max) {
    if (isBefore(min)) return min;
    if (isAfter(max)) return max;
    return this;
  }
}
