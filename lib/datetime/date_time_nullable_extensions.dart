/// Extension methods for nullable DateTime (`DateTime?`) to enhance null-aware DateTime comparisons,
/// especially useful for sorting and ordering operations where null DateTimes need to be handled explicitly.
extension DateTimeNullableExtensions on DateTime? {
  /// Checks if this nullable DateTime is before another nullable DateTime for sorting purposes.
  ///
  /// Null DateTimes are considered to be before non-null DateTimes.
  /// Two null DateTimes are considered equal.
  ///
  /// Returns:
  /// - `true` if this nullable DateTime is considered before the `other` nullable DateTime.
  /// - `false` otherwise.
  ///
  /// Example Usage:
  /// ```dart
  /// DateTime? dt1 = DateTime.now();
  /// DateTime? dt2 = dt1.add(Duration(days: 1));
  /// DateTime? dt3 = null;
  ///
  /// dt1.isBeforeNullable(dt2); // true
  /// dt2.isBeforeNullable(dt1); // false
  /// dt1.isBeforeNullable(dt1); // false (not strictly before, but not considered before for sorting)
  /// dt3.isBeforeNullable(dt1); // true (null is considered before non-null)
  /// dt1.isBeforeNullable(dt3); // false (non-null is not before null)
  /// dt3.isBeforeNullable(null); // false (not strictly before, but not considered before for sorting)
  /// ```
  bool isBeforeNullable(DateTime? other) {
    if (this == null) {
      return other != null; // null is before non-null, null is not before null
    }

    if (other == null) {
      return false; // non-null is not before null
    }

    return this!.isBefore(other);
  }

  /// Compares two nullable DateTimes for sorting purposes.
  ///
  /// Null DateTimes are considered to be before non-null DateTimes.
  ///
  /// Returns:
  /// - `0` if both DateTimes are considered equal (both null or representing the same point in time).
  /// - `-1` if this nullable DateTime is considered smaller (comes before) the `other` nullable DateTime.
  /// - `1` if this nullable DateTime is considered larger (comes after) the `other` nullable DateTime.
  ///
  /// Example Usage:
  /// ```dart
  /// DateTime? dt1 = DateTime.now();
  /// DateTime? dt2 = dt1.add(Duration(days: 1));
  /// DateTime? dt3 = null;
  ///
  /// dt1.compareDateTimeNullable(dt2); // -1
  /// dt2.compareDateTimeNullable(dt1); // 1
  /// dt1.compareDateTimeNullable(dt1); // 0
  /// dt3.compareDateTimeNullable(dt1); // -1 (null is considered before non-null)
  /// dt1.compareDateTimeNullable(dt3); // 1 (non-null is considered after null)
  /// dt3.compareDateTimeNullable(null); // 0 (both null are considered equal)
  /// ```
  int compareDateTimeNullable(DateTime? other) {
    if (this == other) {
      return 0;
    }

    if (this == null) {
      return -1;
    }

    if (other == null) {
      return 1;
    }

    return this!.compareTo(other);
  }
}
