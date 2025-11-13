/// Extension methods for `num` (and its subtypes like `int`, `double`).
extension NumRangeExtensions on num {
  /// Returns true if the number is between [min] and [max] inclusive.
  bool isInRange(num min, final num max) => this >= min && this <= max;

  /// Returns the [min] if the number is less than [min], [max] if greater
  /// than [max], or the number itself otherwise.
  num forceInRange(num min, final num max) => this < min ? min : (this > max ? max : this);

  /// Is NOT this greater than or equal to [from] and less than or equal
  /// to [to]?
  ///
  /// NOTE: Inclusive match
  ///
  /// ```dart
  /// print(0.5.isBetween(0, 10)); // true
  /// print(10.isBetween(1, 10)); // true
  /// ```
  bool isNotBetween(num from, final num to) => !isBetween(from, to);

  /// Is this greater than or equal to [from] and less than or equal to [to]?
  ///
  /// NOTE: Inclusive match
  ///
  /// ```dart
  /// print(0.5.isBetween(0, 10)); // true
  /// print(10.isBetween(1, 10)); // true
  /// ```
  bool isBetween(num from, final num to) => from <= this && to >= this;
}
