extension IntNullableExtensions on int? {
  int compareToIntNullable(int? second) {
      // ref: https://stackoverflow.com/questions/61881850/sort-list-based-on-boolean
      if (this == second) {
        // same
        return 0;
      }

      // this is smaller
      if (this == null) {
        return -1;
      }

      // second is smaller
      if (second == null) {
        return 1;
      }

      return this! < second ? -1 : 1;
   
  }
}
