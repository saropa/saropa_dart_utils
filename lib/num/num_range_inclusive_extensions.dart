import 'package:meta/meta.dart';

/// Is in closed/open range. Roadmap #137. NumRangeExtensions has isBetween (inclusive).
extension NumRangeInclusiveExclusiveExtensions on num {
  /// True if strictly between [min] and [max] (exclusive).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool isInRangeExclusive(num min, num max) => this > min && this < max;

  /// True if in [min, max] inclusive (alias for isBetween).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool isInRangeInclusive(num min, num max) => this >= min && this <= max;
}
