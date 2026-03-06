import 'package:meta/meta.dart';

/// Is in closed/open range. Roadmap #137. NumRangeExtensions has isBetween (inclusive).
extension NumRangeInclusiveExclusiveExtensions on num {
  /// True if strictly between [min] and [max] (exclusive).
  @useResult
  bool isInRangeExclusive(num min, num max) => this > min && this < max;

  /// True if in [min, max] inclusive (alias for isBetween).
  @useResult
  bool isInRangeInclusive(num min, num max) => this >= min && this <= max;
}
