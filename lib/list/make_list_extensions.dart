/// This is an extension on the generic type T
extension MakeListExtensions<T> on T {
  /// This method converts an object to a list if it's not null
  List<T>? toListIfNotNull() =>
      // If 'this' is null, it returns null
      this == null
      ? null
      // If 'this' is not null, it returns a list containing 'this'
      : <T>[this!];
}
