extension IntNullableExtensions on int? {
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
