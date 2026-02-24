import 'package:meta/meta.dart';

extension IntNullableExtensions on int? {
  /// Returns a negative value if this is less than [second], zero if they are
  /// equal, and a positive value if this is greater than [second].
  ///
  /// Null values are considered less than non-null values. Two null values
  /// are considered equal.
  @useResult
  int compareToIntNullable(int? second) {
    final int? self = this;
    // ref: https://stackoverflow.com/questions/61881850/sort-list-based-on-boolean
    if (self == second) {
      // same
      return 0;
    }

    // this is smaller
    if (self == null) {
      return -1;
    }

    // second is smaller
    if (second == null) {
      return 1;
    }

    return self < second ? -1 : 1;
  }
}
