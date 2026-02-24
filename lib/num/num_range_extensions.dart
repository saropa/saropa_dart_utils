import 'package:meta/meta.dart';

/// Extension methods for `num` (and its subtypes like `int`, `double`).
extension NumRangeExtensions on num {
  /// Returns true if the number is between [min] and [max] inclusive.
  @useResult
  bool isInRange(num min, final num max) => this >= min && this <= max;

  /// Returns the [min] if the number is less than [min], [max] if greater
  /// than [max], or the number itself otherwise.
  @useResult
  num forceInRange(num min, final num max) => this < min ? min : (this > max ? max : this);

  /// Returns `true` if this number is NOT between [from] and [to] inclusive.
  ///
  /// ```dart
  /// print(0.5.isBetween(0, 10)); // true
  /// print(10.isBetween(1, 10)); // true
  /// ```
  @useResult
  bool isNotBetween(num from, final num to) => !isBetween(from, to);

  /// Returns `true` if this number is between [from] and [to] inclusive.
  ///
  /// ```dart
  /// print(0.5.isBetween(0, 10)); // true
  /// print(10.isBetween(1, 10)); // true
  /// ```
  @useResult
  bool isBetween(num from, final num to) => from <= this && to >= this;
}
